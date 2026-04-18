import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Get current user's display name
  static String get displayName {
    final user = _auth.currentUser;
    return user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
  }

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── EMAIL SIGN UP ───────────────────────────────────────────
  static Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save display name
      await cred.user?.updateDisplayName(name.trim());

      // Save to Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _handleError(e.code);
    }
  }

  // ─── EMAIL SIGN IN ───────────────────────────────────────────
  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _handleError(e.code);
    }
  }

  // ─── GOOGLE SIGN IN ──────────────────────────────────────────
  static Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Sign in cancelled';

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);

      // Save to Firestore if new user
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists) {
        await _db.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'name': cred.user!.displayName ?? '',
          'email': cred.user!.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _handleError(e.code);
    } catch (e) {
      return 'Google sign-in failed. Try again.';
    }
  }

  // ─── SIGN OUT ────────────────────────────────────────────────
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── UPDATE PROFILE ──────────────────────────────────────────
  static Future<String?> updateDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name.trim());
      await _db
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'name': name.trim()});
      return null;
    } catch (e) {
      return 'Failed to update name';
    }
  }

  // ─── ERROR HANDLER ───────────────────────────────────────────
  static String _handleError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // ─── VALIDATORS ──────────────────────────────────────────────
  static String? validateEmail(String email) {
    if (email.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(email.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!password.contains(RegExp(r'[A-Z]')))
      return 'Must contain at least one uppercase letter';
    if (!password.contains(RegExp(r'[0-9]')))
      return 'Must contain at least one number';
    return null;
  }

  static String? validateName(String name) {
    if (name.trim().isEmpty) return 'Name is required';
    if (name.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }
}