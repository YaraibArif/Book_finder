import 'package:dio/dio.dart';

class OpenLibraryApi {
  static const String baseUrl = "https://openlibrary.org";
  static final Dio _dio = Dio(
    BaseOptions(
      headers: {
        "Accept": "application/json",
      },
    ),
  );

  static Future<Map<String, dynamic>> fetchSubject(String subject) async {
    try {
      final url = "$baseUrl/subjects/$subject.json";
      print("📡 Fetching: $url"); //Debug URL

      final response = await _dio.get(
        url,
        queryParameters: {
          "details": "true",
          "limit": 10,
        },
      );

      print("Status: ${response.statusCode}");
      print("Response Type: ${response.data.runtimeType}");
      print("Response Preview: ${response.data.toString().substring(0, 200)}...");

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        throw Exception("Invalid response format");
      }
    } on DioException catch (e) {
      print("DioException: ${e.message}");
      if (e.response != null) {
        print("Error Body: ${e.response!.data}");
      }
      throw Exception("Dio error: ${e.message}");
    } catch (e) {
      print("Unknown error: $e");
      throw Exception("Unknown error: $e");
    }
  }
}
