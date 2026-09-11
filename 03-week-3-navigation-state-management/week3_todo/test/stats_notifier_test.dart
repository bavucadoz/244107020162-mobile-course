import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/pages/stats_page.dart';
void main() {
  group('StatsNotifier Unit Test', () {
    test('State awal harus dalam kondisi loading lalu berpindah ke Data/Error', () async {
      // 1. Membuat ProviderContainer untuk mengisolasi state Riverpod saat pengujian
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 2. Membaca provider pertama kali (seharusnya mengembalikan state awal)
      final initialState = container.read(statsProvider);
      
      // Memastikan kondisi awal adalah AsyncLoading
      expect(initialState, isA<AsyncLoading<List<StatItem>>>());

      // 3. Menunggu proses asinkron (_fetchStats dengan delay 2 detik) selesai
      // container.read(statsProvider.future) menunggu hingga Future selesai
      try {
        final result = await container.read(statsProvider.future);
        
        // Jika berhasil (70% peluang), pastikan item berjumlah 3
        expect(result.length, 3);
        expect(result[0].title, 'Total Pengguna');
      } catch (e) {
        // Jika gagal (30% peluang), pastikan exception tertangkap sesuai logika
        expect(e, isA<Exception>());
      }
    });

    test('Fungsi retry() harus memperbarui state AsyncValue', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Tunggu inisialisasi awal selesai
      try {
        await container.read(statsProvider.future);
      } catch (_) {}

      // Panggil fungsi retry() pada notifier
      final notifier = container.read(statsProvider.notifier);
      final futureRetry = notifier.retry();

      // Saat retry dipanggil, state harus berubah kembali menjadi AsyncLoading
      expect(container.read(statsProvider), isA<AsyncLoading<List<StatItem>>>());

      // Selesaikan Future dari retry
      await futureRetry;

      // Setelah retry selesai, pastikan state bernilai AsyncData atau AsyncError
      final stateAfterRetry = container.read(statsProvider);
      expect(
        stateAfterRetry.hasValue || stateAfterRetry.hasError,
        isTrue,
      );
    });
  });
}