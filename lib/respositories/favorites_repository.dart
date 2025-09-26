import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream all favorites of user
  Stream<List<FavoriteBook>> streamFavorites(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .orderBy("addedAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        //  Fallback logic
        if (data["addedAt"] == null && data["localAddedAt"] != null) {
          data["addedAt"] =
              Timestamp.fromDate(DateTime.parse(data["localAddedAt"]));
        } else if (data["addedAt"] == null) {
          data["addedAt"] = Timestamp.fromDate(DateTime.now());
        }

        return FavoriteBook.fromMap(data);
      }).toList();
    });
  }

  /// Add new favorite book
  Future<void> addFavorite(String userId, FavoriteBook book) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(book.id)
        .set({
      ...book.toMap(),
      "addedAt": FieldValue.serverTimestamp(),
      "localAddedAt": book.addedAt.toIso8601String(),
    }, SetOptions(merge: true));
  }

  ///  Remove favorite book
  Future<void> removeFavorite(String userId, String bookId) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(bookId)
        .delete();
  }
}
