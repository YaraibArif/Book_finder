class CoverRepository {
  /// Get cover URL from coverId
  String getCoverUrl(int? coverId, {String size = "M"}) {
    if (coverId == null) {
      return "https://via.placeholder.com/150x220.png?text=No+Cover";
    }
    return "https://covers.openlibrary.org/b/id/$coverId-$size.jpg";
  }
}
