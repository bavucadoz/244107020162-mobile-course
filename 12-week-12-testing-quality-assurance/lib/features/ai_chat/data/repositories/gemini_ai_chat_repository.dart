// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_chat_repository.dart';

const geminiSystemPrompt = '''
Kamu adalah CampusMate, asisten belajar dan produktivitas kampus yang ramah.
Jawab dalam Bahasa Indonesia dengan jelas, ringkas, dan terstruktur.
Untuk pertanyaan penjelasan atau perbandingan, berikan jawaban utuh: definisi,
perbedaan atau poin penting, contoh sederhana, dan simpulan singkat bila relevan.
Jangan berhenti pada judul atau satu poin pembuka, dan jangan memulai jawaban dengan
tanda titik dua yang berdiri sendiri.
Bantu pengguna memahami materi, merangkum konsep, menyusun ide, dan mengelola produktivitas belajar.
Jangan mengarang jadwal, kebijakan, nilai, atau informasi resmi kampus yang tidak diberikan.
Jangan meminta atau mengungkap NIK, kata sandi, token, nomor telepon, alamat, maupun data pribadi.
Jika pertanyaan membutuhkan informasi resmi kampus yang tidak tersedia, arahkan pengguna untuk memeriksa kanal resmi kampus.
''';

/// Safe, user-facing API error. This deliberately never contains the API key.
class GeminiApiException implements Exception {
  const GeminiApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One SSE event returned by Gemini. A final event can contain a finishReason
/// without containing any additional text.
class GeminiStreamEvent {
  const GeminiStreamEvent({this.text, this.finishReason});

  final String? text;
  final String? finishReason;
}

class GeminiIncompleteResponseException implements Exception {
  const GeminiIncompleteResponseException();

  @override
  String toString() =>
      'Stream Gemini berakhir sebelum mengirim finishReason. Respons mungkin terputus.';
}

class GeminiTruncatedResponseException implements Exception {
  const GeminiTruncatedResponseException(this.finishReason);

  final String finishReason;

