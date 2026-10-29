import '../entities/note.dart';

/// Filters notes by title only, ignoring leading/trailing spaces and case.
List<Note> filterNotesByTitle(List<Note> notes, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return notes;

  return notes
      .where((note) => note.title.toLowerCase().contains(normalizedQuery))
      .toList(growable: false);
}
