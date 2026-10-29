# AI Log — Praktikum 1–3 dan AI Challenge

---

## Konteks proyek

- Proyek: `week5_offline_notes` (Flutter, dari arsip `lib.zip`).
- Struktur relevan: `lib/features/notes/{domain,presentation,data}`.
- Entitas: `Note` dengan properti `title`, `body`, `updatedAt`, dan `dirty`.
- Kontrak repository: `NoteRepository.fetchNotes()` mengembalikan record berisi `List<Note>` dan `Failure?`.
- State UI: Riverpod `FutureProvider<List<Note>>` bernama `notesProvider`.
- Batasan: jangan mengubah arsitektur repository/database; pencarian hanya berdasarkan judul; jangan menaruh query SQLite atau Dio di widget; jangan menaruh import Flutter/Dio/SQLite di domain.
- Catatan: arsip yang diberikan hanya berisi folder `lib/`, tidak menyertakan `pubspec.yaml`, konfigurasi proyek, atau test existing. Karena itu perintah Flutter harus dijalankan dari proyek asli setelah file hasil praktikum disalin.

---

## Praktikum 1 — Formula prompt 5 slot

```yaml
Peran: Senior Flutter developer dan reviewer.
Konteks: Aplikasi week5_offline_notes, feature-first; Flutter + Riverpod,
  repository NoteRepository, entitas Note. Domain berada di
  lib/features/notes/domain dan UI notes di presentation.
Tugas: Tambahkan pencarian berdasarkan judul catatan, case-insensitive,
  abaikan spasi di awal/akhir query, dan tampilkan empty state saat tidak ada hasil.
Batas: Jangan mengubah skema SQLite, kontrak repository, sinkronisasi,
  routing, atau arsitektur. Filter harus berupa fungsi domain murni.
Output: Kode ringkas, unit test sukses/gagal, widget test empty state,
  instruksi uji manual, dan catatan temuan yang diverifikasi.
```
---

## Praktikum 2 — Prompt mentah

```yaml
Peran: Senior Flutter developer.
Konteks: Feature-first, Riverpod. UI membaca notesProvider; domain memakai
  entitas Note; repository diakses melalui abstraksi NoteRepository.
Tugas: Tambahkan search judul notes dengan empty state.
Batas: Jangan panggil database dari widget; jangan ubah kontrak repository;
  pencarian tidak boleh mengubah urutan catatan yang sudah diterima.
Output: Use case domain murni, integrasi UI, unit test sukses dan gagal,
  widget test empty state, dan langkah verifikasi.
```

### Output awal AI (ringkasan)

1. Membuat `filterNotesByTitle()` di domain untuk memfilter judul dengan `contains`, `trim`, dan `toLowerCase`.
2. Menambahkan input pencarian pada halaman catatan.
3. Menampilkan pesan berbeda ketika belum ada catatan dan ketika query tidak memiliki hasil.
4. Menambahkan unit test untuk pencarian case-insensitive, hasil kosong, dan query kosong.
5. Menambahkan widget test untuk empty state.

Implementasi akhir yang diserahkan berada di:
- `lib/features/notes/domain/usecases/search_notes.dart`
- `lib/features/notes/presentation/pages/note_page.dart`
- `lib/features/notes/presentation/widgets/notes_empty_state.dart`
- `test/search_filter_test.dart`
- `test/notes_empty_state_test.dart`

---

## Praktikum 3 — Debug, refactor, dan verifikasi

### Temuan yang dibuktikan dari kode sumber

**Temuan:** `NoteRepositoryImpl.save()` belum diimplementasikan dan melempar `UnimplementedError`.

**Bukti grep:**
```bash
grep -R -n -E 'TODO: implement save|UnimplementedError' lib/features/notes
```

Bukti dari arsip: metode `save(Note note)` pada `lib/features/notes/data/repositories/note_repository_impl.dart` berisi `// TODO: implement save` dan `throw UnimplementedError();`. Ini temuan nyata pada kode yang diberikan, tetapi **tidak diperbaiki dalam perubahan search**, karena implementasi penyimpanan bukan bagian dari lingkup fitur ini dan memerlukan keputusan apakah metode tersebut perlu mendukung insert atau update.

