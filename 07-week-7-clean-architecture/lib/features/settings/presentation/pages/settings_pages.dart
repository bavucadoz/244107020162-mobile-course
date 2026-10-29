import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import file provider yang baru saja dipisah
import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau state dari masing-masing provider
    final darkModeAsync = ref.watch(darkModeProvider);
    final isForceOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode Gelap'),
            subtitle: const Text('Simpan preferensi ke SharedPreferences'),
            value: darkModeAsync.value ?? false,
            onChanged: darkModeAsync.isLoading
                ? null
                : (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          const Divider(),
          // Tambahkan toggle ini agar forceOfflineProvider berfungsi
          SwitchListTile(
            title: const Text('Paksa Mode Offline'),
            subtitle: const Text('Hanya gunakan data dari cache SQLite lokal'),
            value: isForceOffline,
            onChanged: (value) {
              // Ubah state Riverpod secara instan
              ref.read(forceOfflineProvider.notifier).state = value;
            },
          ),
        ],
      ),
    );
  }
}
