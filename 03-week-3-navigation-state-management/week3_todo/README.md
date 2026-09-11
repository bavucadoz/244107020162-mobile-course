## AI Verification Checklist
[ai](../screenshots/ai-result.png)

- [✓] Apakah state diubah secara immutable (tidak ada `state.add()` atau mutasi list langsung)?
    Ya, state diubah secara immutable melalui re-assignment state = ... dan instansiasi list baru (tidak ada state.add()).
- [✓] Apakah `ref.watch` hanya dipakai di dalam `build`, dan `ref.read` di *callback*?
    Ya, ref.watch hanya dipakai di method build() untuk merender UI, sedangkan ref.read diisolasikan pada callback onPressed.
- [✓] Apakah ketiga state `AsyncValue` benar-benar ditangani (bukan hanya *success*)?
    Ya, ditangani 3 kondisi utama secara eksplisit menggunakan .when() (loading, error, dan data).
- [✓] Apakah provider dideklarasikan dengan tipe eksplisit dan tidak duplikat dengan provider lain?
    Ya, statsProvider dideklarasikan dengan tipe eksplisit AsyncNotifierProvider dan memiliki nama yang unik sehingga tidak bentrok dengan provider lain.
- [✓] Apakah kode AI memakai API Riverpod versi lama (`StateProvider` antipattern, `StateNotifierProvider` usang, atau `Consumer` bertingkat yang tidak perlu)? Perbaiki ke pola Notifier/ConsumerWidget.
    Kode sudah menggunakan AsyncNotifier dan ConsumerWidget standar Riverpod 2.x+. Tidak ada penggunaan antipattern kuno seperti StateNotifierProvider usang atau Consumer bertingkat yang berlebihan.
- [X] Jalankan `flutter analyze` dan `flutter test`, apakah hasil AI lolos tanpa *warning*?
    Ya, sekarang semuanya lolos tanpa ada masalah sama sekali
    [ai](../screenshots/ai-flutter-analyze.png)
    [ai](../screenshots/ai-flutter-test.png)

---
## Checklist verifikasi mandiri
[mandiri](../screenshots/mandiri-pindah-hal1.png)
[mandiri](../screenshots/mandiri-pindah-hal2.png)

- [✓] Navigasi GoRouter bekerja: pindah halaman, back, dan akses path detail langsung.
- [✓] ProviderScope membungkus root aplikasi; state ToDo bertahan saat berpindah halaman.
- [✓] UI AsyncValue menangani loading, error, dan success, bukan hanya success.
- [✓] flutter test dan analyze tanpa issue dan semua test lulus.
    [mandiri](../screenshots/mandiri-flutter.png)