### Refactor yang dilakukan
- Aturan pencarian dipindahkan ke fungsi murni `filterNotesByTitle()` di layer domain.
- UI hanya menyimpan query, memanggil fungsi filter, dan menampilkan hasil.
- Empty state dipisah ke widget kecil agar bisa diuji secara terisolasi.
- Fungsi filter tidak mengimpor Flutter, Dio, maupun SQLite.

### Perintah verifikasi 

```bash
flutter test test/search_filter_test.dart
flutter test test/notes_empty_state_test.dart
flutter analyze
dart format --set-exit-if-changed .
flutter test
```
---

## AI Challenge — Review dan keputusan

| Usulan/temuan | Keputusan | Alasan teknis / bukti |
|---|---|---|
| Pindahkan filter dari widget ke domain use case/fungsi murni | Terima | Mudah diuji tanpa widget/database; domain tidak memiliki import Flutter atau SQLite. |
| Tambahkan pengurutan alfabet saat mencari | Tolak | Tidak diminta dan akan mengubah urutan yang sebelumnya mengikuti `updated_at DESC` dari repository. |
| `save()` pada repository belum diimplementasikan | Terima sebagai temuan, tidak diperbaiki pada fitur ini | Terbukti dengan grep dan `UnimplementedError`; di luar lingkup search sehingga tidak diubah diam-diam. |

---

## Uji manual

1. Jalankan aplikasi dan buka halaman Catatan Offline.
2. Query kosong: semua catatan terlihat; jika database kosong, tampil `Belum ada catatan.`
3. Query cocok seperti `belanja`: judul yang mengandung kata itu ditampilkan tanpa membedakan kapitalisasi.
4. Query tidak cocok seperti `zzz-tak-ada`: tampil `Tidak ada catatan untuk "zzz-tak-ada".`
5. Tekan ikon hapus pada kolom pencarian untuk mengosongkan query.

---

## Refleksi

- **Apa satu halusinasi AI yang Anda temukan dan bagaimana membuktikannya?**  
  = Saya menemukan bahwa AI dapat menghasilkan kode yang menggunakan method atau API yang belum tentu tersedia pada struktur proyek yang digunakan. Untuk membuktikannya, saya memeriksa nama method dan import pada kode yang dihasilkan menggunakan pencarian teks (`grep`) serta menjalankan unit test. Jika method tidak ditemukan atau test gagal karena pemanggilan method yang tidak sesuai, berarti saran AI tersebut perlu diperbaiki sebelum digunakan.

- **Prompt mana yang paling membantu dan apa yang Anda ubah?**  
  = Prompt dengan formula lima slot, yaitu Peran, Konteks, Tugas, Batas, dan Output, merupakan prompt yang paling membantu. Saya memperjelas konteks dengan menyebutkan struktur arsitektur aplikasi, penggunaan Flutter dan Riverpod, serta kebutuhan fitur pencarian judul notes. Saya juga menambahkan batasan agar logika pencarian tidak diletakkan langsung di widget dan meminta AI menyertakan empty state serta test case. Dengan demikian, kode yang dihasilkan lebih terarah dan mudah diverifikasi.

- **Satu refactor apa yang Anda lakukan pada kode AI?**  
  = Saya memindahkan logika pencarian dan filter judul notes dari widget ke fungsi murni pada layer domain, yaitu `search_notes.dart`. Refactor ini bertujuan memisahkan tanggung jawab antara tampilan dan logika bisnis sehingga widget hanya menangani input pengguna dan menampilkan hasil pencarian. Fungsi pencarian juga menjadi lebih mudah diuji secara terpisah tanpa memerlukan akses ke database SQLite atau komponen Flutter.

- **Keputusan terima/tolak mana yang paling sulit?**  
  = Keputusan yang paling sulit adalah menentukan apakah struktur kode yang dihasilkan AI sudah sesuai dengan arsitektur proyek atau masih perlu diperbaiki. Saya menerima saran pemisahan logika pencarian ke fungsi domain karena membuat kode lebih modular dan mudah diuji. Namun, saya menolak saran yang berpotensi menambahkan dependensi yang tidak diperlukan atau mengubah struktur arsitektur yang sudah ada. Keputusan tersebut harus didasarkan pada pemeriksaan kode, hasil test, dan `flutter analyze`, bukan hanya karena AI menyatakan bahwa implementasinya sudah benar.

---
