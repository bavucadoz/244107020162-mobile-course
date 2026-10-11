// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:campus_notify/routes.dart';

// Inisialisasi plugin local notifications secara global
final _local = FlutterLocalNotificationsPlugin();

/// Payload notifikasi yang diklik saat app di foreground atau background lokal.
/// Sifatnya sekali baca (consume from router, lalu kosongkan).
String? pendingDeepLink;

/// 1. Minta izin notifikasi runtime (wajib di Android 13+ dan iOS).
/// Mengembalikan true jika izin authorized atau provisional.
Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

/// 2. Siapkan local notifications (untuk menampilkan banner manual saat app foreground).
Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  
  await _local.initialize(
    // Menggunakan named parameter 'settings:' sesuai breaking changes versi terbaru
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Klik banner foreground -> simpan payload untuk diteruskan ke router.
      pendingDeepLink = response.payload;
    },
  );
}

/// 3. Token Lifecycle: Ambil token, kirim ke backend, dan pantau perubahan token.
Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  // A. Ambil token saat ini dan kirim ke backend / server kampus.
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await onToken(token);
  }

  // B. Pantau perubahan token (reinstall, clear data, rotasi keamanan).
  // Listener ini WAJIB ada agar server tidak menyimpan token basi.
  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);

  // C. Langganan topik kampus (broadcast massal untuk mahasiswa).
  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}

/// 4. Handler Tiga App State & Navigasi Payload (Foreground, Background, Terminated)
/// Tangani notifikasi Foreground
void listenForeground(void Function(String route) go) {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    // Menggunakan fungsi murni untuk ekstraksi route
    final String route = routeFromMessage(message.data);
    
    const androidDetails = AndroidNotificationDetails(
      'pengumuman_kampus_channel', 
      'Pengumuman Kampus',
      importance: Importance.high, 
      priority: Priority.high,
    );
    
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman Kampus',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final String route = routeFromMessage(message.data);
    go(route);
  });
}

/// Tangani Terminated State
Future<void> handleTerminated(void Function(String route) go) async {
  final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  
  if (initialMessage != null) {
    final String route = routeFromMessage(initialMessage.data);
    go(route);
  } else if (pendingDeepLink != null) {
    go(pendingDeepLink!);
    pendingDeepLink = null;
  }
}

/// Berhenti berlangganan topik jika diperlukan
Future<void> unsubscribeTopic() async {
  await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
}

// ============================================================================
// 6. BACKGROUND HANDLER (Wajib Top-Level & Dianotasi)
// ============================================================================
// - Tidak boleh mengakses BuildContext / State UI karena berjalan di isolate terpisah.
// ============================================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Tugas di sini hanya untuk pemrosesan ringan / logging data di latar belakang.
  print("Background message diterima di isolate terpisah: ${message.messageId}");
}

String routeFromMessage(Map<String, dynamic>? data) {
  if (data == null) return AppRoutes.home;

  // Ambil nilai rute dari payload data 
  final String? route = data['route']?.toString();
  
  if (route != null && route.isNotEmpty) {
    return route;
  }

  return AppRoutes.home;
}