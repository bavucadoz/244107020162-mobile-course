import '../../domain/entities/note.dart';
import '../../../../core/failures.dart';

abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  });

  Future<({Note? note, Failure? failure})> fetchNoteById(int id);
  Future<({int count, Failure? failure})> countDirty();
  Future<Failure?> markAllSynced();
  Future<Failure?> deleteNote(int id);

  Future<void> save(Note note) async {}
}
