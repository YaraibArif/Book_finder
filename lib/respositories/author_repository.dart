import '../services/open_library_api.dart';

class AuthorRepository {
  /// Fetch full details of an author
  Future<Map<String, dynamic>> getAuthor(String authorKey) async {
    final data = await OpenLibraryApi.fetchAuthor(authorKey);
    return data;
  }
}
