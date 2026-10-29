import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/core/local/db.dart';
import 'package:week5_offline_notes/core/network/api_client.dart';
import 'package:week5_offline_notes/features/notes/data/repositories/note_repository_impl.dart';
import 'package:week5_offline_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:week5_offline_notes/features/posts/data/repositories/post_repository_impl.dart';
import 'package:week5_offline_notes/features/posts/presentation/providers/posts_providers.dart';
import 'package:week5_offline_notes/features/settings/presentation/providers/settings_providers.dart';

import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
  ProviderScope(
    overrides: [
      noteRepositoryProvider.overrideWithValue(
        NoteRepositoryImpl(openDb: openNotesDb),
      ),
      postRepositoryProvider.overrideWithValue(
        PostRepositoryImpl(apiClient: createDio(), openDb: openNotesDb),
      ),
    ],
    child: const MyApp(),
  ),
);
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final isDarkMode = darkModeAsync.value ?? false;

    return MaterialApp.router(
      title: 'Offline Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
