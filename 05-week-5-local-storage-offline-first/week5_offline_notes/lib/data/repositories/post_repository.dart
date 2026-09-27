import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/post.dart';

class PostRepository {
  PostRepository(
    this._dio, {
    Future<Database> Function()? openDb,
  }) : _openDb = openDb ?? openNotesDb;

  final Dio _dio;
  final Future<Database> Function() _openDb;

  // 1. Baca data dari Cache SQLite lokal secara instan
  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts');
    return rows
        .map((row) => Post.fromRawJson(row['payload'] as String))
        .toList();
  }

  /// 2. Fetch data dari Dio API dan perbarui tabel cached_posts
  Future<List<Post>> refreshPostsFromNetwork() async {
    final response = await _dio.get<List>('/posts');
    final data = response.data ?? [];
    final posts = data
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();

    final db = await _openDb();
    final batch = db.batch();
    
    // Bersihkan cache lama dan timpa dengan data terbaru
    batch.delete('cached_posts');
    for (final post in posts) {
      batch.insert(
        'cached_posts',
        {
          'id': post.id,
          'payload': post.toRawJson(),
          'cached_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    return posts;
  }

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get<List>('/posts');
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }

  Future<List<Post>> fetchPostsPage({
    required int page,
    int limit = 10,
  }) async {
    final response = await _dio.get<List>(
      '/posts',
      queryParameters: {'_page': page, '_limit': limit},
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }

  Future<Post> fetchPostById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/posts/$id');
    final data = response.data;
    if (data == null) {
      throw Exception('Data post dengan ID $id tidak ditemukan');
    }
    return Post.fromJson(data);
  }
}