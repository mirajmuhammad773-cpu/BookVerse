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

  // Latest google_sign_in API
  final GoogleSignIn _googleSignIn =
      GoogleSignIn.instance;

  // ============================================================
  // GOOGLE SIGN-IN INITIALIZATION
  // ============================================================

  bool _googleInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) {
      return;
    }

    await _googleSignIn.initialize();

    _googleInitialized = true;
  }

  // ============================================================
  // CURRENT USER
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
        throw Exception('Unable to create user.');
      }

      // Update Firebase Auth display name
      await firebaseUser.updateDisplayName(
        name.trim(),
      );

      final UserModel user = UserModel(
        uid: firebaseUser.uid,
        name: name.trim(),
        email: email.trim(),
        password: password,
        createdAt: DateTime.now(),
      );

      // IMPORTANT:
      // Password should NOT be stored in Firestore.
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
        password: password,
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
      // Latest google_sign_in requires initialization
      await _initializeGoogleSignIn();

      // Latest API:
      // signIn() -> authenticate()
      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      // Latest GoogleSignInAuthentication contains idToken
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception(
          'Google ID token is missing.',
        );
      }

      // Firebase Google credential
      final AuthCredential credential =
          GoogleAuthProvider.credential(
        idToken: idToken,
      );

      // Sign in to Firebase
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

      // ========================================================
      // CHECK FIRESTORE USER
      // ========================================================

      final DocumentSnapshot<
          Map<String, dynamic>> existingUser =
          await _usersCollection
              .doc(firebaseUser.uid)
              .get();

      // User already exists
      if (existingUser.exists &&
          existingUser.data() != null) {
        return UserModel.fromMap(
          existingUser.data()!,
        );
      }

      // ========================================================
      // CREATE NEW GOOGLE USER
      // ========================================================

      final UserModel user = UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        password: '',
        createdAt: DateTime.now(),
      );

      // Password is NOT stored.
      await _usersCollection
          .doc(firebaseUser.uid)
          .set(
        user.toFirestoreMap(),
      );

      return user;
    } on GoogleSignInException catch (e) {
      throw Exception(
        'Google Sign-In failed: ${e.description ?? e.code.name}',
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
    String uid, {
    String password = '',
  }) async {
    final DocumentSnapshot<
        Map<String, dynamic>> document =
        await _usersCollection
            .doc(uid)
            .get();

    if (!document.exists ||
        document.data() == null) {
      throw Exception(
        'User profile not found.',
      );
    }

    final UserModel user =
        UserModel.fromMap(
      document.data()!,
    );

    return user.copyWith(
      password: password,
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
  // UPDATE USER
  // ============================================================

  Future<void> updateUser({
    required String uid,
    String? name,
    String? email,
  }) async {
    final Map<String, dynamic> data = {};

    if (name != null) {
      data['name'] = name.trim();
    }

    if (email != null) {
      data['email'] = email.trim();
    }

    if (data.isEmpty) {
      return;
    }

    // Update Firestore
    await _usersCollection
        .doc(uid)
        .update(data);

    // Update Firebase Auth display name
    final User? firebaseUser =
        _auth.currentUser;

    if (firebaseUser != null &&
        name != null) {
      await firebaseUser.updateDisplayName(
        name.trim(),
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
      // Continue Firebase logout
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

    // Delete Firestore user
    await _usersCollection
        .doc(user.uid)
        .delete();

    // Google logout
    try {
      await _initializeGoogleSignIn();

      await _googleSignIn.disconnect();
    } catch (_) {
      // Ignore Google disconnect errors
    }

    // Delete Firebase Auth account
    await user.delete();
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
      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';

      default:
        return e.message ??
            'Authentication failed.';
    }
  }
}