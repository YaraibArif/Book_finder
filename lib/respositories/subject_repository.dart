import '../services/open_library_api.dart';

class SubjectRepository {
  Future<Map<String, dynamic>> getSubject(
      String subject, {
        int limit = 25,
        int offset = 0,
        bool details = false,
      }) async {
    final data = await OpenLibraryApi.fetchSubject(
      subject,
      limit: limit,
      offset: offset,
      details: details,
    );
    return data;
  }
}
