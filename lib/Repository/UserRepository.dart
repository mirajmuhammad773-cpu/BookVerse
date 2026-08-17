import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Models/UserModel.dart';

class UserRepository {
  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn =
      GoogleSignIn.instance;

  bool _googleInitialized = false;

  // ============================================================
  // GOOGLE SIGN-IN INITIALIZATION
  // ============================================================

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) {
      return;
    }

    await _googleSignIn.initialize();

    _googleInitialized = true;
  }

  // ============================================================
  // CURRENT FIREBASE USER
  // ============================================================

  User? get currentFirebaseUser {
    return _auth.currentUser;
  }

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  bool get isLoggedIn {
    return _auth.currentUser != null;
  }

  // ============================================================
  // USERS COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get _usersCollection {
    return _firestore.collection('users');
  }

  // ============================================================
  // EMAIL + PASSWORD SIGN UP
  // ============================================================

  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Unable to create user.',
        );
      }

      await firebaseUser.updateDisplayName(
        name.trim(),
      );

      final UserModel user = UserModel(
        uid: firebaseUser.uid,
        name: name.trim(),
        email: email.trim(),
        password: '',
        createdAt: DateTime.now(),
      );

      // Password is NOT stored in Firestore.
      await _usersCollection
          .doc(firebaseUser.uid)
          .set(
        user.toFirestoreMap(),
      );

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _handleAuthException(e),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // EMAIL + PASSWORD LOGIN
  // ============================================================

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Unable to login user.',
        );
      }

      return await getUserById(
        firebaseUser.uid,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _handleAuthException(e),
      );
    }
  }

  // ============================================================
  // GOOGLE SIGN IN
  // ============================================================

  Future<UserModel> signInWithGoogle() async {
    try {
      await _initializeGoogleSignIn();

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final String? idToken =
          googleAuth.idToken;

      if (idToken == null) {
        throw Exception(
          'Google ID token is missing.',
        );
      }

      final AuthCredential credential =
          GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(
        credential,
      );

      final User? firebaseUser =
          userCredential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Unable to sign in with Google.',
        );
      }

      final DocumentSnapshot<
              Map<String, dynamic>>
          existingUser =
          await _usersCollection
              .doc(firebaseUser.uid)
              .get();

      if (existingUser.exists &&
          existingUser.data() != null) {
        return UserModel.fromMap(
          existingUser.data()!,
        );
      }

      final UserModel user = UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        password: '',
        createdAt: DateTime.now(),
      );

      await _usersCollection
          .doc(firebaseUser.uid)
          .set(
        user.toFirestoreMap(),
      );

      return user;
    } on GoogleSignInException catch (e) {
      throw Exception(
        'Google Sign-In failed: '
        '${e.description ?? e.code.name}',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _handleAuthException(e),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // GET USER BY ID
  // ============================================================

  Future<UserModel> getUserById(
    String uid,
  ) async {
    final DocumentSnapshot<
            Map<String, dynamic>>
        document =
        await _usersCollection
            .doc(uid)
            .get();

    if (!document.exists ||
        document.data() == null) {
      throw Exception(
        'User profile not found.',
      );
    }

    return UserModel.fromMap(
      document.data()!,
    );
  }

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  Future<UserModel?> getCurrentUser() async {
    final User? firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    try {
      return await getUserById(
        firebaseUser.uid,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // UPDATE USER PROFILE
  // ============================================================

  Future<void> updateUser({
    required String uid,
    String? name,
    String? email,
  }) async {
    final Map<String, dynamic> data = {};

    if (name != null &&
        name.trim().isNotEmpty) {
      data['name'] = name.trim();
    }

    if (email != null &&
        email.trim().isNotEmpty) {
      data['email'] = email.trim();
    }

    if (data.isEmpty) {
      return;
    }

    await _usersCollection
        .doc(uid)
        .update(data);

    final User? firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      return;
    }

    if (name != null &&
        name.trim().isNotEmpty) {
      await firebaseUser.updateDisplayName(
        name.trim(),
      );
    }

    if (email != null &&
        email.trim().isNotEmpty &&
        email.trim() != firebaseUser.email) {
      await firebaseUser.verifyBeforeUpdateEmail(
        email.trim(),
      );
    }
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No logged-in user found.',
      );
    }

    // ----------------------------------------------------------
    // CHECK PASSWORD LOGIN PROVIDER
    // ----------------------------------------------------------

    final bool hasPasswordProvider =
        user.providerData.any(
      (provider) =>
          provider.providerId == 'password',
    );

    if (!hasPasswordProvider) {
      throw Exception(
        'Password cannot be changed for this Google account.',
      );
    }

    final String? email = user.email;

    if (email == null ||
        email.trim().isEmpty) {
      throw Exception(
        'User email not found.',
      );
    }

    // ----------------------------------------------------------
    // CURRENT PASSWORD REQUIRED
    // ----------------------------------------------------------

    if (currentPassword.trim().isEmpty) {
      throw Exception(
        'Please enter your current password.',
      );
    }

    // ----------------------------------------------------------
    // RE-AUTHENTICATE USER
    // ----------------------------------------------------------

    try {
      final AuthCredential credential =
          EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(
        credential,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _handleAuthException(e),
      );
    }

    // ----------------------------------------------------------
    // UPDATE FIREBASE AUTH PASSWORD
    // ----------------------------------------------------------

    try {
      await user.updatePassword(
        newPassword,
      );

      // Force Firebase user state refresh.
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _handleAuthException(e),
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      await _initializeGoogleSignIn();

      await _googleSignIn.signOut();
    } catch (_) {
      // Continue with Firebase logout.
    }

    await _auth.signOut();
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> deleteAccount() async {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      return;
    }

    await _usersCollection
        .doc(user.uid)
        .delete();

    try {
      await _initializeGoogleSignIn();

      await _googleSignIn.disconnect();
    } catch (_) {
      // Ignore Google disconnect errors.
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _handleAuthException(e),
      );
    }
  }

  // ============================================================
  // AUTH ERROR HANDLER
  // ============================================================

  String _handleAuthException(
    FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Password is too weak.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
        return 'Current password is incorrect.';

      case 'invalid-credential':
        return 'Current password is incorrect.';

      case 'requires-recent-login':
        return 'Please login again before changing your password.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';

      case 'provider-already-linked':
        return 'This account is already linked.';

      case 'credential-already-in-use':
        return 'This credential is already in use.';

      default:
        return e.message ??
            'Authentication failed.';
    }
  }
}