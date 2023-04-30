import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/services/FirebaseAuthMethods.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInProvider extends ChangeNotifier {
  // instance of firebaseauth, facebook and google
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  // User Data

  // hasError, errorCode, provider, uid, email, name, imageUrl
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _name;
  String? get name => _name;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  String? _description;
  String? get description => _description;

  int? _image;
  int? get image => _image;

  String? _init;
  String? get init => _init;

  int? _initColor;
  int? get initColor => _initColor;

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future setSignOut() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("signed_out", true);
    _isSignedIn = false;

    notifyListeners();
  }

  Future sendEmailVerification(BuildContext context) async {
    try {
      await firebaseAuth.currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future signInWithEmailPassword(
      {required String email, required String password}) async {
    try {
      await firebaseAuth
          .signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      )
          .then((value) {
        if (!value.user!.emailVerified) {
          _errorCode = "Check your email and verify your account!";
          _hasError = true;
          notifyListeners();
          return;
        }

        setSignIn();
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          _errorCode = 'Credentials error';
          _hasError = true;
          notifyListeners();
          break;

        case 'user-not-found':
          _errorCode = 'No account with this username';
          _hasError = true;
          notifyListeners();
          break;

        case 'invalid-email':
          _errorCode = 'Invalid username';
          _hasError = true;
          notifyListeners();
          break;

        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // saving the values
      _name = email.split('@')[0];
      _email = email;
      _imageUrl = '';
      _uid = firebaseAuth.currentUser!.uid;
      _hasError = false;
      _provider = "EMAIL_PASSWORD";
      _description = '';
      _image = 0;
      _init = email[0];
      _initColor = const Color.fromARGB(255, 0, 0, 0).value;

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "account-exists-with-different-credential":
          _errorCode =
              "You already have an account with us. Use correct provider";
          _hasError = true;
          notifyListeners();
          break;

        case "email-already-in-use":
          _errorCode = "Email already in use";
          _hasError = true;
          notifyListeners();
          break;

        case "null":
          _errorCode = "Some unexpected error while trying to sign in";
          _hasError = true;
          notifyListeners();
          break;

        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<OAuthCredential> getFacebookCredentials() async {
    OAuthCredential oAuthCredential = AuthCredential as OAuthCredential;
    try {
      final LoginResult result = await facebookAuth.login();

      if (result.status == LoginStatus.success) {
        OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        return credential;
      }
      return oAuthCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "null":
          _errorCode = "Some unexpected error while trying to sign in";
          _hasError = true;

          notifyListeners();
          return oAuthCredential;

        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();

          return oAuthCredential;
      }
    }
  }

  FutureOr<AuthCredential?> getGoogleCredentials() async {
    AuthCredential? authCredential;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        // executing our authentication

        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        return credential;
      }
      return authCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "account-exists-with-different-credential":
          _errorCode =
              "You already have an account with us. Use correct provider";
          _hasError = true;
          notifyListeners();
          return authCredential;

        case "null":
          _errorCode = "Some unexpected error while trying to sign in";
          _hasError = true;

          notifyListeners();
          return authCredential;

        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();

          return authCredential;
      }
    }
  }

  // sign in with google
  Future signInWithGoogle() async {
    try {
      AuthCredential? credential = await getGoogleCredentials();

      final User userDetails =
          (await firebaseAuth.signInWithCredential(credential!)).user!;

      _name = userDetails.displayName;
      _email = userDetails.email;
      _imageUrl = userDetails.photoURL;
      _provider = userDetails.providerData.toString();
      _uid = userDetails.uid;
      _image = 0;
      _init = userDetails.email![0];
      _initColor = const Color.fromARGB(255, 0, 0, 0).value;

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        default:
          _errorCode = 'Stop';
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> update(
    String username,
    String description,
  ) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        'username': username,
        'description': description,
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> updateSoft(String username, String description) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        'username': username,
        'description': description,
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  // sign in with facebook
  Future signInWithFacebook() async {
    try {
      final LoginResult result = await facebookAuth.login();

      final graphResponse = await http.get(Uri.parse(
          'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${result.accessToken!.token}'));

      final profile = jsonDecode(graphResponse.body);

      if (result.status == LoginStatus.success) {
        final credential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        final userDetails = (await firebaseAuth
                .signInWithCredential(credential)
                .catchError((e) async {
          if (e.code == 'account-exists-with-different-credential') {
            var email = profile["email"];
            final signInMethods =
                await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
            if (signInMethods.contains("google.com")) {
              final googleCredentials = await getGoogleCredentials();

              final userDetails =
                  (await firebaseAuth.signInWithCredential(googleCredentials!))
                      .user!;
              if (userDetails.email == e.email) {
                await userDetails.linkWithCredential(e.credential);
              }
            }
          }
        }))
            .user;

        // saving the values
        _name = profile['name'];
        _email = profile['email'];
        _imageUrl = profile['picture']['data']['url'];
        _uid = userDetails!.uid;
        _hasError = false;
        _provider = "FACEBOOK";
        _description = '';
        _image = const Color.fromARGB(255, 255, 255, 255).value;
        _init = profile['email']![0];
        _initColor = const Color.fromARGB(255, 0, 0, 0).value;
        notifyListeners();
      } else {
        _errorCode = 'Stop';
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "account-exists-with-different-credential":
          _errorCode =
              "You already have an account with us. Use correct provider";
          _hasError = true;

          notifyListeners();
          break;

        case "null":
          _errorCode = "Some unexpected error while trying to sign in";
          _hasError = true;
          notifyListeners();
          break;
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  // ENTRY FOR CLOUDFIRESTORE
  Future getUserDataFromFirestore(String uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) => {
              _name = snapshot['username'],
              _uid = snapshot['uid'],
              _email = snapshot['email'],
              _imageUrl = snapshot['image_url'],
              _provider = snapshot['provider'],
              _description = snapshot['description'],
              _image = snapshot['image'],
              _init = snapshot['init'],
              _initColor = snapshot['initColor'],
            });
  }

  Future resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future saveDataToFirestore() async {
    final DocumentReference r =
        FirebaseFirestore.instance.collection("users").doc(uid);
    await r.set({
      "email": _email,
      "uid": _uid,
      "username": _name,
      "image_url": _imageUrl,
      'init': _init,
      "description": '',
      'image': new Color(0x00000000).value,
      'initColor': new Color(0xFFFFFFFF).value,
      "provider": _provider,
    });
    notifyListeners();
  }

  Future saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString('username', _name!);
    await s.setString('email', _email!);
    await s.setString('uid', _uid!);
    await s.setString('image_url', _imageUrl!);
    await s.setString('provider', _provider!);
    await s.setString('description', _description!);
    await s.setInt('image', _image!);
    await s.setString('init', _init!);
    await s.setInt('initColor', _initColor!);
    notifyListeners();
  }

  Future getDataFromSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _name = s.getString('username');
    _email = s.getString('email');
    _imageUrl = s.getString('image_url');
    _uid = s.getString('uid');
    _provider = s.getString('provider');
    _description = s.getString('description');
    _image = s.getInt('image');
    _init = s.getString('init');
    _initColor = s.getInt('initColor');
    notifyListeners();
  }

  // checkUser exists or not in cloudfirestore
  Future<bool> checkUserExists() async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snap.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  Future clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
  }

  // signout
  Future userSignOut() async {
    firebaseAuth.signOut;
    await googleSignIn.signOut();
    await facebookAuth.logOut();
    setSignOut();
    clearStoredData();

    notifyListeners();
    // clear all storage information
  }
}
