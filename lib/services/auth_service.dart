import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service to manage Firebase Authentication state and operations
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  /// Get the current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Get user display name
  String get displayName => _auth.currentUser?.displayName ?? 'User';

  /// Get user email
  String get email => _auth.currentUser?.email ?? '';

  /// Get user photo URL
  String? get photoURL => _auth.currentUser?.photoURL;

  /// Get user ID
  String get userId => _auth.currentUser?.uid ?? '';

  /// Sign out from both Firebase and Google
  Future<void> signOut() async {
    try {
      // Sign out from Google first
      await _googleSignIn.signOut();
      // Then sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Delete user account (careful with this!)
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Get user creation date
  DateTime? get userCreationDate => _auth.currentUser?.metadata.creationTime;

  /// Get last sign in date
  DateTime? get lastSignInDate => _auth.currentUser?.metadata.lastSignInTime;
}
