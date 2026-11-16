import '../../../../core/failures.dart';
import '../entities/post.dart';

abstract class PostRepository {
  /// Mengambil daftar post (menangani cache & network di belakang layar)
  Future<({List<Post> posts, Failure? failure})> getPosts({
    bool forceOffline = false,
  });

  /// Mengambil detail post berdasarkan ID
  Future<({Post? post, Failure? failure})> getPostById(int id);
}
