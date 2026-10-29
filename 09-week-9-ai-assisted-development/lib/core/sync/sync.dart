import '../../features/notes/domain/repositories/note_repository.dart';
import '../../features/posts/domain/repositories/post_repository.dart';
import '../../features/posts/domain/entities/post.dart';

class SyncService {
  /// Antrean Sinkronisasi Catatan Kotor (dirty)
  static Future<int> syncNotes(
    NoteRepository repo, {
    bool isOffline = false,
  }) async {
    if (isOffline) {
      throw Exception('Gagal sync: Perangkat dalam status offline.');
    }

    // 1. Ambil nilai record dan cek kegagalan
    final result = await repo.countDirty();
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }

    // 2. Ekstrak jumlah count
    final dirtyCount = result.count;
    if (dirtyCount == 0) return 0;

    // 3. Simulasi upload ke server
    await Future.delayed(const Duration(seconds: 1));
    await repo.markAllSynced();

    return dirtyCount;
  }

  /// Cache-First Read untuk Data API
  static Future<List<Post>> loadPostsCacheFirst(
    PostRepository repo, {
    bool isOffline = false,
  }) async {
    // Repository sekarang pintar, sudah membungkus logika cache-first di dalamnya
    final result = await repo.getPosts(forceOffline: isOffline);

    if (result.failure != null) {
      // Jika error, Anda bisa melemparkan eksepsi agar ditangkap UI
      throw Exception(result.failure!.message);
    }

    return result.posts;
  }
}
