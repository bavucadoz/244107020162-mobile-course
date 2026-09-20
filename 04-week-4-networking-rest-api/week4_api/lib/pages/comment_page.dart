import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/comment_notifier.dart';
import '../data/error_helper.dart';

class CommentScreen extends ConsumerWidget {
  final int postId;

  const CommentScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentProvider(postId));

    return Scaffold(
      appBar: AppBar(title: Text('Comments for Post #$postId')),
      body: commentsAsync.when(
        data: (comments) {
          if (comments.isEmpty) {
            return const Center(child: Text('Tidak ada komentar.'));
          }
          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return ListTile(
                title: Text(comment.name),
                subtitle: Text(comment.body),
                trailing: Text(comment.email),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          // Menggunakan error helper untuk menampilkan pesan ramah pengguna
          final userFriendlyMessage = getErrorMessage(error);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    userFriendlyMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger refresh manual pada notifier
                      ref.read(commentProvider(postId));
                    },
                    child: const Text('Coba Lagi'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}