  @override
  String toString() => 'Respons Gemini dihentikan: $finishReason.';
}

/// Reads generated text from one Gemini GenerateContentResponse.
String? extractGeminiText(Object? payload) {
  if (payload is! Map<String, dynamic>) return null;

  final apiError = payload['error'];
  if (apiError is Map<String, dynamic>) {
    final message = apiError['message'] as String?;
    throw StateError(message ?? 'Gemini API mengembalikan error.');
  }

  final candidates = payload['candidates'];
  if (candidates is! List || candidates.isEmpty) return null;

  final firstCandidate = candidates.first;
  if (firstCandidate is! Map<String, dynamic>) return null;
  final content = firstCandidate['content'];
  if (content is! Map<String, dynamic>) return null;
  final parts = content['parts'];
  if (parts is! List) return null;

  final text = StringBuffer();
  for (final part in parts) {
    if (part is Map<String, dynamic> && part['text'] is String) {
      text.write(part['text'] as String);
    }
  }

  final result = text.toString();
  return result.isEmpty ? null : result;
}

/// Parses Gemini Server-Sent Events and preserves the terminal finishReason.
/// A normal EOF by itself is NOT considered proof that generation completed.
Stream<GeminiStreamEvent> parseGeminiSseEvents(
  Stream<List<int>> byteStream,
) async* {
  final lines = utf8.decoder.bind(byteStream).transform(const LineSplitter());
  final dataLines = <String>[];

  await for (final line in lines) {
    if (line.isEmpty) {
      final event = _decodeGeminiSseEvent(dataLines);
      dataLines.clear();
      if (event != null) yield event;
      continue;
    }

    // Ignore SSE comments/heartbeats and non-data fields such as `event:`.
    if (line.startsWith(':')) continue;

    final separator = line.indexOf(':');
    final field = separator == -1 ? line : line.substring(0, separator);
    if (field != 'data') continue;

    var value = separator == -1 ? '' : line.substring(separator + 1);
    if (value.startsWith(' ')) value = value.substring(1);
    dataLines.add(value);
  }

  // Some servers close the stream without a final blank-line delimiter.
  final remainingEvent = _decodeGeminiSseEvent(dataLines);
  if (remainingEvent != null) yield remainingEvent;
}

GeminiStreamEvent? _decodeGeminiSseEvent(List<String> dataLines) {
  if (dataLines.isEmpty) return null;

  final data = dataLines.join('\n').trim();
  if (data.isEmpty || data == '[DONE]') return null;

  final decoded = jsonDecode(data);
  if (decoded is! Map<String, dynamic>) return null;

  final text = extractGeminiText(decoded);
  String? finishReason;
  final candidates = decoded['candidates'];
  if (candidates is List && candidates.isNotEmpty) {
    final firstCandidate = candidates.first;
    if (firstCandidate is Map<String, dynamic>) {
      final reason = firstCandidate['finishReason'];
      if (reason is String && reason.isNotEmpty) finishReason = reason;
    }
  }

  if (text == null && finishReason == null) return null;
  return GeminiStreamEvent(text: text, finishReason: finishReason);
}

/// Compatibility helper used by parser tests and simple consumers that only
/// need text deltas. Production requests use [parseGeminiSseEvents] so they can
/// validate the terminal finishReason.
Stream<String> parseGeminiSseStream(Stream<List<int>> byteStream) async* {
  await for (final event in parseGeminiSseEvents(byteStream)) {
    final text = event.text;
    if (text != null) yield text;
  }
}

/// Removes a stray standalone leading colon sometimes included in generated
/// Markdown, without changing normal punctuation inside the answer.
String normalizeGeminiResponseText(String input) {
  return input
      .replaceFirst(RegExp(r'^\s*:\s*(?:\r?\n)+'), '')
      .trimLeft();
}

class GeminiAiChatRepository implements AiChatRepository {
  GeminiAiChatRepository({
    required Dio dio,
    required FlutterSecureStorage storage,
  }) : _dio = dio,
       _storage = storage;

  static const _apiKeyStorageKey = 'gemini_api_key';
  static const _model = 'gemini-3.8-flash';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:streamGenerateContent';

  final Dio _dio;
  final FlutterSecureStorage _storage;

  @override
  Future<bool> hasApiKey() async {
    final key = await _storage.read(key: _apiKeyStorageKey);
    return key != null && key.trim().isNotEmpty;
  }

  @override
  Future<void> saveApiKey(String key) async {
    final normalizedKey = key.trim();
    if (normalizedKey.isEmpty) {
      throw ArgumentError('API key tidak boleh kosong.');
    }
    await _storage.write(key: _apiKeyStorageKey, value: normalizedKey);
  }

  @override
  Future<void> deleteApiKey() => _storage.delete(key: _apiKeyStorageKey);

  Future<String?> _readDioErrorDetails(DioException error) async {
    final data = error.response?.data;
    String? rawBody;

    try {
      if (data is ResponseBody) {
        rawBody = await utf8.decoder
            .bind(data.stream.cast<List<int>>())
            .join();
      } else if (data is String) {
        rawBody = data;
      } else if (data is Map) {
        final apiError = data['error'];
        if (apiError is Map && apiError['message'] is String) {
          return apiError['message'] as String;
        }
      }
    } catch (_) {
      // Keep the HTTP status and Dio error type even if the error body
      // cannot be decoded.
    }

    if (rawBody == null || rawBody.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final apiError = decoded['error'];
        if (apiError is Map && apiError['message'] is String) {
          return apiError['message'] as String;
        }
      }
    } catch (_) {
      // Some gateways return plain-text error bodies.
    }

    return rawBody.trim().length > 300
        ? '${rawBody.trim().substring(0, 300)}…'
        : rawBody.trim();
  }

