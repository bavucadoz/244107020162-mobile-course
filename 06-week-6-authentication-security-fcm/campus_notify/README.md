# 06 | Authentication, Security & FCM

---
## Tampilan


---
## AI Verification Checklist

- [✓] Apakah background handler berupa fungsi top-level dengan @pragma('vm:entry-point')? (tolak jika berupa method kelas).
    = Ya. Fungsi dideklarasikan di luar kelas (top-level) dengan anotasi tersebut agar dapat dijalankan oleh sistem pada isolate terpisah saat aplikasi tertutup.
- [✓] Apakah onTokenRefresh benar-benar mengirim token baru ke backend, bukan hanya dicetak ke log?
    = Ya. Listener onTokenRefresh memanggil fungsi asinkron yang mengeksekusi request HTTP (_dio.post) untuk memperbarui token di server.
- [✓] Apakah foreground memakai local notification manual? (tanpa ini banner tidak muncul saat aplikasi terbuka).
    = Ya. Menggunakan flutter_local_notifications karena FCM secara default tidak menampilkan system banner secara otomatis saat aplikasi dalam kondisi aktif.
- [✓] Apakah klik dari ketiga state (foreground/background/terminated) masuk ke rute yang benar? Buktikan dengan tabel pengujian.
    = Ya. Ditangani secara komprehensif melalui callback banner lokal, onMessageOpenedApp, dan getInitialMessage yang meneruskan payload ke router.
- [✓] Apakah token/secret tidak di-hardcode dan tidak di-log penuh? Perbaiki bila AI melanggarnya.
    = Ya. Kredensial dimuat secara dinamis via opsi aman, dan token FCM ditampilkan terpotong (masked) untuk mencegah kebocoran data sensitif.
- Keputusan final Anda beserta alasannya, boleh berbeda dari rekomendasi AI selama berargumen.
    = Sebagai keputusan final, saya memilih untuk menggunakan pendekatan fungsi modular terpusat (top-level functions) di dalam file push_service.dart. Keputusan ini diambil karena strukturnya paling sesuai dengan modul praktikum yang sedang saya pelajari, sehingga lebih mudah dipahami alurnya ketimbang langsung menggunakan arsitektur kelas yang terlalu kompleks.
    
---
## Checklist Verifikasi Mandiri

- [✓] UI tidak memanggil SQLite/SharedPreferences langsung; semua lewat repository + provider.
- [✓] Aplikasi penuh berfungsi dalam mode pesawat: baca, tambah, hapus catatan.
    > ![baca](screenshots/detail-catatan.png)
    > ![tambah](screenshots/tambah.png)
- [✓X] Badge dirty akurat sebelum/sesudah sync; cache posts tampil tanpa internet. [cache posts tidak tertampil :( ]
    > ![dirty](screenshots/belum-singkron.png)
    > ![sync](screenshots/singkron.png)
- [✓] flutter analyze tanpa issue dan semua test lulus.
    > ![flutter](screenshots/flutter-test-analyze.png)
- [✓] Hasil AI diverifikasi dan didokumentasikan pada folder docs/. [docs](/05-week-5-local-storage-offline-first/docs/AI_Challenge.md)

---
## Refleksi

- Mengapa daftar catatan tidak boleh disimpan di SharedPreferences? Apa yang rusak jika aturan ini dilanggar?
    = Karena SharedPreferences menggunakan berkas key-value tunggal (XML/plist) yang dibaca secara utuh ke dalam memori (RAM). Yang trejadi jika dilanggar adalah pembacaan file JSON raksasa akan memicu UI freezing/lag, konsumsi RAM membengkak, serta berisiko data korup.
- Kapan cache-first cukup, dan kapan Anda membutuhkan strategi lain (misalnya network-first untuk data harga real-time)?
    = cache-first cukup saat data yang jarang berubah atau ketika kecepatan respon UI adalah prioritas utama (misal: artikel, profil pengguna, atau catatan pribadi). Dibutuhkannya strategi lain saat digunakan untuk data kritis dan dinamis (misal: harga saham, sisa tiket, atau stok barang). Menampilkan data usang (stale data) pada skenario ini dapat menyebabkan transaksi finansial atau keputusan pengguna yang salah.
- Bagaimana dirty flag berubah menjadi antrean sync tanpa memblokir UI? Kapan antrean terpisah (tabel outbox) menjadi perlu?
    = Dirty flag berubah menjadi antrean sync saat membaca baris WHERE dirty = 1 dan mengunggahnya secara asynchronous di background thread, sehingga UI tetap responsif untuk interaksi pengguna. Tabel Outbox diperlukan saat operasi mutasi bersifat kompleks dan berurutan, membutuhkan pencatatan riwayat retry counter, atau memerlukan penyimpanan payload log terpisah saat urutan eksekusi sync sangat krusial.
- Bagian mana dari rekomendasi AI yang Anda tolak, dan mengapa?
    = Bagian yang saya tolak adalah rekomendasi penggunaan ORM Drift yang mewajibkan code generation. Karena, untuk praktikum/tugas ini, sudah disarankan sejak awal menggunakan sqflite. DI tambah lagi, sqflite jauh lebih efisien karena memberikan kontrol query langsung, waktu kompilasi yang lebih cepat tanpa ketergantungan generator, dan sudah memenuhi seluruh kriteria dirty flag serta pengujian Fake Repository.
---