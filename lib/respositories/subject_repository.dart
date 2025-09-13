import '../services/open_library_api.dart';

class SubjectRepository {
  Future<List<dynamic>> getBooksBySubject(String subject) async {
    final data = await OpenLibraryApi.fetchSubject(subject);
    return data["works"] ?? [];
  }
}
