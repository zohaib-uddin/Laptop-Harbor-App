import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool _loading = false;
  bool get isLoading => _loading;

  AuthProvider(this._authService) {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) async {
    if (user == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }
    _currentUser = await _authService.getCurrentAppUser();
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.login(
        email: email,
        password: password,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
