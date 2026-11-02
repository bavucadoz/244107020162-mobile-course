# AI Development Log — Week 10

---

## 1. Prompt inti yang digunakan

```yaml
Peran: Senior Flutter developer yang memahami Riverpod 3, Dio, secure storage, dan integrasi Gemini REST API.
Konteks: Proyek campus_notify memakai feature-first architecture, Riverpod 3.4.3, Dio 5.11.1, flutter_secure_storage 11.2.0, SQLite untuk notes, Firebase Messaging, dan GoRouter. Dependensi yang diperlukan untuk chat AI sudah tersedia.
Tugas: Tambahkan satu fitur CampusMate AI Chat ke aplikasi. Gunakan Gemini streamGenerateContent berbasis SSE, tampilkan respons bertahap, indikator loading, konfigurasi API key, dan fallback error.
Batas: Jangan menyimpan API key di source code/SharedPreferences; jangan mengirim isi SQLite, token FCM, atau data pribadi; jangan menambah dependency tanpa alasan; jangan mengubah fitur notes/posts/settings selain menambahkan entry point dan route; domain tidak boleh bergantung pada Flutter, Dio, atau SQLite.
Output: Struktur file, kode service/repository/provider/page, test parser + controller + widget, dokumentasi prompt dan risiko, serta instruksi verifikasi.
```
---

## 2. Output awal AI (rancangan sebelum implementasi)

1. Buat entity `ChatMessage` dengan role user/model.
2. Buat kontrak `AiChatRepository` pada domain.
3. Implementasikan `GeminiAiChatRepository` pada data menggunakan Dio dan `flutter_secure_storage`.
4. Simpan API key terenkripsi melalui secure storage dan kirim melalui header `x-goog-api-key`.
5. Gunakan endpoint `streamGenerateContent?alt=sse`; parsing setiap baris `data:` menjadi chunk teks.
6. Kelola state percakapan dengan Riverpod Notifier.
7. Buat halaman chat dengan banner privasi, input, bubble pesan, loading, retry, dan pengaturan API key.
8. Tambahkan route `/ai-chat` dan tombol AI pada halaman Catatan.
9. Buat unit test parser, controller, dan widget test.

---

## 3. System prompt dan user prompt

**System prompt yang diterapkan:**

```text
Kamu adalah CampusMate, asisten belajar dan produktivitas kampus yang ramah.
Jawab dalam Bahasa Indonesia dengan jelas, ringkas, dan terstruktur.
Bantu pengguna memahami materi, merangkum konsep, menyusun ide, dan mengelola produktivitas belajar.
Jangan mengarang jadwal, kebijakan, nilai, atau informasi resmi kampus yang tidak diberikan.
Jangan meminta atau mengungkap NIK, kata sandi, token, nomor telepon, alamat, maupun data pribadi.
Jika pertanyaan membutuhkan informasi resmi kampus yang tidak tersedia, arahkan pengguna untuk memeriksa kanal resmi kampus.
```

**Contoh user prompt:**

```text
Jelaskan perbedaan database relasional dan non-relasional dengan contoh sederhana untuk mahasiswa TI.
```

**Contoh output awal yang diharapkan (simulasi format):**

```text
Database relasional menyimpan data dalam tabel yang saling terhubung menggunakan relasi atau kunci, contohnya PostgreSQL dan MySQL. Database non-relasional menyimpan data dalam bentuk yang lebih fleksibel seperti dokumen atau key-value, contohnya MongoDB. Pilihannya bergantung pada struktur data dan kebutuhan aplikasi.
```

Catatan: output di atas merupakan contoh format jawaban, bukan hasil request live ke Gemini.

---

## 4. Tabel usulan AI dan keputusan implementasi

| Usulan | Keputusan | Alasan teknis / bukti |
|---|---|---|
| Menambah package `http` | Tolak | Proyek sudah memiliki Dio. Menggunakan Dio menghindari dependency HTTP duplikat. |
| Menyimpan API key dengan SharedPreferences | Tolak | SharedPreferences bukan secure secret storage. API key disimpan via `FlutterSecureStorage`. |
| Menempel API key pada query URL | Tolak | API key dikirim melalui header `x-goog-api-key`; URL tidak memuat key. |
| Menggunakan endpoint lama `gemini-pro:generateContent` | Tolak | Implementasi memakai endpoint streaming `streamGenerateContent` dan model `gemini-3.8-flash` sesuai dokumentasi Gemini yang dirujuk saat pengerjaan. |
| Mengirim isi Notes sebagai context otomatis | Tolak | Dapat mengirim catatan pribadi tanpa tindakan eksplisit pengguna. Request hanya berisi percakapan yang diketik di halaman AI. |
| Membuat layer repository dan Notifier terpisah | Terima | Memisahkan integrasi jaringan, kontrak domain, dan state UI agar dapat diuji menggunakan fake repository. |
| Menggunakan `LogInterceptor` dari Dio utama | Tolak | Menghindari pencatatan prompt/request body ke log debug. Fitur memakai Dio khusus tanpa request-body logger. |
| Memperbaiki import relatif `../features` pada router | Terima + refactor | Dari `lib/router.dart`, path tersebut mengarah ke luar folder `lib`. Diganti menjadi package import `package:campus_notify/features/...`. |

---

## 5. Bukti verifikasi yang disiapkan

Test otomatis dibuat pada:

- `test/features/ai_chat/gemini_response_parser_test.dart`
  - parsing text dari response Gemini;
  - chunk tanpa teks menghasilkan null;
  - payload error menjadi StateError.
- `test/features/ai_chat/ai_chat_controller_test.dart`
  - dua chunk streaming digabung menjadi satu respons;
  - pesan kosong tidak memanggil repository;
  - error repository menghasilkan pesan fallback.
- `test/features/ai_chat/ai_chat_page_test.dart`
  - welcome state dan peringatan privasi tampil;
  - pesan yang dikirim dan respons simulasi tampil pada UI.

---

## 6. Temuan teknis yang diperbaiki

- `lib/router.dart` pada sumber memakai import `../features/...`. Karena file router berada di `lib/`, import tersebut berpotensi menunjuk ke direktori di luar `lib`. Import diganti ke `package:campus_notify/features/...` dan route `/ai-chat` ditambahkan.
- API key tidak ditulis pada konstanta/source code dan tidak dikirim melalui query parameter.
- Provider AI menggunakan Dio khusus tanpa `LogInterceptor` agar isi prompt tidak ikut dicetak melalui logger aplikasi.

---