# AI Prompt Challenge
[LinkPenggunaanAI](https://share.gemini.google/rgtSpbje14Wa)

---
## Matriks Pengujian Push Notification (FCM)

| State Aplikasi | Perilaku yang Diharapkan | Cara Pengujian | Hasil Pengujian |
| :--- | :--- | :--- | :--- |
| **Foreground** | Banner lokal muncul di dalam aplikasi, saat diklik langsung masuk ke rute `/pengumuman/3`. | Buka aplikasi di layar utama, kirim pesan FCM dari Firebase Console dengan kustom data `route: /pengumuman/3`. Klik banner lokal yang muncul. | **Berhasil** (Pindah halaman ke Detail Pengumuman ID: 3) |
| **Background** | Banner sistem muncul di status bar HP, saat diklik aplikasi terbuka dan masuk ke rute yang benar. | Tekan tombol *Home* (minimize aplikasi), kirim pesan dari Firebase Console. Tarik panel notifikasi dan klik banner. | **Berhasil** (Aplikasi terbuka otomatis ke rute `/pengumuman/3`) |
| **Terminated** | Aplikasi terbuka dari kondisi mati total menuju rute yang benar via `getInitialMessage`. | *Swipe-close* (tutup paksa) aplikasi dari *recent apps*, kirim pesan dari Firebase Console. Klik banner sistem. | **Berhasil** (Aplikasi melakukan *cold start* dan langsung mengarah ke rute `/pengumuman/3`) |

---