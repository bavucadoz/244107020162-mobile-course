## AI Verification Checklist

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
    Terdapat masalah, bukan karena kode Flutter/Dart saya yang salah, melainkan karena kebijakan keamanan di sistem operasi yang memblokir eksekusi process starter bawaan Dart SDK.