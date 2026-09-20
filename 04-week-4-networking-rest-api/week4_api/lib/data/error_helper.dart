import 'package:dio/dio.dart';

// Mengonversi Object error menjadi pesan string yang mudah dipahami pengguna
String getErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      // Menangani kasus timeout (koneksi, kirim, atau terima data)
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat. Waktu tunggu telah habis (Timeout).';

      // Menangani koneksi terputus/tidak ada internet
      case DioExceptionType.connectionError:
        return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';

      // Menangani HTTP Status Code (404, 500, dll)
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Data komentar tidak ditemukan (404).';
        } else if (statusCode == 500) {
          return 'Terjadi masalah internal pada server (500). Coba lagi nanti.';
        }
        return 'Terjadi kesalahan pada server (Status: $statusCode).';

      case DioExceptionType.cancel:
        return 'Permintaan data dibatalkan.';

      default:
        return 'Terjadi kesalahan jaringan yang tidak terduga.';
    }
  }
  return 'Terjadi kesalahan: ${error.toString()}';
}