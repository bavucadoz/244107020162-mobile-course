## 04 | Networking & REST API

---
## Penggunaan AI
[Link Penggunaan AI](https://share.gemini.google/Yyw8O27W0Gom)

---
## AI Verification Checklist
[Hasil AI](../screenshots/ai-prompt-challenge.png)

- [✓] Apakah UI memanggil Dio secara langsung (dilarang) atau lewat repository?
    = Ya, UI terpisah sepenuhnya dari Dio. UI hanya berinteraksi melalui Provider.
- [✓] Apakah `fromJson` aman null, atau masih memakai cast langsung yang bisa crash?
    = Ya, `fromJson` aman dari null dan crash.
- [✓] Apakah semua tipe `DioExceptionType` (timeout, connectionError, badResponse) dipetakan ke pesan pengguna?
    = Ya. 
- [✓] Apakah `baseUrl`/timeout terpusat di satu client, bukan tersebar di tiap method?
    = Ya, `baseUrl`/timeout terpusat di dioProvider, tidak ditulis ulang di setiap method repository.
- [✓] Apakah test AI benar-benar menguji kasus field hilang, atau hanya happy path? Tambahkan minimal 1 edge case sendiri.
    = Test AI menguji kasus field null/hilang. `EdgeTest`: fromJson harus memberikan nilai fallback aman ketika field missing atau null. 
- [X] Jalankan `flutter analyze` dan `flutter test`, apakah hasil AI lolos tanpa warming?
    = Ya, sekarang semuanya lolos tanpa ada masalah sama sekali
    [Screenshot AI](../screenshots/ai-flutter.png)
    
---
## Checklist Verifikasi Mandiri

- [✓] UI tidak memanggil Dio langsung, semua akses data lewat repository + provider.
- [✓] Empat state tampil benar: loading, error (+ retry), empty, success.
- [✓?] Pagination: data bertambah saat scroll, tidak ada request ganda, ada indikator akhir data. (Data Load cukup lama)
- [✓] flutter analyze tanpa issue dan semua test lulus.

---
## Refleksi
- Mengapa UI dilarang memanggil Dio langsung? Apa yang rusak jika aturan ini dilanggar?
    = Karena hal ini melanggar prinsip Separation of Concerns. UI seharusnya hanya mengurus tampilan dan interaksi pengguna, bukan detail protokol HTTP, header, URL, atau serialisasi JSON. Jika dilanggar, Widget UI tidak bisa di-unit test secara terisolasi tanpa melakukan panggilan jaringan sungguhan atau konfigurasi mocking HTTP yang rumit.
- Kapan pagination client-side cukup, dan kapan harus mengandalkan pagination server (_page/_limit)?
    = Client-Side cukup jika jumlah data relatif kecil dan tetap. Kita bisa mengandalkan Server-Side (_page/_limit) jika Data berjumlah ribuan/berpotensi terus bertambah.
- Bagaimana exception repository berubah menjadi AsyncError tanpa try/catch di setiap widget? Kapan try/catch eksplisit tetap dibutuhkan?
    = Pada Riverpod, exception dari repository otomatis berubah menjadi AsyncError secara deklaratif karena metode build() pada AsyncNotifier atau FutureProvider membungkus proses asynchronous dan menangkap error yang dilempar dari repository. Dengan begitu, UI cukup membaca state secara responsif menggunakan .when(error: ...) tanpa perlu menulis blok try/catch di setiap widget. Meski demikian, try/catch eksplisit tetap dibutuhkan pada aksi imperatif pengguna—seperti saat menekan tombol submit, delete, atau update—agar aplikasi bisa menangani efek samping (side effect) lokal seperti menampilkan SnackBar, Toast, atau dialog peringatan tanpa mengubah seluruh tampilan layar menjadi state error.
- Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?
    = Perbaikan pada kode hasil AI berfokus pada pembetulan sintaks Riverpod 2.x, peningkatan null-safety, dan perapian struktur kode. Kelas yang tidak ada dalam package seperti AutoDisposeFamilyAsyncNotifier diganti dengan sintaks FamilyAsyncNotifier serta modifier .autoDispose.family agar variabel bawaan seperti ref, state, dan arg dapat terdeteksi oleh compiler. Proses konversi fromJson diperbaiki dari type casting langsung menjadi safe parsing dengan nilai fallback default untuk mencegah aplikasi crash saat menerima respons null dari API. Terakhir, komponen duplikat PostTile dipisahkan ke folder widgets/post_tile.dart, salah ketik CrossAlignment dibetulkan menjadi CrossAxisAlignment, serta import yang tidak terpakai dibersihkan sehingga flutter analyze berjalan bersih tanpa peringatan.
---

## Mini Project
[ss](../screenshots/project.png)
[ss](../screenshots/project-detail.png)
[ss](../screenshots/flutter-project.png)
[ss](../screenshots/flutter-test.png)
