# AI Review: Prompt dan Output Awal

Tanggal: 29 Oktober 2026
Alat: Claude
Bahan: diff PR validasi judul + refactor DI (docs/ai-review-input.diff),
get_notes.dart, validate_note.dart, validate_note_test.dart

## Prompt

```
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

## Output awal AI (tidak diedit)

### 1. [BLOCKER] `NoteRepositoryImpl.save` melempar `UnimplementedError`, padahal dipanggil `SaveNote`

**Alasan:** Jalur sukses (judul valid) berakhir di `throw UnimplementedError()`. Validasi menolak judul kosong dengan benar, tetapi menyimpan catatan yang sah justru crash. Test tetap hijau karena `validate_note_test.dart` hanya menguji fungsi murni, tidak pernah menyentuh repository.

**Usulan:**

```dart
@override
Future<void> save(Note note) async {
  final db = await _openDb();
  await db.insert(
    'notes',
    NoteModel(
      title: note.title.trim(),
      body: note.body,
      updatedAt: DateTime.now(),
      dirty: true,
    ).toMap(),
  );
}
```

Ini selalu menambah baris baru. Kalau `save` juga harus meng-update catatan yang sudah ada, perlu cabang `update` berdasarkan `note.id`.

### 2. [BLOCKER, perlu diverifikasi] Validasi belum terpasang ke alur UI

**Alasan:** Judul PR berbunyi "validasi di use case + pesan error di UI", tetapi diff tidak memuat provider untuk `SaveNote` dan tidak ada perubahan di halaman. Kalau form catatan masih memanggil `addNote` langsung, pengguna tetap bisa menyimpan catatan tanpa judul dan `SaveNote` adalah kode mati. `addNote` di data layer juga tidak memeriksa judul sama sekali.

**Usulan:**

```dart
final saveNoteProvider = Provider<SaveNote>(
  (ref) => SaveNote(ref.watch(noteRepositoryProvider)),
);
```

```dart
try {
  await ref.read(saveNoteProvider)(note);
  if (context.mounted) context.pop();
} on NoteValidationException catch (e) {
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.message)));
  }
}
```

### 3. [BLOCKER] Use case `SaveNote` tidak punya test

**Alasan:** Jobsheet meminta kasus sukses dan gagal. Test yang ada hanya menguji `validateNoteTitle`. Perilaku yang sebenarnya penting, yaitu judul kosong tidak sampai ke `repository.save` dan judul valid memanggilnya, tidak diuji. Itu sebabnya bug Temuan 1 lolos. `FakeNoteRepository.save` di `get_notes_test.dart` juga masih `throw UnimplementedError()`, jadi fake itu tidak bisa dipakai untuk menguji `SaveNote` tanpa di-subclass.

**Usulan:**

```dart
class _RecordingRepo extends FakeNoteRepository {
  final saved = <Note>[];
  @override
  Future<void> save(Note note) async => saved.add(note);
}

void main() {
  Note note(String title) => Note(
        id: 0, title: title, body: '',
        updatedAt: DateTime(2026), dirty: true,
      );

  test('judul kosong: melempar dan repository tidak dipanggil', () async {
    final repo = _RecordingRepo();
    await expectLater(
      SaveNote(repo)(note('  ')),
      throwsA(isA<NoteValidationException>()),
    );
    expect(repo.saved, isEmpty);
  });

  test('judul valid: repository.save dipanggil sekali', () async {
    final repo = _RecordingRepo();
    await SaveNote(repo)(note('Belanja'));
    expect(repo.saved, hasLength(1));
  });
}
```

### 4. [SARAN] Interface `NoteRepository.save` punya badan kosong (no-op diam-diam)

**Alasan:** `Future<void> save(Note note) async {}` di kelas abstrak membuat method konkret yang tidak melakukan apa-apa. Implementasi yang memakai `extends` atau `with` dan lupa meng-override akan diam-diam tidak menyimpan, tanpa error compile maupun runtime. Kontrak domain seharusnya abstrak.

**Usulan:**

```dart
Future<void> save(Note note);
```

### 5. [SARAN] Gaya error tidak konsisten: use case melempar exception, repository mengembalikan `Failure`

**Alasan:** Semua method lain di `NoteRepository` melaporkan error lewat record `(..., failure)` atau `Future<Failure?>` (`deleteNote`, `markAllSynced`). `SaveNote` memakai `throw NoteValidationException`, sehingga pemanggil harus menangani dua mekanisme berbeda.

**Usulan:**

```dart
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

Future<Failure?> call(Note note) async {
  final error = validateNoteTitle(note.title);
  if (error != null) return ValidationFailure(error);
  return _repository.save(note);
}
```

### Bukan temuan (menurut AI)
- `validateNoteTitle` sudah benar untuk null, string kosong, spasi, tab, dan newline.
- Perakitan repository di `main.dart` memenuhi aturan dependency.
- Catatan kecil: `PostRepositoryImpl` kini memakai `createDio()`, sehingga override `dioProvider` di test tidak berpengaruh ke repository posts.