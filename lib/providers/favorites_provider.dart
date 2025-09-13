import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';

class FavoritesProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final String userId;

  FavoritesProvider({required this.userId});

  /// 🔹 Local cache
  final List<FavoriteBook> _favorites = [];

  List<FavoriteBook> get favorites => _favorites;

  /// 🔹 Stream user favorites
  Stream<List<FavoriteBook>> get favoritesStream {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .orderBy("addedAt", descending: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => FavoriteBook.fromMap(doc.data()))
          .toList();

      // 🟢 local cache update
      _favorites
        ..clear()
        ..addAll(list);

      notifyListeners();
      return list;
    });
  }

  /// 🔹 Check if book is favorite
  bool isFavorite(String bookId) {
    return _favorites.any((book) => book.id == bookId);
  }

  /// 🔹 Add book to favorites
  Future<void> addFavorite({
    required String workKey,
    required String title,
    required List<String> authors,
    String? coverUrl,
    String? firstPublishYear,
  }) async {
    final book = FavoriteBook(
      id: workKey,
      title: title,
      authors: authors,
      coverUrl: coverUrl,
      firstPublishYear: firstPublishYear,
      addedAt: DateTime.now(),
    );

    await _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(book.id)
        .set(book.toMap());
  }

  /// 🔹 Remove book from favorites
  Future<void> removeFavorite(String bookId) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(bookId)
        .delete();
  }
}
