import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';
import 'local/post.dart';

class SyncService {
  /// Sinkronisasi catatan kotor (dirty = true)
  static Future<int> syncNotes(NoteRepository repo, {bool isOffline = false}) async {
    if (isOffline) {
      throw Exception('Gagal sync: Perangkat dalam mode offline.');
    }

    final dirtyCount = await repo.countDirty();
    if (dirtyCount == 0) return 0;

    // Simulasi delay upload ke REST API
    await Future.delayed(const Duration(seconds: 1));

    // Tandai semua catatan kotor menjadi bersih (dirty = 0)
    await repo.markAllSynced();

    return dirtyCount;
  }

  /// Memuat data post dengan pola Cache-First Read
  static Future<List<Post>> loadPostsCacheFirst(
    PostRepository repo, {
    bool isOffline = false,
  }) async {
    // 1. Segera kembalikan cache lokal agar UI tidak blank
    final cached = await repo.readCachedPosts();

    // 2. Di background: fetch Dio -> simpan ke cached_posts jika online
    if (!isOffline) {
      try {
        return await repo.refreshPostsFromNetwork();
      } catch (_) {
        // Jika fetch jaringan gagal, biarkan tetap mengembalikan cache
      }
    }

    return cached;
  }
}