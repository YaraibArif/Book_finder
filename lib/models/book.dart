class FavoriteBook {
  final String id;
  final String title;
  final List<String> authors;
  final String? coverUrl;
  final String? firstPublishYear;
  final DateTime addedAt;

  FavoriteBook({
    required this.id,
    required this.title,
    required this.authors,
    this.coverUrl,
    this.firstPublishYear,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "authors": authors,
      "coverUrl": coverUrl,
      "firstPublishYear": firstPublishYear,
      "addedAt": addedAt.toIso8601String(),
    };
  }

  factory FavoriteBook.fromMap(Map<String, dynamic> map) {
    return FavoriteBook(
      id: map["id"] ?? "",
      title: map["title"] ?? "Unknown",
      authors: (map["authors"] as List?)?.map((e) => e.toString()).toList() ?? [],
      coverUrl: map["coverUrl"],
      firstPublishYear: map["firstPublishYear"],
      addedAt: DateTime.tryParse(map["addedAt"] ?? "") ?? DateTime.now(),
    );
  }
}
