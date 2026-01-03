import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userData => _userData;

  AuthProvider() {
    // load auth state in background
    _loadAuthState().catchError((error) {
      print('Error loading auth state: $error');
      // default to logged out if something goes wrong
      _isAuthenticated = false;
      _userData = null;
      notifyListeners();
    });
  }

  Future<void> _loadAuthState() async {
    try {
      _isAuthenticated = await LocalStorageService.isAuthenticated();
      if (_isAuthenticated) {
        _userData = await LocalStorageService.getUserData();
      }
      notifyListeners();
    } catch (e) {
      print('Error in _loadAuthState: $e');
      _isAuthenticated = false;
      _userData = null;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    // basic auth check - just needs email and password
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userData = {
        'email': email,
        'name': email.split('@')[0],
      };
      
      await LocalStorageService.setAuthenticated(true);
      await LocalStorageService.saveUserData(_userData!);
      
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userData = null;
    await LocalStorageService.setAuthenticated(false);
    notifyListeners();
  }
}

