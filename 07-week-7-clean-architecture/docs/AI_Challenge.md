# AI Prompt Challenge

---
## Prompt
Ada sedikit perubahan prompt karena saya menggunakan Praktikum dari minggu ke-5

`AI PROMPT CHALLENGE`
Tugas:
1. Usulkan struktur feature-first Clean Architecture
(presentation/domain/data) untuk fitur notes + posts.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan. 

---
## 1. Struktur Target Feature-First Clean Architecture

Struktur ini memisahkan setiap fitur ke dalam *module* mandiri. Keuntungan utamanya: jika Anda menghapus fitur `posts`, Anda hanya perlu menghapus satu folder tanpa menyentuh fitur `notes`.

```
lib/
├── core/                        # Infrastruktur & utilitas lintas fitur
│   ├── network/
│   │   └── api_client.dart
│   ├── local/
│   │   ├── db.dart
│   │   └── prefs.dart
│   ├── sync/
│   │   └── sync_manager.dart
│   └── failures.dart            # Domain error handling
├── features/
│   ├── notes/                   # FITUR NOTES
│   │   ├── domain/
│   │   │   ├── entities/note.dart
│   │   │   ├── repositories/note_repository.dart (Interface)
│   │   │   └── usecases/get_notes.dart (Opsional untuk CRUD)
│   │   ├── data/
│   │   │   ├── models/note_model.dart
│   │   │   └── repositories/note_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/notes_providers.dart
│   │       ├── pages/note_page.dart
│   │       ├── pages/note_detail_page.dart
│   │       └── widgets/note_tile.dart
│   ├── posts/                   # FITUR POSTS
│   │   ├── domain/
│   │   │   ├── entities/post.dart
│   │   │   └── repositories/post_repository.dart (Interface)
│   │   ├── data/
│   │   │   ├── models/post_model.dart
│   │   │   └── repositories/post_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/posts_providers.dart
│   │       └── pages/posts_page.dart
│   └── settings/                # FITUR SETTINGS
│       └── presentation/
│           ├── providers/settings_providers.dart
│           └── pages/settings_pages.dart
├── router.dart
└── main.dart
```

---
## 2. Peta Migrasi File Lama ke Struktur Baru

Tabel berikut merangkum transisi file dari arsitektur *legacy* (berbasis layer/jenis file) ke arsitektur *Feature-First*:

| File Lama | Tindakan & Tujuan Baru | Alasan |
| :--- | :--- | :--- |
| `data/local/db.dart` | **Pindah** ke `core/local/db.dart` | Database adalah infrastruktur umum yang memuat tabel lintas fitur. |
| `data/local/note.dart` | **Pecah** ke `notes/domain/entities/note.dart` & `notes/data/models/note_model.dart` | Memisahkan entitas murni (domain) dari logika pemetaan JSON/SQL (data). |
| `data/local/post.dart` | **Pecah** ke `posts/domain/entities/...` & `posts/data/models/...` | Sama seperti catatan, dipisah ke modul fiturnya sendiri. |
| `data/repositories/api_client.dart` | **Pindah** ke `core/network/api_client.dart` | Klien HTTP (Dio) adalah infrastruktur dasar, bukan repository spesifik fitur. |
| `data/repositories/note_repository.dart` | **Pecah** menjadi Interface (`domain/...`) dan Implementasi (`data/...`) | Menerapkan *Dependency Inversion* agar UI tidak bergantung pada SQL/API secara langsung. |
| `data/repositories/post_repository.dart` | **Pecah** menjadi Interface dan Implementasi di fitur `posts` | Memisahkan kontrak dan logika akses data spesifik Post. |
| `prefs.dart` & `sync.dart` | **Pindah** ke `core/local/prefs.dart` & `core/sync/sync_manager.dart` | Keduanya adalah layanan sistem yang sifatnya lintas fitur. |
| `pages/...` & `widgets/...` | **Pindah** ke `presentation/pages/` dan `presentation/widgets/` masing-masing fitur | Memisahkan UI berdasarkan modul fitur (notes vs posts vs settings). |
| `providers.dart` | **Hapus & Pecah** ke `.../presentation/providers/` masing-masing fitur | Menghindari file "God class" yang menampung *state* seluruh aplikasi secara global. |

---

## 3. Pragmatisme Clean Architecture: Menghindari Over-Engineering

Menerapkan Clean Architecture secara kaku (*by-the-book*) terkadang menghasilkan *boilerplate* (kode berulang) yang tidak perlu, terutama pada aplikasi sederhana.

**Tanda Over-Engineering pada CRUD Sederhana:**
Jika sebuah operasi hanya sekadar membaca data dari SQLite dan menampilkannya di UI tanpa modifikasi apa pun, membuat file *Use Case* (misal: `GetNotes`) yang isinya murni hanya `return repository.fetchNotes()` adalah bentuk *over-engineering*.

**Kapan Repository Boleh Langsung Dipanggil dari UI (Provider)?**
Untuk operasi CRUD dasar (*Create, Read, Update, Delete*) yang sifatnya pemindahan data murni (*pass-through*), *State Management* (UI Provider) dapat langsung memanggil fungsi di layer `Repository`. Lapisan *Use Case* dapat dilewati (*skipped*) untuk efisiensi kode.

**Kapan Use Case Benar-Benar Dibutuhkan?**
*Use Case* wajib dibuat jika terdapat **aturan bisnis kompleks** atau manipulasi data yang melibatkan lebih dari satu sumber. Contoh:
1. **SyncNotesUseCase:** Harus membaca dari database lokal (`NoteRepository`), mengirimnya ke API (`ApiClient`), menangani konflik jaringan, lalu memperbarui database lokal lagi.
2. **Validasi Bisnis Ekstra:** Mencegah pembuatan catatan jika pengguna sudah mencapai batas maksimal paket gratis (membutuhkan pengecekan status *user* dan hitungan *database* sekaligus sebelum disimpan).

---

## 4. Wiring Dependency Injection (DI) dengan Riverpod

Proyek ini sengaja tidak menggunakan *package* DI eksternal (seperti `get_it` atau `injectable`). **Riverpod** digunakan secara ganda sebagai **State Manager** sekaligus **Service Locator / DI Container**.

### Contoh Implementasi Wiring
```
// 1. Layer Core / Infrastruktur (Menyediakan koneksi DB)
final databaseProvider = FutureProvider<Database>((ref) async {
  return openNotesDb(); 
});

// 2. Layer Data (Menginjeksi DB ke Repository Implementasi)
// Tipe kembalian Provider dideklarasikan sebagai Interface (NoteRepository)
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  // Dalam realita, pastikan DB sudah di-init sebelumnya (handle async)
  return NoteRepositoryImpl(openDb: openNotesDb);
});

// 3. Layer Domain / Use Case (Opsional, menyuntikkan Repository Interface)
final getNotesUseCaseProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

// 4. Layer Presentation / UI (Konsumen Akhir)
final notesStateProvider = FutureProvider<List<Note>>((ref) async {
  // UI hanya memanggil Use Case (atau langsung Repository untuk CRUD sederhana)
  final result = await ref.watch(getNotesUseCaseProvider).call();
  
  // Menangani domain Failure sebelum dikirim ke UI
  if (result.failure != null) throw Exception(result.failure!.message);
  
  return result.notes;
});
```

---