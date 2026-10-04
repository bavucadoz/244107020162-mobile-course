import 'package:dio/dio.dart';

String handleApiError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi internet lambat atau habis waktu. Silakan coba lagi.';
      
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return 'Sesi habis atau tidak sah. Silakan masuk kembali.';
        } else if (statusCode == 403) {
          return 'Anda tidak memiliki akses ke halaman ini.';
        } else if (statusCode == 404) {
          return 'Data atau server tidak ditemukan.';
        } else if (statusCode != null && statusCode >= 500) {
          return 'Terjadi gangguan pada server kampus. Coba beberapa saat lagi.';
        }
        return 'Terjadi kesalahan pada server (Kode: $statusCode).';
        
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
        
      default:
        return 'Terjadi kesalahan jaringan yang tidak diketahui.';
    }
  } else if (error is Exception) {
    // Menghilangkan awalan "Exception: " jika ada
    return error.toString().replaceAll('Exception: ', '');
  }
  
  return 'Terjadi kesalahan yang tidak terduga.';
}