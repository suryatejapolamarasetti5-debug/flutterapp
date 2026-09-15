class AuthService {
  static String? registeredName;
  static String? registeredEmail;
  static String? registeredPassword;

  static Map<String, dynamic>? currentUser;

  static int? get currentUserId =>
      currentUser == null ? null : currentUser!['id'] as int?;

  static String? get currentUserName =>
      currentUser == null ? null : currentUser!['name'] as String?;

  static String? get currentUserEmail =>
      currentUser == null ? null : currentUser!['email'] as String?;

  static void setLoggedInUser(Map<String, dynamic> user) {
    currentUser = Map<String, dynamic>.from(user);
  }

  static void logout() {
    currentUser = null;
  }

  static bool register({
    required String name,
    required String email,
    required String password,
  }) {
    registeredName = name.trim();
    registeredEmail = email.trim().toLowerCase();
    registeredPassword = password;

    return true;
  }

  static bool login({
    required String email,
    required String password,
  }) {
    if (registeredEmail == null || registeredPassword == null) {
      return false;
    }

    return email.trim().toLowerCase() == registeredEmail &&
        password == registeredPassword;
  }
}