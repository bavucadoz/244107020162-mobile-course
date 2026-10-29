import 'package:flutter/material.dart';

class NotesEmptyState extends StatelessWidget {
  const NotesEmptyState({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final isSearching = query.trim().isNotEmpty;
    return Center(
      child: Text(
        isSearching
            ? 'Tidak ada catatan untuk "$query".'
            : 'Belum ada catatan.',
        key: const Key('notes-empty-state'),
        textAlign: TextAlign.center,
      ),
    );
  }
}
