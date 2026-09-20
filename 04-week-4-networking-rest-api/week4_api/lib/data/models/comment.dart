class Comment {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  // Factory constructor fromJson dengan penanganan null-safety
  // Menggunakan operator '??' untuk memberikan nilai default jika field bernilai null atau hilang
  factory Comment.fromJson(Map<String, dynamic>? json) {
    return Comment(
      postId: json?['postId'] as int? ?? 0,
      id: json?['id'] as int? ?? 0,
      name: json?['name'] as String? ?? '',
      email: json?['email'] as String? ?? '',
      body: json?['body'] as String? ?? '',
    );
  }

  // Metode untuk mengonversi instance ke JSON jika dibutuhkan
  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'id': id,
      'name': name,
      'email': email,
      'body': body,
    };
  }
}