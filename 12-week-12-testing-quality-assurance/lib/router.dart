import 'package:go_router/go_router.dart';
import 'package:campus_notify/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:campus_notify/features/notes/presentation/pages/note_detail_page.dart';
import 'package:campus_notify/features/notes/presentation/pages/note_page.dart';
import 'package:campus_notify/features/settings/presentation/pages/settings_pages.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const NotesPage()),
    GoRoute(
      path: '/ai-chat',
      builder: (context, state) => const AiChatPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        final id = int.tryParse(idStr ?? '') ?? 0;
        return NoteDetailPage(noteId: id);
      },
    ),
  ],
);
