# 05 | Local Storage & Offline First

---
## Tampilan
> ![Tampilan](screenshots/tampilan.png)

---
## AI Verification Checklist

- [✓] Apakah AI menempatkan daftar catatan di SharedPreferences? (menolak: rapuh untuk koleksi).
    = Tidak. AI menolak penggunaan SharedPreferences untuk menyimpan daftar catatan dan hanya merekomendasikannya untuk preferensi tema tunggal (dark_mode), karena SharedPreferences sangat rapuh dan lambat untuk data koleksi/terstruktur.
- [✓] Apakah skema AI mendukung antrean sync (dirty flag / updated_at) atau hanya CRUD polos?
    = Ya. Skema AI mendukung antrean sync offline-first dengan menyediakan kolom dirty (penanda status sinkronisasi ke server) dan updated_at (timestamp untuk resolusi konflik Last-Write-Wins).
- [✓] Apakah klaim "real-time" AI didukung stream (Drift/watch) atau hanya asumsi?
    = Ya. Klaim reaktivitas terbukti secara teknis melalui mekanisme Stream terintegrasi (.watch() pada Drift/Hive) serta state invalidation reaktif (ref.invalidate()) pada Riverpod + sqflite.
- [✓] Apakah estimasi boilerplate AI masuk akal setelah Anda mencoba instalasinya (`flutter pub add` + migrasi skema)?
    = Ya. SharedPreferences memiliki boilerplate paling minim, sqflite di tingkat menengah, sedangkan Drift/Hive memiliki boilerplate paling tinggi karena membutuhkan instalasi build_runner dan code generation
- Keputusan final Anda beserta alasannya, boleh berbeda dari rekomendasi AI selama berargumen.
    = Saya lebih memilih SharedPreferences untuk preferensi tema karena ringan dan tidak perlu konfigurasi database, dan sqflite untuk pengelolaan catatan karena memberikan pemahaman query SQL langsung serta bebas dari kompleksitas code untuk praktikum, dan siap diintegrasikan dengan Riverpod.
    
---
## Checklist Verifikasi Mandiri

- [✓] UI tidak memanggil SQLite/SharedPreferences langsung; semua lewat repository + provider.
- [✓] Aplikasi penuh berfungsi dalam mode pesawat: baca, tambah, hapus catatan.
- [✓X] Badge dirty akurat sebelum/sesudah sync; cache posts tampil tanpa internet. [cache posts tidak tertampil :( ]
- [✓] flutter analyze tanpa issue dan semua test lulus.
    > ![flutter](screenshots/flutter-test-analyze)
- [✓] Hasil AI diverifikasi dan didokumentasikan pada folder docs/. [docs](/05-week-5-local-storage-offline-first/docs/AI_Challenge.md)

---
## Refleksi

---