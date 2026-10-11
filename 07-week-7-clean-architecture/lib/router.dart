import 'package:go_router/go_router.dart';
import 'pages/note_page.dart';
import 'pages/note_detail_page.dart';
import 'pages/settings_pages.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const NotesPage(),
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