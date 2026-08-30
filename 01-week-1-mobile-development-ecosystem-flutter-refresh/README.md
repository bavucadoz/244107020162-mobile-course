#01 | Mobile Development Ecosystem & Flutter Refresh
--
Praktikum: Aplikasi Flutter Pertama
    1. Membuat dan menjalankan proyek
       [1](screenshots/1-membuat-dan-menjalankan-proyek.png)
       [1](screenshots/1-tampilan-aplikasi-contoh.png)
    2. Mengubah UI default
       [2](screenshots/2-mengubah-ui.png)
       
--
Checklist Verifikasi
    [✓] flutter doctor tidak memiliki masalah yang menghambat target Android.
        [checklist](screenshots/flutter-doctor.png)
    [✓] flutter devices mendeteksi emulator/perangkat fisik.
        [checklist](screenshots/flutter-devices.png)
    [✓] Aplikasi berjalan dan UI default telah diganti dengan profil sederhana.
        = Aplikasi berhasil berjalan sesuai dengan praktikum yang dijalankan.
    [✓] Anda dapat menjelaskan perbedaan hot reload dan hot restart
        = Perbedaan hot reload dan hot restart adalah, hot reload menerapkan perubahan kode ke aplikasi tanpa mengulang seluruh aplikasi, sehingga state yang sedang berjalan tetap dipertahankan. Sedangkan, hot restart menjalankan ulang aplikasi dari awal sehingga state aplikasinya di-reset.
    [✓] Repository remote berisi source code, README, screenshot, dan riwayat commit.

--
Mini Assigment
Membuat aplikasi Profil Mahasiswa berdasarkan praktikum. Tambahkan NIM dan satu informasi tambahan menggunakan widget dasar.
[Assigment](screenshots/profil-mahasiswa.png)

--
Kendala Set Up
[kendala](screenshots/kendala-1.png)
    Salah satu kendala set up yang saya alami adalah ketika hasil flutter doctor menunjukkan Android Sdk belum ditemukan karena saya meletakkan Android Sdk di lokasi costum, sehingga Android toolchain tidak dapat digunakan. Oleh karena itu saya mengikuti perintah yang tertampilkan untuk mengarahkan Flutter ke lokasi SDK dengan perintah flutter config --android-sdk "D:\Android\Sdk".
[kendala](screenshots/kendala-2.png)
    Setelah itu, saya jalankan kembali flutter doctor. Hasilnya kini menunjukkan warning pada Android toolchain karena lisensi Android yang statusnya tidak diketahui. SDK versi terbaru sudah tidak lagi menggunakan mekanisme lama --android-licenses, melainkan otomatis dikelola lewat Android CLI. Selama Android SDK sudah terpasang lengkap dan environment variable sudah benar, Flutter tetap bisa build dan menjalankan aplikasi Android secara normal juga. (Untuk, Visual Studio/VSCode saya letakkan di path berbeda dengan Android).

--
Refleksi
    - Kapan native lebih tepat dipilih daripada cross-platform?
        = Native lebih tepat dipilih daripada cross-platform apabila aplikasinya membutuhkan performa tinggi & grafis berat, membutuhkan integrasi mendalam dengan fitur spesifik perangkat, serta menggunakan fitur baru OS sejak hari pertama.
    - Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?
        = Perubahan state menyebabkan Flutter membangun ulang bagian widget tree yang terdampak sehingga UI otomatis menyesuaikan dengan state terbaru. Hal ini sesuai dengan konsep UI deklaratif, yaitu developer cukup menentukan seperti apa tampilan berdasarkan kondisi atau state saat ini, tanpa mengatur perubahan UI secara manual.
    - Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portfolio?
        = Karena, commit kecil dengan pesan yang jelas memudahkan anggota tim memahami perubahan, melacak riwayat pekerjaan, serta menemukan dan memperbaiki masalah jika terjadi, dan didalam portfolio biasanya riwayat commit yang rapi juga menunjukkan bahwa developer memiliki kebiasaan kerja yang terstruktur, komunikatif, dan profesional.
