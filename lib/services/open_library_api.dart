import 'package:dio/dio.dart';

class OpenLibraryApi {
  static const String baseUrl = "https://openlibrary.org";
  static final Dio _dio = Dio(
    BaseOptions(
      headers: {
        "Accept": "application/json",
      },
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  static Future<Map<String, dynamic>> fetchSubject(
      String subject, {
        int limit = 25,
        int offset = 0,
        bool details = false,
      }) async {
    try {
      final url = "$baseUrl/subjects/$subject.json";
      final response = await _dio.get(
        url,
        queryParameters: {
          "limit": limit,
          "offset": offset,
          if (details) "details": "true",
        },
      );

      print("📡 URL: $url");
      print("Status: ${response.statusCode}");
      print("Response type: ${response.data.runtimeType}");

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Invalid JSON response: ${response.data}");
      }
    } on DioException catch (e) {
      print("DioException: ${e.message}");
      if (e.response != null) {
        print("Error body: ${e.response!.data}");
      }
      throw Exception("Dio error: ${e.message}");
    } catch (e) {
      print("Unknown error: $e");
      throw Exception("Unknown error: $e");
    }
  }

  // Work detail fetch
  static Future<Map<String, dynamic>> fetchWork(String workKey) async {
    final url = "$baseUrl$workKey.json"; // e.g. /works/OL12345W.json
    final response = await _dio.get(url);

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return response.data;
    } else {
      throw Exception("Invalid response for work $workKey");
    }
  }

// Author detail fetch
  static Future<Map<String, dynamic>> fetchAuthor(String authorKey) async {
    final url = "$baseUrl$authorKey.json"; // e.g. /authors/OL12345A.json
    final response = await _dio.get(url);

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return response.data;
    } else {
      throw Exception("Invalid response for author $authorKey");
    }
  }

}
