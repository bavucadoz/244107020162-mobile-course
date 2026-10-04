import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../messaging/push_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool? _permissionGranted;
  String? _maskedToken;
  String _status = 'Menginisialisasi FCM...';

  @override
  void initState() {
    super.initState();
    // Minta izin + inisialisasi FCM setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    // 1. Minta Izin
    try {
      final granted = await requestNotificationPermission();
      if (mounted) setState(() => _permissionGranted = granted);
    } catch (e) {
      if (mounted) setState(() => _status = 'Gagal izin notifikasi: $e');
    }

    // 2. Ambil Token FCM
    try {
      await initFcmToken(onToken: _handleToken);
    } catch (e) {
      if (mounted) setState(() => _status = 'Gagal ambil token: $e');
    }

    // 3. Setup Listener Navigasi (Untuk Praktikum 3)
    void goRoute(String route) {
      if (mounted) context.push(route);
    }
    
    listenForeground(goRoute);
    await handleTerminated(goRoute);
  }

  Future<void> _handleToken(String token) async {
    // TODO: Kirim token ke API Backend menggunakan Dio (Praktikum 1/2)
    // await ref.read(apiClientProvider).post('/devices', data: {'fcm_token': token});

    if (!mounted) return;
    setState(() {
      _maskedToken = _mask(token);
      _status = 'Token diterima & Listener aktif.';
    });
  }

  static String _mask(String token) =>
      token.length < 12 ? '***...' : '${token.substring(0, 12)}...';

  String get _permissionLabel {
    if (_permissionGranted == null) return 'Belum diminta';
    return _permissionGranted! ? 'Diizinkan' : 'Ditolak';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kampus'),
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
          const Text(
            'Selamat Datang!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // ---- BUKTI PRAKTIKUM 2 (Pengganti DebugPage) ----
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🛠️️ Info Debug FCM', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  Text('Izin Notifikasi: $_permissionLabel'),
                  const SizedBox(height: 8),
                  Text(
                    'Token FCM: ${_maskedToken ?? "Memuat..."}',
                    style: const TextStyle(fontFamily: 'monospace', color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 8),
                  Text('Status: $_status'),
                ],
              ),
            ),
          ),
          // --------------------------------------------------

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/pengumuman/3'),
            icon: const Icon(Icons.campaign),
            label: const Text('Simulasi Buka Pengumuman 3'),
          ),
        ],
      ),
    );
  }
}