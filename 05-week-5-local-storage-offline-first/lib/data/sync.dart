import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';
import 'local/post.dart';

class SyncService {
  /// Antrean Sinkronisasi Catatan Kotor (dirty)
  static Future<int> syncNotes(NoteRepository repo, {bool isOffline = false}) async {
    if (isOffline) {
      throw Exception('Gagal sync: Perangkat dalam status offline.');
    }

    final dirtyCount = await repo.countDirty();
    if (dirtyCount == 0) return 0;

    // Simulasi upload ke server
    await Future.delayed(const Duration(seconds: 1));
    await repo.markAllSynced();

    return dirtyCount;
  }

  /// Cache-First Read untuk Data API
  static Future<List<Post>> loadPostsCacheFirst(
    PostRepository repo, {
    bool isOffline = false,
  }) async {
    final cached = await repo.readCachedPosts();

    if (!isOffline) {
      try {
        return await repo.refreshPostsFromNetwork();
      } catch (_) {
        // Jika jaringan gagal, tetap kembalikan cache lokal
      }
    }

    return cached;
  }
}