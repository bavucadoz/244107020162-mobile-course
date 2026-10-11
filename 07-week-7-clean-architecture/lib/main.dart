// ignore_for_file: unnecessary_underscores, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart'; 

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
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final loggedIn = authState.value ?? false;
      final goingLogin = state.matchedLocation == AppRoutes.login;

      if (!loggedIn && !goingLogin) return AppRoutes.login;
      if (loggedIn && goingLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
      GoRoute(
        path: AppRoutes.announcementDetail,
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