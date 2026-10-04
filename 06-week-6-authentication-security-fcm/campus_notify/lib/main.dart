import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart'; 
import 'messaging/push_service.dart';
import 'providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/announcement_page.dart';

// Wajib Top-Level Function untuk Background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message diterima: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase SEBELUM runApp()
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Daftarkan background handler FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Siapkan local notifications (Praktikum 2 & 3)
  await initLocalNotifications();

  runApp(const ProviderScope(child: MyApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final loggedIn = authState.value ?? false;
      final goingLogin = state.matchedLocation == '/login';

      if (!loggedIn && !goingLogin) return '/login';
      if (loggedIn && goingLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/', builder: (_, __) => const HomePage()),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (_, state) => AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}