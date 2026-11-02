class AppFormat {
  /// output: "27 Sep 2026, 14:30"
  static String dateToString(DateTime date) {
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');

    // Konversi angka bulan ke nama bulan sederhana
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final month = months[localDate.month - 1];
    final year = localDate.year;

    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  // ontoh fungsi murni parsing rute manual
  static int? extractIdFromRoute(String route) {
    final parts = route.split('/');
    if (parts.length > 2 && parts[1] == 'note') {
      return int.tryParse(parts[2]);
    }
    return null;
  }
}
