import '../services/open_library_api.dart';

class BookRepository {
  /// Fetch full details of a work
  Future<Map<String, dynamic>> getWork(String workKey) async {
    final data = await OpenLibraryApi.fetchWork(workKey);
    return data;
  }
}
