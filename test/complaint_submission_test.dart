import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/auth_service.dart';

void main() {
  test('logged-in user can be tracked for complaint submissions', () {
    AuthService.logout();

    AuthService.setLoggedInUser({
      'id': 7,
      'name': 'Test User',
      'email': 'test@example.com',
      'role': 'user',
    });

    expect(AuthService.currentUserId, 7);
    expect(AuthService.currentUserEmail, 'test@example.com');
    expect(AuthService.currentUserName, 'Test User');
  });
}
