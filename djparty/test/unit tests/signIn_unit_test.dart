import 'package:djparty/services/SignInProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/services/SignInProvider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  test('sign in with e-mail and password', () async {
    SignInProvider sp = SignInProvider();
    await sp.signUpWithEmailPassword(email: 'ric@ric.com', password: 'pizza');
    expect(sp.errorCode is String, true);
  });
}
