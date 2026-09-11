import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Sesuaikan import path dengan nama project kamu di pubspec.yaml
import 'package:week3_todo/pages/ai_stats_page.dart';

void main() {
  group('StatsNotifier Unit Test', () {
    test('State awal harus dalam kondisi loading lalu berpindah ke Data/Error', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Memastikan state awal saat pertama kali dibaca adalah AsyncLoading
      final initialState = container.read(statsProvider);
      expect(initialState, isA<AsyncLoading<List<StatItem>>>());

      // Menunggu hingga Future pembentukan data selesai
      try {
        final result = await container.read(statsProvider.future);
        expect(result.length, 3);
        expect(result[0].title, 'Total Pengguna');
      } catch (e) {
        // Menangani jika terjadi exception dari simulasi error 30%
        expect(e, isA<Exception>());
      }
    });

    test('Fungsi retry() harus memperbarui state AsyncValue', () async {
      final container = ProviderContainer();

      // 1. Tunggu inisialisasi awal notifier selesai dulu
      try {
        await container.read(statsProvider.future);
      } catch (_) {}

      // 2. Panggil fungsi retry()
      final notifier = container.read(statsProvider.notifier);
      final futureRetry = notifier.retry();

      // 3. Cek apakah state berubah menjadi AsyncLoading saat retry berjalan
      expect(container.read(statsProvider), isA<AsyncLoading<List<StatItem>>>());

      // 4. Tunggu proses retry selesai sepenuhnya sebelum container di-dispose
      try {
        await futureRetry;
      } catch (_) {}

      // 5. Pastikan state akhir bernilai AsyncData atau AsyncError
      final stateAfterRetry = container.read(statsProvider);
      expect(
        stateAfterRetry.hasValue || stateAfterRetry.hasError,
        isTrue,
      );

      // Dispose container secara manual di akhir setelah semua Future selesai
      container.dispose();
    });
  });
}