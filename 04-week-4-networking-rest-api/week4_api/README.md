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