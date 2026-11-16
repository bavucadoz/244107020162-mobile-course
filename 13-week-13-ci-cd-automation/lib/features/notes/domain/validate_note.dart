class NoteValidationException implements Exception {
  final String message;
  const NoteValidationException(this.message);
  @override
  String toString() => message;
}

/// Mengembalikan pesan error, atau null jika valid.
String? validateNoteTitle(String? title) {
  if (title == null || title.trim().isEmpty) {
    return 'Judul tidak boleh kosong';
  }
  return null;
}
