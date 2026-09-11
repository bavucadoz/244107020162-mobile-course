## ToDo & Product Management App (Flutter Riverpod & GoRouter)

Aplikasi mobile berbasis Flutter yang dikembangkan sebagai bagian dari mini project manajemen state menggunakan **Flutter Riverpod** dan navigasi deklaratif **GoRouter**.

## Fitur Utama
1. **Manajemen Daftar Tugas (ToDo List)**: Menambah tugas baru, menandai selesai (dengan efek coret), menghapus tugas, serta memfilter status tugas (Semua, Belum Selesai, Selesai).
2. **Navigasi Multi-Halaman**: Menggunakan `GoRouter` dan `ShellRoute` dengan `NavigationBar` interaktif untuk beralih antara halaman **Daftar Tugas** (`/`) dan **Statistik** (`/stats`).
3. **Simulasi Asinkron (`AsyncValue`)**: Halaman produk terintegrasi dengan penanganan state asinkron (`loading`, `error`, dan `data`) secara reaktif.
4. **State Management**: Memanfaatkan `StateNotifier` dan *Derived Providers* (`filteredTodosProvider`) untuk reaktivitas UI yang optimal.

## Stack Teknologi
* **Framework**: Flutter (Dart)
* **State Management**: `flutter_riverpod`
* **Navigasi**: `go_router`
* **Testing**: `flutter_test`

## Cara Menjalankan
1. Clone repository ini ke komputer Anda.
2. Buka terminal pada folder proyek (`03-week-3-navigation-state-management/week3_todo`).
3. Jalankan perintah untuk mengunduh dependencies:
   ```bash
   flutter pub get
   flutter run
   flutter test

---
## Penggunaan AI
[Link Penggunaan AI](https://share.gemini.google/XZrwMJFjrBrq)
Saya sempat mengalami kendala akibat kebijakan keamanan di sistem operasi yang memblokir eksekusi process starter bawaan Dart SDK

## AI Verification Checklist
[Hasil AI](../screenshots/ai-result.png)

- [✓] Apakah state diubah secara immutable (tidak ada `state.add()` atau mutasi list langsung)?
    = Ya, state diubah secara immutable melalui re-assignment state = ... dan instansiasi list baru (tidak ada state.add()).
- [✓] Apakah `ref.watch` hanya dipakai di dalam `build`, dan `ref.read` di *callback*?
    = Ya, ref.watch hanya dipakai di method build() untuk merender UI, sedangkan ref.read diisolasikan pada callback onPressed.
- [✓] Apakah ketiga state `AsyncValue` benar-benar ditangani (bukan hanya *success*)?
    = Ya, ditangani 3 kondisi utama secara eksplisit menggunakan .when() (loading, error, dan data).
- [✓] Apakah provider dideklarasikan dengan tipe eksplisit dan tidak duplikat dengan provider lain?
    = Ya, statsProvider dideklarasikan dengan tipe eksplisit AsyncNotifierProvider dan memiliki nama yang unik sehingga tidak bentrok dengan provider lain.
- [✓] Apakah kode AI memakai API Riverpod versi lama (`StateProvider` antipattern, `StateNotifierProvider` usang, atau `Consumer` bertingkat yang tidak perlu)? Perbaiki ke pola Notifier/ConsumerWidget.
    = Kode sudah menggunakan AsyncNotifier dan ConsumerWidget standar Riverpod 2.x+. Tidak ada penggunaan antipattern kuno seperti StateNotifierProvider usang atau Consumer bertingkat yang berlebihan.
- [X] Jalankan `flutter analyze` dan `flutter test`, apakah hasil AI lolos tanpa *warning*?
    = Ya, sekarang semuanya lolos tanpa ada masalah sama sekali
    [Screenshot AI Analyze](../screenshots/ai-flutter-analyze.png)
    [Screenshot AI Test](../screenshots/ai-flutter-test.png)

---
## Checklist verifikasi mandiri
[Refactoring Page Daftar](../screenshots/mandiri-pindah-hal1.png)
[Refactoring Page Statistik](../screenshots/mandiri-pindah-hal2.png)

- [✓] Navigasi `GoRouter` bekerja: pindah halaman, back, dan akses path detail langsung.
- [✓] `ProviderScope` membungkus root aplikasi; state ToDo bertahan saat berpindah halaman.
- [✓] UI `AsyncValue` menangani loading, error, dan success, bukan hanya success.
- [✓] flutter test dan analyze tanpa issue dan semua test lulus.
    [Hasil Flutter Test dan Analyze](../screenshots/mandiri-flutter.png)

---
## Refleksi
1. Kapan `setState` masih cukup, dan kapan state harus naik ke `Riverpod`?
    = `setState` cukup untuk mengelola state lokal yang hanya berdampak pada satu widget tunggal dan tidak perlu dibagikan ke komponen lain. Sate harus naik ke `Riverpod` bila, state harus dibagikan ke banyak widget, dikonsumsi lintas halaman, atau mengelola data asinkron yang membutuhkan caching dan reaktivitas tinggi.
2. Apa perbedaan `context.go` dan `context.push`, dan kapan masing-masing tepat digunakan?
    = `context.go` digunakan untuk mengganti rute aktif secara total pada navigation stack, sedangkan `context.push` menumpuk rute baru di atas halaman saat ini dengan mempertahankan tombol back. `context.go` tepat digunakan untuk navigasi tingkat atas seperti menu Bottom Navigation Bar (/ dan /stats), sedangkan `context.push` tepat digunakan untuk navigasi hierarkis seperti halaman detail, form input, atau sub-menu.
3. Bagaimana `AsyncValue` mencegah bug dibanding tiga boolean terpisah?
    = Dengan cara mmerangkum status tersebut ke dalam struktur eksklusif berbasis sealed class, sehingga state loading, error, dan data saling mengunci dan memaksa developer menangani seluruh skenario secara aman melalui metode .when().
4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?
    = Pada bagian Logika Manipulasi State, yaitu dengan mengganti penggunaan .sublist pada TodoListNotifier yang sangat rentan error Index Out of Bounds dengan pendekatan list comprehension (for loop) agar lebih aman, bersih, dan kebal dari nilai index yang tidak valid.