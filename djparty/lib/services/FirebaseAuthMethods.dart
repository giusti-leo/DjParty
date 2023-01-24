/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/Home.dart';
import 'package:djparty/page/SignIn.dart';
import 'package:djparty/utils/showOtpDialog.dart';
import 'package:djparty/utils/showSnackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:djparty/utils/showOTPDialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:djparty/utils/showOtpDialog.dart';

import '../page/Login.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth;
  FirebaseAuthMethods(this._auth);
  var _googleSignin = GoogleSignIn();
  var googleAccount = GoogleSignInAccount;

  // FOR EVERY FUNCTION HERE
  // POP THE ROUTE USING: Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);

  // GET USER DATA
  // using null check operator since this method should be called only
  // when the user is logged in
  User get user => _auth.currentUser!;

  // STATE PERSISTENCE STREAM
  Stream<User?> get authState => FirebaseAuth.instance.authStateChanges();
  // OTHER WAYS (depends on use case):
  // Stream get authState => FirebaseAuth.instance.userChanges();
  // Stream get authState => FirebaseAuth.instance.idTokenChanges();
  // KNOW MORE ABOUT THEM HERE: https://firebase.flutter.dev/docs/auth/start#auth-state

  // EMAIL SIGN UP
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) {
        if (value.user != null) {
          if (value.additionalUserInfo!.isNewUser) {
            insertUser(context, user);
            displayToastMessage('User added', context);
          }
        }
      });
      await sendEmailVerification(context);
      Navigator.pushNamed(context, SignIn.routeName);
    } on FirebaseAuthException catch (e) {
      // if you want to display your own custom error message
      if (e.code == 'weak-password') {
        displayToastMessage('The password provided is too weak.', context);
      } else if (e.code == 'email-already-in-use') {
        displayToastMessage(
            'The account already exists for that email.', context);
      } // Displaying the usual firebase error message
    }
  }

  // EMAIL LOGIN
  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      if (user.emailVerified) {
        Navigator.pushNamed(context, Home.routeName);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-request') {
        displayToastMessage('Mail already sent!', context);
        return;
      } else {
        displayToastMessage(e.message!, context);
      }
    }
  }

  // EMAIL VERIFICATION
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      _auth.currentUser!.sendEmailVerification();
      displayToastMessage(
          'Please, verify your email. Mail sent again!', context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-request') {
        displayToastMessage('Mail already sent!', context);
        return;
      }
    }
  }

  // GOOGLE SIGN IN
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      await _auth.signInWithCredential(credential).then((value) {
        if (value.user != null) {
          if (value.additionalUserInfo!.isNewUser) {
            insertGoogleUser(context, googleUser);
            displayToastMessage('User added', context);
          }
          Navigator.pushNamed(context, Home.routeName);
        }
      });
    } on FirebaseAuthException catch (e) {
      displayToastMessage(e.message!, context);
      // Displaying the error message
    }
  }

  Future<void> insertGoogleUser(
      BuildContext context, GoogleSignInAccount googleUser) async {
    try {
      CollectionReference<Map<String, dynamic>> users =
          FirebaseFirestore.instance.collection('users');

      Map<String, dynamic> userDataMap = {
        'email': googleUser.email.toString(),
        'username': googleUser.email.toString(),
        'description': '',
        'image': new Color(0x00000000).value,
        'init': googleUser.email[0].toString(),
        'initColor': new Color(0xFFFFFFFF).value
      };

      await users
          .doc(_auth.currentUser!.uid)
          .set(userDataMap)
          .then((value) => print('User added'));
    } on FirebaseAuthException catch (e) {
      displayToastMessage(e.code, context);
    }
  }

  Future<void> insertUser(BuildContext context, User user) async {
    try {
      CollectionReference<Map<String, dynamic>> users =
          FirebaseFirestore.instance.collection('users');

      Map<String, dynamic> userDataMap = {
        'email': user.email.toString(),
        'username': user.email.toString(),
        'description': '',
        'image': new Color(0x00000000).value,
        'initColor': new Color(0xFFFFFFFF).value,
        'init': user.email![0].toString(),
      };

      await users
          .doc(_auth.currentUser!.uid)
          .set(userDataMap)
          .then((value) => print('User added'));
    } on FirebaseAuthException catch (e) {
      displayToastMessage(e.code, context);
    }
  }

  // FACEBOOK SIGN IN
  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final loginResult = await FacebookAuth.instance.login();

      if (loginResult.accessToken == null) return;

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      await _auth.signInWithCredential(facebookAuthCredential).then((value) {
        if (value.user != null) {
          if (value.additionalUserInfo!.isNewUser) {
            insertFacebookUser(context, value.user!);
            displayToastMessage('User added', context);
          }
          Navigator.pushNamed(context, Home.routeName);
        }
      });
    } on FirebaseAuthException catch (e) {
      displayToastMessage(e.message!, context); // Displaying the error message
    }
  }

  Future<void> insertFacebookUser(BuildContext context, User user) async {
    try {
      CollectionReference<Map<String, dynamic>> users =
          FirebaseFirestore.instance.collection('users');

      Map<String, dynamic> userDataMap = {
        'email': user.email!.toString(),
        'image': new Color(0x00000000).value,
        'username': user.displayName!.toString(),
        'description': '',
        'init': user.email![0].toString(),
        'initColor': new Color(0xFFFFFFFF).value
      };

      await users
          .doc(_auth.currentUser!.uid)
          .set(userDataMap)
          .then((value) => print('User added'));
    } on FirebaseAuthException catch (e) {
      displayToastMessage(e.code, context);
    }
  }

  // SIGN OUT
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      displayToastMessage(e.message!, context);
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount(BuildContext context) async {
    try {
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      displayToastMessage(e.message!, context);
    }
  }

  Future<void> resetPassword(
      {required String email, required BuildContext context}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      displayToastMessage('Check your mail box', context);
    } on FirebaseAuthMethods catch (e) {
      displayToastMessage(e.toString(), context);
    }
  }
}*/
