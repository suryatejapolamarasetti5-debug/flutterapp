class AuthService {
  static String? registeredName;
  static String? registeredEmail;
  static String? registeredPassword;

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