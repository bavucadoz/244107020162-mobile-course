# 02 | Declarative UI & Responsive Design
--
# Praktikum: Layout Sederhana (Warm-Up)
[0](screenshots/0-warmup.png)
Eksperimen Warm Up :
    1. Hapus Expanded pada baris nama, lalu amati peringatan overflow atau perilaku layout-nya; kembalikan setelah itu.
       [1](screenshots/1-warmup.png)
    2. Ganti mainAxisSize: MainAxisSize.min menjadi nilai default dan amati perubahan tinggi kartu.
       [2](screenshots/2-warmup.png)
    3. Tambahkan satu baris data (misal Email) menggunakan pola Row + Expanded yang sama.
       [3](screenshots/3-warmup.png)
       
--
# Praktikum: Dashboard Responsif
Eksperimen Layout :
    1. Ubah breakpoint dari 700 menjadi nilai lain dan amati perubahan jumlah kolom.
       [1](screenshots/1-layout.png)
    2. Ubah themeMode menjadi ThemeMode.dark, lalu kembalikan ke ThemeMode.system.
       [2](screenshots/2-layout.png)
    3. Uji aplikasi dengan ukuran layar emulator yang berbeda.
       [3](screenshots/3-layout.png)
    4. Tambahkan Semantics atau label yang bermakna pada elemen yang penting bagi screen reader.
       [4](screenshots/4-layout.png)
       
--
# Tugas Utama
Mengembangkan dashboard menjadi halaman Academic Overview dengan ketentuan seperti di jobsheet
[Assigment](screenshots/tugasutama-sempit.png)
[Assigment](screenshots/tugasutama-lebar.png)

-------------------
# AI Prompt Challenge
Menggunakan AI hanya untuk membandingkan dua alternatif tata letak
    1. Prompt desain. "Bandingkan dua tata letak dashboard akademik untuk Flutter: versi GridView dan versi LayoutBuilder + Column. Jelaskan trade-off responsif dan aksesibilitasnya."
       = Output penting AI:
        GridView:
            GridView cocok untuk dashboard yang memiliki beberapa kartu informasi dengan ukuran yang relatif seragam. Grid dapat mengatur beberapa item dalam baris dan memudahkan pembuatan layout dua kolom atau lebih.
             Kelebihannya:
                -Mudah digunakan untuk banyak kartu informasi.
                -Cocok untuk dashboard.
                -Dapat digunakan bersama LayoutBuilder untuk membuat jumlah kolom responsif.
                -Mendukung scrolling ketika jumlah kartu bertambah.
             Kekurangannya:
                -Urutan visual kartu perlu diperhatikan agar tetap mudah dipahami oleh pembaca layar.
                -Pengaturan ukuran kartu seperti childAspectRatio dapat membuat isi kartu terlalu sempit pada ukuran tertentu.
        LayoutBuilder + Column:
            LayoutBuilder + Column memberikan kontrol yang lebih besar terhadap struktur layout. Komponen dapat disusun secara berbeda berdasarkan ukuran layar.
             Kelebihannya:
                -Struktur layout lebih fleksibel.
                -Mudah membuat susunan yang berbeda untuk layar sempit dan lebar.
                -Cocok jika setiap bagian dashboard memiliki ukuran atau struktur yang berbeda.
             Kekurangannya:
                -Kode dapat menjadi lebih panjang.
                -Untuk banyak kartu yang seragam, implementasinya lebih rumit dibandingkan GridView.
                -Perlu perhatian terhadap overflow jika banyak widget ditempatkan dalam Column.

    2. Prompt penguatan konsep. "Jelaskan kapan penggunaan Expanded justru menyebabkan overflow di dalam Row, beri contoh kode yang gagal dan perbaikannya.
       = Expanded bekerja dengan mengambil ruang yang tersedia di Row. Masalah dapat muncul ketika child lain memiliki ukuran yang tidak fleksibel dan total kebutuhan ruangnya melebihi constraint. Contoh yang bermasalah:
[ai](screenshots/contoh-bermasalah.png)
       Jika lebar parent kurang dari kebutuhan minimum kedua child, layout dapat mengalami overflow. Perbaikannya adalah memastikan child yang membutuhkan ruang fleksibel juga dapat menyusut, misalnya dengan Flexible, atau membatasi ukuran konten: 
