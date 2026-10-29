// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({
    required Dio apiClient,
    required Future<Database> Function() openDb,
  }) : _dio = apiClient,
       _openDb = openDb;

  final Dio _dio;
  final Future<Database> Function() _openDb;

  @override
  Future<({List<Post> posts, Failure? failure})> getPosts({
    bool forceOffline = false,
  }) async {
    try {
      final db = await _openDb();

      // Jika user maksa offline, langsung baca dari SQLite
      if (forceOffline) {
        final rows = await db.query('cached_posts');
        final posts = rows
            .map(
              (row) =>
                  PostModel.fromRawJson(row['payload'] as String).toEntity(),
            )
            .toList();
        return (posts: posts, failure: null);
      }

      // Jika online, coba fetch dari API
      final response = await _dio.get<List>('/posts');
      final data = response.data ?? [];
      final postModels = data
          .whereType<Map<String, dynamic>>()
          .map(PostModel.fromJson)
          .toList();

      // Simpan ke Cache (SQLite)
      final batch = db.batch();
      batch.delete('cached_posts'); // Hapus cache lama
      for (final model in postModels) {
        batch.insert('cached_posts', {
          'id': model.id,
          'payload': model.toRawJson(),
          'cached_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);

      // Kembalikan versi Entity murni ke UI
      final posts = postModels.map((m) => m.toEntity()).toList();
      return (posts: posts, failure: null);
    } catch (e) {
      // Jika internet mati (DioError), fallback baca dari SQLite
      try {
        final db = await _openDb();
        final rows = await db.query('cached_posts');
        if (rows.isNotEmpty) {
          final posts = rows
              .map(
                (row) =>
                    PostModel.fromRawJson(row['payload'] as String).toEntity(),
              )
              .toList();
          return (posts: posts, failure: null); // Sukses fallback ke cache
        }
      } catch (_) {}

      // Jika internet mati dan cache kosong, kirim error ke UI
      return (
        posts: const <Post>[],
        failure: NetworkFailure('Gagal memuat postingan: $e'),
      );
    }
  }

  @override
  Future<({Post? post, Failure? failure})> getPostById(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/posts/$id');
      final data = response.data;
      if (data == null) {
        return (
          post: null,
          failure: const NetworkFailure('Data tidak ditemukan'),
        );
      }
      final post = PostModel.fromJson(data).toEntity();
      return (post: post, failure: null);
    } catch (e) {
      return (
        post: null,
        failure: NetworkFailure('Gagal memuat detail post: $e'),
      );
    }
  }
}
