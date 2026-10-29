import 'package:week5_offline_notes/features/notes/domain/validate_note.dart';

import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNotes {
  const GetNotes(this._repository);
  final NoteRepository _repository;

  Future<({List<Note> notes, Failure? failure})> call() {
    return _repository.fetchNotes();
  }
}

class SaveNote {
  SaveNote(this._repository);
  final NoteRepository _repository;

  Future<void> call(Note note) async {
    final error = validateNoteTitle(note.title);
    if (error != null) throw NoteValidationException(error);
    await _repository.save(note);
  }
}