class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String announcementDetail = '/pengumuman/:id';

  /// Helper untuk membangun rute dinamis pengumuman
  static String announcement(String id) => '/pengumuman/$id';
}