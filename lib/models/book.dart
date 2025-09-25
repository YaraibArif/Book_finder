import 'package:cloud_firestore/cloud_firestore.dart';

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
      "addedAt": addedAt.toIso8601String(), // local storage
    };
  }
  factory FavoriteBook.fromMap(Map<String, dynamic> map) {
    return FavoriteBook(
      id: map["id"] ?? "",
      title: map["title"] ?? "Unknown",
      authors: (map["authors"] as List?)?.map((e) => e.toString()).toList() ?? [],
      coverUrl: map["coverUrl"],
      firstPublishYear: map["firstPublishYear"],
      addedAt: (map["addedAt"] is Timestamp)
          ? (map["addedAt"] as Timestamp).toDate()
          : DateTime.tryParse(map["localAddedAt"] ?? "") ?? DateTime.now(),
    );
  }

}
