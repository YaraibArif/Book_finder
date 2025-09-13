import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId: "567654118983-434ihaoc0h00lpaqofv6mmi0parlcqu9.apps.googleusercontent.com", // ye Firebase Console Web client ID
  );



  firebase_auth.User? _user;
  firebase_auth.User? get user => _user;

  bool _isSignedIn = false;
  String? _userId;
  String? _userEmail;

  bool get isSignedIn => _isSignedIn;
  String? get userId => _userId;
  String? get userEmail => _userEmail;

  AuthProvider() {
    _auth.authStateChanges().listen((firebase_auth.User? user) {
      _user = user;
      if (user != null) {
        _isSignedIn = true;
        _userId = user.uid;
        _userEmail = user.email;
      } else {
        _isSignedIn = false;
        _userId = null;
        _userEmail = null;
      }
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw e.message ?? "Authentication failed";
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw e.message ?? "Sign up failed";
    }
  }

  /// ✅ Single signOut method (merged)
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();

    _isSignedIn = false;
    _userId = null;
    _userEmail = null;

    notifyListeners();
  }

  /// 🔹 Utility for local dummy login (optional, for testing without Firebase)
  void signInDummy({String? userId, String? email}) {
    _isSignedIn = true;
    _userId = userId ?? "dummy_user";
    _userEmail = email ?? "guest@example.com";
    notifyListeners();
  }

  void toggleAuth() {
    if (_isSignedIn) {
      signOut();
    } else {
      signInDummy();
    }
  }
}
