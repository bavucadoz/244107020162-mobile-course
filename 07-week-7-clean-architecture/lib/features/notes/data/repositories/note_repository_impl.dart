// ignore_for_file: prefer_initializing_formals

import 'package:sqflite/sqflite.dart';
import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({required Future<Database> Function() openDb})
      : _openDb = openDb;

  final Future<Database> Function() _openDb;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final db = await _openDb();
      final rows =
          await db.query('notes', orderBy: 'updated_at DESC');
      final notes =
          rows.map((r) => NoteModel.fromMap(r).toEntity()).toList();
      return (notes: notes, failure: null);
    } catch (e) {
      return (
        notes: const <Note>[],
        failure: LocalFailure('Gagal membaca catatan: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    try {
      final db = await _openDb();
      final now = DateTime.now();
      final id = await db.insert(
        'notes',
        NoteModel(
            title: title, body: body, updatedAt: now, dirty: true)
            .toMap(),
      );
      return (
        note: Note(id: id, title: title, body: body,
            updatedAt: now, dirty: true),
        failure: null,
      );
    } catch (e) {
      return (note: null,
          failure: LocalFailure('Gagal menyimpan catatan: $e'));
    }
  }

  @override
  Future<({Note? note, Failure? failure})> fetchNoteById(int id) async {
    try {
      final db = await _openDb();
      final rows = await db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (rows.isEmpty) {
        return (note: null, failure: null); // Kembalikan null jika data tidak ditemukan
      }
      
      final note = NoteModel.fromMap(rows.first).toEntity();
      return (note: note, failure: null);
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal mengambil detail catatan: $e'));
    }
  }

  // --- 3 METODE TAMBAHAN UNTUK MEMPERBAIKI ERROR ---

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    try {
      final db = await _openDb();
      final result = await db.rawQuery('SELECT COUNT(*) FROM notes WHERE dirty = 1');
      final count = Sqflite.firstIntValue(result) ?? 0;
      
      return (count: count, failure: null);
    } catch (e) {
      return (count: 0, failure: LocalFailure('Gagal menghitung catatan belum sinkron: $e'));
    }
  }

  @override
  Future<Failure?> markAllSynced() async {
    try {
      final db = await _openDb();
      await db.update(
        'notes',
        {'dirty': 0},
        where: 'dirty = ?',
        whereArgs: [1],
      );
      return null;
    } catch (e) {
      return LocalFailure('Gagal menandai sinkronisasi: $e');
    }
  }

  @override
  Future<Failure?> deleteNote(int id) async {
    try {
      final db = await _openDb();
      await db.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );
      return null;
    } catch (e) {
      return LocalFailure('Gagal menghapus catatan: $e');
    }
  }
}