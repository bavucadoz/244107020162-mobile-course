import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'repositories/comment_repository.dart';

// Provider family otomatis menangani fetching data, error state, dan autoDispose
final commentProvider = FutureProvider.autoDispose.family<List<Comment>, int>((ref, postId) async {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.fetchComments(postId);
});