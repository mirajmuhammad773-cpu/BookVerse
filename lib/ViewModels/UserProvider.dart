import 'package:flutter/foundation.dart';

import '../Models/UserModel.dart';
import '../Repository/UserRepository.dart';

class UserProvider extends ChangeNotifier {
  // ============================================================
  // REPOSITORY
  // ============================================================

  final UserRepository _repository =
      UserRepository();

  // ============================================================
  // STATE
  // ============================================================

  UserModel? _user;

  bool _isLoading = false;

  bool _isInitialized = false;

  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  String? get errorMessage => _errorMessage;

  bool get isLoggedIn =>
      _repository.isLoggedIn;

  String? get userId =>
      _user?.uid;

  String get userName =>
      _user?.name ?? '';

  String get userEmail =>
      _user?.email ?? '';

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // SET LOADING
  // ============================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ============================================================
  // LOAD CURRENT USER
  // ============================================================

  Future<void> loadCurrentUser() async {
    _setLoading(true);

    _errorMessage = null;

    try {
      _user =
          await _repository.getCurrentUser();

      _isInitialized = true;
    } catch (e) {
      _errorMessage =
          e.toString();

      _isInitialized = true;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    _errorMessage = null;

    try {
      _user =
          await _repository.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      _errorMessage =
          e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    _errorMessage = null;

    try {
      _user =
          await _repository.loginWithEmail(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      _errorMessage =
          e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<bool> signInWithGoogle() async {
    _setLoading(true);

    _errorMessage = null;

    try {
      _user =
          await _repository.signInWithGoogle();

      return true;
    } catch (e) {
      _errorMessage =
          e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<bool> updateProfile({
    String? name,
    String? email,
  }) async {
    if (_user == null) {
      return false;
    }

    _setLoading(true);

    _errorMessage = null;

    try {
      await _repository.updateUser(
        uid: _user!.uid,
        name: name,
        email: email,
      );

      _user = _user!.copyWith(
        name: name,
        email: email,
      );

      return true;
    } catch (e) {
      _errorMessage =
          e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _repository.logout();

      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage =
          e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<bool> deleteAccount() async {
    _setLoading(true);

    _errorMessage = null;

    try {
      await _repository.deleteAccount();

      _user = null;

      return true;
    } catch (e) {
      _errorMessage =
          e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }
}