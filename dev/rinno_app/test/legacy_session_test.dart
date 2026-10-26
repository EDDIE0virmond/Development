import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rinno_app/core/constants/api_constants.dart';
import 'package:rinno_app/core/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'an editable legacy profile cannot restore authenticated roles',
    () async {
      SharedPreferences.setMockInitialValues({
        ApiConstants.userDataKey: jsonEncode({
          'id': 1,
          'nome': 'Forged profile',
          'email': 'audit@example.test',
          'role': 'master',
        }),
      });
      final auth = AuthProvider();
      await auth.refreshUser();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.canCreateUsers, isFalse);
      expect(auth.currentUser, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(ApiConstants.userDataKey), isFalse);
      auth.dispose();
    },
  );
}
