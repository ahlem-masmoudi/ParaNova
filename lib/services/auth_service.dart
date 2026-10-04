import 'package:web/web.dart' as web;

class AuthService {
  static const String _keyIsLoggedIn = 'app_is_logged_in';
  static const String _defaultUsername = 'admin';
  static const String _defaultPassword = 'admin123';

  // Vérifier si l'utilisateur est connecté
  bool isLoggedIn() {
    final isLoggedIn = web.window.localStorage.getItem(_keyIsLoggedIn);
    return isLoggedIn == 'true';
  }

  // Connexion
  bool login(String username, String password) {
    if (username == _defaultUsername && password == _defaultPassword) {
      web.window.localStorage.setItem(_keyIsLoggedIn, 'true');
      print('✅ Connexion réussie');
      return true;
    }
    print('❌ Identifiants incorrects');
    return false;
  }

  // Déconnexion
  void logout() {
    web.window.localStorage.removeItem(_keyIsLoggedIn);
    print('👋 Déconnexion');
  }
}
