import '../utils/demo_credentials.dart';
import '../models/user_model.dart';

/// Service handling authentication logic.
class AuthService {
  /// Attempts citizen login with phone and password.
  /// Returns true if credentials match, false otherwise.
  static bool loginCitizen(String phone, String password) {
    if (phone == DemoCredentials.citizenPhone &&
        password == DemoCredentials.citizenPassword) {
      UserSession.loggedInName = DemoCredentials.citizenName;
      UserSession.loggedInPhone = phone;
      return true;
    }
    return false;
  }

  /// Attempts admin login with username and password.
  /// Returns true if credentials match, false otherwise.
  static bool loginAdmin(String username, String password) {
    if (username == DemoCredentials.adminUsername &&
        password == DemoCredentials.adminPassword) {
      UserSession.loggedInName = DemoCredentials.adminName;
      return true;
    }
    return false;
  }

  /// Logs out the current user by clearing session data.
  static void logout() {
    UserSession.loggedInName = '';
    UserSession.loggedInPhone = '';
  }

  /// Checks if a user is currently logged in.
  static bool get isLoggedIn => UserSession.loggedInName.isNotEmpty;
}
