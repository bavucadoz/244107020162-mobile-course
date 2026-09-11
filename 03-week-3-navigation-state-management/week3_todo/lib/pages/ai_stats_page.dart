import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- MODEL ---
// Model sederhana untuk menampung data statistik
class StatItem {
  final String title;
  final String value;

  const StatItem({required this.title, required this.value});
}

// --- NOTIFIER (LOGIC LAYER) ---
// AsyncNotifier mengelola state berupa Future/AsyncValue<List<StatItem>>
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  @override
  Future<List<StatItem>> build() async {
    // Memanggil fungsi fetch data saat provider pertama kali diinisialisasi
    return _fetchStats();
  }

  // Fungsi privat untuk simulasi pengambilan data dari server/database
  Future<List<StatItem>> _fetchStats() async {
    // 1. Simulasi delay jaringan selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // 2. Simulasi error acak dengan peluang kegagalan 30%
    final random = Random();
    if (random.nextDouble() < 0.3) {
      throw Exception('Gagal terhubung ke server statistik (Peluang 30%)');
    }

    // 3. Mengembalikan 3 item data jika berhasil
    return const [
      StatItem(title: 'Total Pengguna', value: '1,250'),
      StatItem(title: 'Penjualan Bulan Ini', value: 'Rp 45.000.000'),
      StatItem(title: 'Tingkat Konversi', value: '8.5%'),
    ];
  }

  // Fungsi untuk memuat ulang data secara manual
  Future<void> retry() async {
    // Mengubah state menjadi loading terlebih dahulu
    state = const AsyncValue.loading();
    // AsyncValue.guard secara otomatis menangkap error jika _fetchStats() gagal
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

// --- PROVIDER ---
// Mendaftarkan StatsNotifier agar dapat diakses oleh UI
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(StatsNotifier.new);

// --- UI LAYER ---
// ConsumerWidget digunakan agar widget dapat membaca/mendengar perubahan pada Riverpod Provider
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch mendengarkan statistik AsyncValue (Data / Loading / Error)
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Aplikasi'),
        centerTitle: true,
      ),
      // .when() digunakan untuk mendekonstruksi 3 kemungkinan kondisi AsyncValue
      body: statsAsync.when(
        // 1. KONDISI LOADING: Menampilkan indikator putar di tengah layar
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // 2. KONDISI ERROR: Menampilkan pesan kesalahan dan tombol Coba Lagi
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Terjadi Kesalahan:\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  // Menjalankan fungsi retry() pada Notifier saat tombol ditekan
                  onPressed: () => ref.read(statsProvider.notifier).retry(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),

        // 3. KONDISI SUCCESS: Menampilkan ListView berisi 3 item data statistik
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            final item = stats[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(item.title),
                subtitle: Text(
                  item.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}