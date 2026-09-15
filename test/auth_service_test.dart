import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/auth_service.dart';

void main() {
  test('tracks the logged-in user for complaint submissions', () {
    AuthService.logout();

    AuthService.setLoggedInUser({
      'id': 42,
      'name': 'Ada Lovelace',
      'email': 'ada@example.com',
    });

    expect(AuthService.currentUserId, 42);
    expect(AuthService.currentUserName, 'Ada Lovelace');
    expect(AuthService.currentUserEmail, 'ada@example.com');
  });
}
