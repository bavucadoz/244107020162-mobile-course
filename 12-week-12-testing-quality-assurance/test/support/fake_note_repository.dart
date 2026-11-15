import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/domain/repositories/note_repository.dart';

/// Fake ini tidak menggunakan SQLite, jaringan, atau plugin perangkat.
class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({
    List<Note> initialNotes = const [],
    this.fetchError,
    this.addError,
    this.fetchByIdError,
    this.countDirtyError,
    this.deleteError,
  }) : _notes = List<Note>.of(initialNotes),
       _nextId = initialNotes.fold<int>(
         1,
         (next, note) => note.id != null && note.id! >= next
             ? note.id! + 1
             : next,
       );

  final List<Note> _notes;
  int _nextId;

  String? fetchError;
  String? addError;
  String? fetchByIdError;
  String? countDirtyError;
  String? deleteError;

  Note? lastSavedNote;
  int addCallCount = 0;
  int fetchCallCount = 0;
  int deleteCallCount = 0;

  List<Note> get notes => List<Note>.unmodifiable(_notes);

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    fetchCallCount++;
    final error = fetchError;
    if (error != null) {
      return (notes: const <Note>[], failure: LocalFailure(error));
    }
    return (notes: notes, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    addCallCount++;
    final error = addError;
    if (error != null) {
      return (note: null, failure: LocalFailure(error));
    }

    final note = Note(
      id: _nextId++,
      title: title,
      body: body,
      updatedAt: DateTime(2026, 11, 15),
      dirty: true,
    );
    _notes.add(note);
    return (note: note, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> fetchNoteById(int id) async {
    final error = fetchByIdError;
    if (error != null) {
      return (note: null, failure: LocalFailure(error));
    }

    for (final note in _notes) {
      if (note.id == id) return (note: note, failure: null);
    }
    return (note: null, failure: null);
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    final error = countDirtyError;
    if (error != null) {
      return (count: 0, failure: LocalFailure(error));
    }
    return (
      count: _notes.where((note) => note.dirty).length,
      failure: null,
    );
  }

  @override
  Future<Failure?> markAllSynced() async {
    for (var index = 0; index < _notes.length; index++) {
      final note = _notes[index];
      _notes[index] = Note(
        id: note.id,
        title: note.title,
        body: note.body,
        updatedAt: note.updatedAt,
        dirty: false,
      );
    }
    return null;
  }

  @override
  Future<Failure?> deleteNote(int id) async {
    deleteCallCount++;
    final error = deleteError;
    if (error != null) return LocalFailure(error);
    _notes.removeWhere((note) => note.id == id);
    return null;
  }

  @override
  Future<void> save(Note note) async {
    lastSavedNote = note;
    final index = _notes.indexWhere((item) => item.id == note.id);
    if (index == -1) {
      _notes.add(note);
    } else {
      _notes[index] = note;
    }
  }
}
