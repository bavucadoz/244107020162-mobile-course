import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/features/settings/presentation/providers/settings_providers.dart';

import '../../../../core/network/api_client.dart';

import 'package:week5_offline_notes/core/local/db.dart';

import '../../domain/repositories/post_repository.dart';
import '../../domain/entities/post.dart';
import '../../data/repositories/post_repository_impl.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    apiClient: ref.watch(dioProvider),
    openDb: openNotesDb,
  );
});

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(postRepositoryProvider);
    final isForceOffline = ref.watch(forceOfflineProvider);

    // Caching, background refresh, offline check SEMUANYA ditangani oleh repository
    final result = await repository.getPosts(forceOffline: isForceOffline);
    if (result.failure != null) throw Exception(result.failure!.message);
    return result.posts;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidateSelf(); // Biarkan Riverpod mengulang fungsi build()
  }
}

final postDetailProvider = FutureProvider.autoDispose.family<Post, int>((
  ref,
  id,
) async {
  final repository = ref.watch(postRepositoryProvider);
  // Repository yang bertugas mengecek SQLite/Cache memori vs Network
  final result = await repository.getPostById(id);
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.post!;
});
