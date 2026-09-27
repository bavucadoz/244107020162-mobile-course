import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/repositories/api_client.dart';
import 'data/local/post.dart';
import 'data/repositories/post_repository.dart';
import 'pages/settings_pages.dart'; 

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(postRepositoryProvider);
    final isForceOffline = ref.watch(forceOfflineProvider);

    final cachedPosts = await repository.readCachedPosts();

    if (!isForceOffline) {
      _refreshInBackground();
    }
    return cachedPosts;
  }

  Future<void> _refreshInBackground() async {
    try {
      final repository = ref.read(postRepositoryProvider);
      final freshPosts = await repository.refreshPostsFromNetwork();
      state = AsyncData(freshPosts);
    } catch (e, st) {
      // Jika jaringan gagal/offline dan cache kosong, set error state
      if (state.value == null || state.value!.isEmpty) {
        state = AsyncError(e, st);
      }
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    await _refreshInBackground();
  }
}

final postListProvider =
    AsyncNotifierProvider<PostListNotifier, List<Post>>(
  PostListNotifier.new,
  retry: (retryCount, error) => null,
);

/// Provider detail post (tetap membaca cache dari postListProvider terlebih dahulu)
final postDetailProvider =
    FutureProvider.autoDispose.family<Post, int>((ref, id) async {
  final listState = ref.watch(postListProvider);

  if (listState.hasValue && listState.value != null) {
    final cachedPost =
        listState.value!.where((post) => post.id == id).firstOrNull;
    if (cachedPost != null) {
      return cachedPost;
    }
  }

  final repository = ref.watch(postRepositoryProvider);
  return repository.fetchPostById(id);
});

Future<List<Post>> readPostsOnce(ProviderContainer container) {
  final completer = Completer<List<Post>>();
  final sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      next.whenData(completer.complete);
      if (next.hasError) {
        completer.completeError(
          next.error ?? StateError('unknown error'),
          next.stackTrace ?? StackTrace.empty,
        );
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

Future<Object?> readPostsErrorOnce(ProviderContainer container) {
  final completer = Completer<Object?>();
  final sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      completer.complete(next.error);
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}