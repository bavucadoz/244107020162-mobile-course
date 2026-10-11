// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../providers/auth_provider.dart';
import '../messaging/push_service.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool? _permissionGranted;
  String? _maskedToken;
  String _status = 'Menginisialisasi FCM...';
  final FlutterLocalNotificationsPlugin _localTest = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    // 1. Minta Izin Notifikasi
    try {
      final granted = await requestNotificationPermission();
      if (mounted) setState(() => _permissionGranted = granted);
    } catch (e) {
      if (mounted) setState(() => _status = 'Gagal izin: $e');
    }

    // 2. Ambil Token FCM
    try {
      await initFcmToken(onToken: _handleToken);
    } catch (e) {
      if (mounted) setState(() => _status = 'Gagal ambil token: $e');
    }

    // 3. Setup Listener Navigasi untuk Foreground & Background
    void goRoute(String route) {
      if (mounted) context.push(route);
    }
    
    listenForeground(goRoute);
    await handleTerminated(goRoute);
  }

  Future<void> _handleToken(String token) async {
    if (!mounted) return;
    setState(() {
      _maskedToken = _mask(token);
      _status = 'Token aktif & terdaftar ke topik.';
    });
  }

  static String _mask(String token) =>
      token.length < 12 ? '***...' : '${token.substring(0, 12)}...';

  String get _permissionLabel {
    if (_permissionGranted == null) return 'Belum diminta';
    return _permissionGranted! ? 'Diizinkan' : 'Ditolak';
  }

  // =========================================================================
  // FUNGSI SIMULASI PENGUJIAN LOKAL KETIGA APP STATE
  // =========================================================================
  
  // 1. Simulasi Foreground Notification (Muncul Banner Lokal)
  Future<void> _simulateForegroundTest() async {
    const androidDetails = AndroidNotificationDetails(
      'pengumuman_kampus_channel',
      'Pengumuman Kampus',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _localTest.show(
      id: 999,
      title: '[UJI FOREGROUND] Jadwal Kuliah Berubah',
      body: 'Kelas Mobile dipindah ke Ruang A2 jam 13.00',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: AppRoutes.announcement('3'), // Mengarah ke /pengumuman/3
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulasi Foreground terkirim! Klik banner di atas.')),
    );
  }

  // 2. Simulasi Background Test (Petunjuk Cara Uji)
  void _showBackgroundInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cara Uji State Background'),
        content: const Text(
          '1. Tekan tombol HOME di HP Anda (aplikasi masuk ke background/minimize).\n\n'
          '2. Buka Firebase Console > Messaging > New Campaign.\n\n'
          '3. Masukkan Title & Body, lalu isi Custom Data dengan:\n'
          '   • Key: route\n'
          '   • Value: /pengumuman/3\n\n'
          '4. Kirim pesan, lalu klik banner sistem yang muncul di HP Anda.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mengerti'))
        ],
      ),
    );
  }

  // 3. Simulasi Terminated Test (Petunjuk Cara Uji)
  void _showTerminatedInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cara Uji State Terminated'),
        content: const Text(
          '1. Tutup total (Swipe-close) aplikasi dari daftar Recent Apps.\n\n'
          '2. Kirim pesan uji coba dari Firebase Console dengan Custom Data:\n'
          '   • Key: route\n'
          '   • Value: /pengumuman/3\n\n'
          '3. Klik banner notifikasi yang masuk. Aplikasi akan melakukan cold-start dan langsung membuka halaman /pengumuman/3.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mengerti'))
        ],
      ),
    );
  }
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kampus & Uji FCM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Debug Token
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🛠 Status & Info Debug FCM', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  Text('Izin Notifikasi: $_permissionLabel'),
                  const SizedBox(height: 6),
                  Text(
                    'Token FCM: ${_maskedToken ?? "Memuat..."}',
                    style: const TextStyle(fontFamily: 'monospace', color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 6),
                  Text('Status: $_status', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Panel Pengujian Tiga App State',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Gunakan tombol di bawah untuk menguji respons rute aplikasi:',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Tombol Uji 1: Foreground
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100, foregroundColor: Colors.green.shade900),
            onPressed: _simulateForegroundTest,
            icon: const Icon(Icons.bolt),
            label: const Text('Uji State: 1. Foreground (Test Banner Lokal)'),
          ),
          const SizedBox(height: 10),

          // Tombol Uji 2: Background
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade100, foregroundColor: Colors.orange.shade900),
            onPressed: _showBackgroundInstructions,
            icon: const Icon(Icons.minimize),
            label: const Text('Panduan Uji: 2. Background State'),
          ),
          const SizedBox(height: 10),

          // Tombol Uji 3: Terminated
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red.shade900),
            onPressed: _showTerminatedInstructions,
            icon: const Icon(Icons.close),
            label: const Text('Panduan Uji: 3. Terminated State'),
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: () => context.push(AppRoutes.announcement('3')),
            child: const Text('Buka Manual Pengumuman'),
          ),
        ],
      ),
    );
  }
}