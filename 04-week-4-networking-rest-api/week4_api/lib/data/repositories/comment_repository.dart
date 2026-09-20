import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment.dart';

// Provider untuk instance Dio global dengan timeout 10 detik
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10), // Timeout koneksi 10 detik
      receiveTimeout: const Duration(seconds: 10), // Timeout respon 10 detik
    ),
  );
});

// Provider untuk CommentRepository
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CommentRepository(dio);
});

class CommentRepository {
  final Dio _dio;

  CommentRepository(this._dio);

  // Mengambil daftar komentar berdasarkan postId
  Future<List<Comment>> fetchComments(int postId) async {
    try {
      final response = await _dio.get(
        '/comments',
        queryParameters: {'postId': postId},
      );

      final List<dynamic> data = response.data as List<dynamic>;

      // Mapping setiap item JSON ke instance Comment
      return data
          .map((item) => Comment.fromJson(item as Map<String, dynamic>?))
          .toList();
    } on DioException {
      // Re-throw DioException agar ditangkap secara otomatis oleh AsyncValue di Riverpod
      rethrow;
    } catch (e) {
      throw Exception('Gagal memproses data komentar: $e');
    }
  }
}