[ai](screenshots/membatasi-konten.png)
       Pada kode dashboard, penggunaan Expanded(child: Text(title)) di dalam DashboardCard tepat karena nilai di sebelah kanan membutuhkan ruang tersendiri dan judul dapat mengambil sisa ruang.

    3. Verification prompt. Minta AI mengaudit hasilnya sendiri: "Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak tersedia di Flutter stabil saat ini?"
       = Hasil verifikasi terhadap kode:
        1. Di bawah 600 px
             LayoutBuilder menggunakan: final columns = constraints.maxWidth >= 700 ? 2 : 1;
             sehingga layar sempit menggunakan 1 kolom. Ini membantu menghindari kartu menjadi terlalu sempit.
        2. Aksesibilitas
             Penggunaan Semantics pada judul halaman, switch tema, profil, dan dashboard card merupakan keputusan yang baik. excludeSemantics: true pada DashboardCard juga membuat screen reader membaca informasi kartu sebagai satu unit.
        3. Flutter stable
             Widget yang digunakan seperti MaterialApp, Scaffold, AppBar, GridView, LayoutBuilder, Semantics, CupertinoSwitch, Expanded, dan CircleAvatar merupakan widget Flutter standar.
        4. Potensi masalah yang ditemukan
             ProfileCard mempunyai: width: 320,Pada grid satu kolom, ukuran ini masih bisa menjadi masalah jika lebar layar sangat kecil karena padding GridView juga mengambil ruang. Lebih aman menghapus width: 320 dan membiarkan grid menentukan lebar kartu.
        Selain itu, Colors.indigo.shade50 tidak otomatis mengikuti dark theme dengan baik. Warna kartu profil sebaiknya menggunakan warna dari ColorScheme agar tetap terbaca dalam mode gelap.

    4. Keputusan.
       = Setelah membandingkan alternatif yang diberikan AI, keputusan yang digunakan pada implementasi adalah dengan menggunakan GridView + LayoutBuilder.
        Alasannya diantaranya:
        1. Dashboard terdiri dari beberapa kartu informasi.
        2. Kartu memiliki struktur yang relatif sederhana.
        3. GridView lebih mudah digunakan untuk membuat kumpulan kartu.
        4. LayoutBuilder memungkinkan jumlah kolom menyesuaikan ukuran layar.
        5. Implementasinya masih sederhana sehingga mudah dijelaskan saat code review.
        6. Semantics tetap digunakan untuk mendukung aksesibilitas.
        Untuk tahap ini kode belum dilakukan refactoring menjadi widget reusable atau konstanta breakpoint karena bagian tersebut merupakan tugas Refactoring Challenge berikutnya.

-------------------
# Refactoring Challange
Merapikan Kode Program setelah tugas
    1. Ekstrak kartu informasi menjadi widget reusable (misal InfoCard) yang menerima title dan value, sehingga tidak ada duplikasi widget.
       [1](screenshots/infocard.png)
    2. Ganti warna dan ukuran yang di-hardcode dengan Theme.of(context) agar mengikuti tema terang/gelap secara otomatis.
       [2](screenshots/themeofcontent.png)
    3. Pindahkan breakpoint ke satu konstanta bernama (misal const kWideBreakpoint = 700;) agar hanya didefinisikan satu kali.
       [3](screenshots/kWideBreakpoint-1.png)
       [3](screenshots/kWideBreakpoint-2.png)
    4. Jalankan flutter analyze dan pastikan tidak ada error maupun warning baru.
       [4](screenshots/flutter-analyze.png)

--
# Testing Dasar
Jalankan dengan flutter test.
[testing](screenshots/flutter-test.png)

--
# Checklist
Checklist Verifikasi
    [✓] flutter analyze tidak menghasilkan error.
        [checklist](screenshots/flutter-analyze.png)
    [✓] flutter test lulus semua widget test responsif.
        [checklist](screenshots/flutter-test.png)
    [✓] Aplikasi dapat dijalankan pada ukuran layar sempit dan lebar
        [checklist](screenshots/tugasutama-sempit.png)
        [checklist](screenshots/tugasutama-lebar.png)
    [✓] Dark mode memiliki kontras dan teks yang terbaca
        [checklist](screenshots/darkmode.png)
    [✓] Struktur widget dapat dijelaskan saat code review.
    [✓] Screenshot, folder test/, dan README sudah tersimpan pada folder tugas Week 2.

--
# Refleksi
    - Apa perbedaan cara berpikir imperative dan declarative saat membangun UI?
        = Imperative lebih berfokus pada langkah-langkah yang harus dilakukan untuk membuat atau mengubah tampilan UI. Sedangkan declarative lebih berfokus pada hasil tampilan yang diinginkan berdasarkan kondisi tertentu.
    - Kapan Expanded membantu dan kapan penggunaannya justru menghasilkan layout error?
        = Expanded membantu ketika kita ingin membagi ruang yang tersedia di dalam Row atau Column secara fleksibel. Contohnya pada bagian profile, Expanded digunakan agar nama mahasiswa dapat menggunakan sisa ruang yang tersedia. Namun, jika digunakan pada parent yang ukurannya terbatas atau pada kondisi yang tidak menyediakan ruang yang sesuai, penggunaannya dapat menyebabkan error seperti RenderFlex overflow.
    - Bagaimana breakpoint dan theme memengaruhi pengalaman pengguna?
        = Breakpoint membuat tampilan aplikasi dapat menyesuaikan ukuran layar. Pada layar sempit dashboard ditampilkan dalam satu kolom, sedangkan pada layar lebar menggunakan dua kolom sehingga lebih nyaman dilihat. Theme juga memengaruhi kenyamanan pengguna dengan menyediakan mode terang dan gelap yang dapat dipilih sesuai kondisi atau preferensi penggunanya.
    - Apa yang Anda verifikasi dari rekomendasi AI setelah tugas inti selesai?
        = Saya memverifikasi rekomendasi AI dengan menjalankan aplikasi secara langsung dan melihat hasil tampilan pada ukuran layar yang berbeda. Saya juga menjalankan flutter test untuk memastikan responsive layout dan widget yang digunakan sesuai dengan ketentuan tugas. Dengan demikian, rekomendasi AI tidak langsung diterapkan tanpa pengecekan, tetapi tetap disesuaikan dan diuji kembali.