  String _formatDioError(DioException error, String? details) {
    final status = error.response?.statusCode;
    final suffix = details == null || details.isEmpty ? '' : '\nDetail: $details';

    if (status == 400) {
      return 'Permintaan Gemini ditolak (HTTP 400). Periksa format request dan parameter model.$suffix';
    }
    if (status == 401 || status == 403) {
      return 'Gemini menolak API key atau akses project (HTTP $status). Pastikan key berasal dari Google AI Studio, tidak dibatasi untuk API yang salah, dan project memiliki akses Gemini API.$suffix';
    }
    if (status == 404) {
      return 'Model atau endpoint Gemini tidak ditemukan (HTTP 404). Periksa ID model dan endpoint API.$suffix';
    }
    if (status == 429) {
      return 'Kuota atau batas request Gemini tercapai (HTTP 429). Periksa kuota dan billing project, lalu coba lagi nanti.$suffix';
    }
    if (status != null && status >= 500) {
      return 'Server Gemini sedang mengalami gangguan (HTTP $status). Coba lagi beberapa saat.$suffix';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi ke Gemini timeout saat menghubungkan. Periksa internet lalu coba lagi.';
      case DioExceptionType.sendTimeout:
        return 'Pengiriman request ke Gemini timeout. Coba lagi.';
      case DioExceptionType.receiveTimeout:
        return 'Gemini terlalu lama mengirim respons. Coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke Gemini. Periksa koneksi internet atau jaringan emulator.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat koneksi Gemini tidak dapat diverifikasi oleh perangkat.';
      case DioExceptionType.cancel:
        return 'Request Gemini dibatalkan.';
      default:
        return 'Request Gemini gagal${status == null ? '' : ' (HTTP $status)' }.$suffix';
    }
  }

  @override
  Stream<String> streamReply(List<ChatMessage> conversation) async* {
    final apiKey = await _storage.read(key: _apiKeyStorageKey);
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const MissingAiApiKeyException();
    }
    if (conversation.isEmpty) return;

    // Keep only the most recent turns to limit payload size and API usage.
    final recentMessages = conversation.length > 12
        ? conversation.sublist(conversation.length - 12)
        : conversation;

    final payload = <String, Object?>{
      'systemInstruction': {
        'parts': [
          {'text': geminiSystemPrompt},
        ],
      },
      'contents': recentMessages
          .map(
            (message) => {
              'role': message.role == ChatRole.user ? 'user' : 'model',
              'parts': [
                {'text': message.text},
              ],
            },
          )
          .toList(growable: false),
      'generationConfig': {
        'temperature': 0.6,
        // Gemini 3.8 Flash defaults to medium thinking. maxOutputTokens also
        // counts internal thinking tokens, so a 512-token cap can leave only
        // a few words for the visible answer. LOW reserves more budget for text.
        'thinkingConfig': {'thinkingLevel': 'LOW'},
        'maxOutputTokens': 2048,
      },
    };

    try {
      final response = await _dio.post<ResponseBody>(
        _endpoint,
        queryParameters: const {'alt': 'sse'},
        data: payload,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 90),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
        ),
      );

      final body = response.data;
      if (body == null) {
        throw const FormatException('Respons streaming Gemini kosong.');
      }

      String? finishReason;
      await for (final event in
          parseGeminiSseEvents(body.stream.cast<List<int>>())) {
        if (event.text != null) yield event.text!;
        if (event.finishReason != null) {
          finishReason = event.finishReason;
        }
      }

      if (finishReason == null) {
        throw const GeminiIncompleteResponseException();
      }
      if (finishReason != 'STOP') {
        throw GeminiTruncatedResponseException(finishReason);
      }
    } on DioException catch (error) {
      final details = await _readDioErrorDetails(error);
      throw GeminiApiException(_formatDioError(error, details));
    }
  }
}
