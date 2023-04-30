import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/Home.dart';
import 'package:djparty/page/HomePage.dart';
import 'package:djparty/page/SignIn.dart';
import 'package:djparty/services/FirebaseAuthMethods.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'package:djparty/services/FirebaseAuthMethods.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

DatabaseReference dbRef = FirebaseDatabase.instance.ref();
final FirebaseAuth auth = FirebaseAuth.instance;

final TextEditingController _emailController = TextEditingController();
final TextEditingController _userPasswordController1 = TextEditingController();
final TextEditingController _userPasswordController2 = TextEditingController();
final RoundedLoadingButtonController googleController =
    RoundedLoadingButtonController();

final RoundedLoadingButtonController facebookController =
    RoundedLoadingButtonController();
final RoundedLoadingButtonController registrationController =
    RoundedLoadingButtonController();

class Login extends StatefulWidget {
  static String routeName = 'init';
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;
  bool visible = false;
  bool err = false;

  @override
  void initState() {
    super.initState();
    visible = false;
  }

  @override
  void dispose() {
    _emailController.clear();
    _userPasswordController1.clear();
    _userPasswordController2.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(128, 83, 99, 90),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(128, 38, 40, 39),
        shadowColor: Color.fromARGB(128, 102, 128, 114),
        title: const Text('Create Dj Party account',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Form(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 20, bottom: 0),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    toolbarOptions: const ToolbarOptions(
                        copy: true, paste: true, selectAll: true, cut: true),
                    cursorColor: const Color.fromRGBO(30, 215, 96, 0.9),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: Color.fromRGBO(30, 215, 96, 0.9),
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(128, 53, 74, 62),
                        hintStyle: TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(30, 215, 96, 0.9),
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(30, 215, 96, 0.9),
                              width: 1),
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(30, 215, 96, 0.9)),
                        hintText: ''),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 10.0, bottom: 0.0),
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: _userPasswordController1,
                    obscureText: !_passwordVisible1,
                    style: const TextStyle(color: Colors.white),
                    toolbarOptions: const ToolbarOptions(
                        copy: true, paste: true, selectAll: true, cut: true),
                    cursorColor: const Color.fromRGBO(30, 215, 96, 0.9),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color.fromRGBO(30, 215, 96, 0.9),
                        ),
                        suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible1
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color.fromRGBO(30, 215, 96, 0.9),
                            ),
                            onPressed: () async {
                              setState(() {
                                change(1);
                              });
                              await Future.delayed(const Duration(seconds: 3));
                              setState(() {
                                change(1);
                              });
                            }),
                        filled: true,
                        fillColor: const Color.fromARGB(128, 53, 74, 62),
                        hintStyle: const TextStyle(
                            color: Color.fromRGBO(30, 215, 96, 0.9)),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                              color: Color.fromRGBO(30, 215, 96, 0.9),
                              width: 1),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                              color: Color.fromRGBO(30, 215, 96, 0.9),
                              width: 1),
                        ),
                        labelText: 'New Password',
                        labelStyle: const TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(30, 215, 96, 0.9)),
                        hintText: ''),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 10.0, bottom: 20.0),
                  child: TextFormField(
                    controller: _userPasswordController2,
                    obscureText: !_passwordVisible2,
                    keyboardType: TextInputType.visiblePassword,
                    style: const TextStyle(color: Colors.white),
                    toolbarOptions: const ToolbarOptions(
                        copy: true, paste: true, selectAll: true, cut: true),
                    cursorColor: const Color.fromRGBO(30, 215, 96, 0.9),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color.fromRGBO(30, 215, 96, 0.9),
                        ),
                        suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible2
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color.fromRGBO(30, 215, 96, 0.9),
                            ),
                            onPressed: () async {
                              setState(() {
                                change(2);
                              });
                              await Future.delayed(const Duration(seconds: 3));
                              setState(() {
                                change(2);
                              });
                            }),
                        filled: true,
                        fillColor: const Color.fromARGB(128, 53, 74, 62),
                        hintStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                              color: Color.fromRGBO(30, 215, 96, 0.9),
                              width: 1),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                              color: Color.fromRGBO(30, 215, 96, 0.9),
                              width: 1),
                        ),
                        labelText: 'Confirm New Password',
                        labelStyle: const TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(30, 215, 96, 0.9)),
                        hintText: ''),
                  ),
                ),
                RoundedLoadingButton(
                  onPressed: () {
                    signup();
                  },
                  controller: registrationController,
                  successColor: const Color.fromRGBO(30, 215, 96, 0.9),
                  width: MediaQuery.of(context).size.width * 0.80,
                  elevation: 0,
                  borderRadius: 25,
                  color: const Color.fromRGBO(30, 215, 96, 0.9),
                  child: Wrap(
                    children: const [
                      Icon(
                        FontAwesomeIcons.music,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text("Register",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                RoundedLoadingButton(
                  onPressed: () {
                    handleGoogleSignIn();
                  },
                  controller: googleController,
                  successColor: Colors.red,
                  width: MediaQuery.of(context).size.width * 0.80,
                  elevation: 0,
                  borderRadius: 25,
                  color: Colors.red,
                  child: Wrap(
                    children: const [
                      Icon(
                        FontAwesomeIcons.google,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text("Sign in with Google",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                RoundedLoadingButton(
                  onPressed: () {
                    handleFacebookAuth();
                  },
                  controller: facebookController,
                  successColor: Colors.blue,
                  width: MediaQuery.of(context).size.width * 0.80,
                  elevation: 0,
                  borderRadius: 25,
                  color: Colors.blue,
                  child: Wrap(
                    children: const [
                      Icon(
                        FontAwesomeIcons.facebook,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text("Sign in with Facebook",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Have already an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        handleToSignIn();
                      },
                      child: const Text(
                        ' Log in ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(30, 215, 96, 0.9),
                        ),
                      ),
                    ),
                  ],
                )),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  handleToSignIn() {
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      nextScreenReplace(context, const SignIn());
    });
  }

  // handling facebookauth
  // handling google sigin in
  Future handleFacebookAuth() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      facebookController.reset();
      return;
    }
    await sp.signInWithFacebook().then((value) {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        facebookController.reset();
        return;
      } else if (sp.errorCode == 'Stop') {
        facebookController.reset();

        return;
      }
      // checking whether user exists or not
      sp.checkUserExists().then((value) async {
        if (sp.hasError == true) {
          showInSnackBar(context, sp.errorCode.toString(), Colors.red);
          facebookController.reset();
          return;
        }
        if (value == true) {
          // user exists
          await sp.getUserDataFromFirestore((sp.uid.toString())).then((value) =>
              sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        facebookController.success();
                        handleAfterSignIn();
                      })));
        } else {
          // user does not exist
          sp.saveDataToFirestore().then((value) => sp
              .saveDataToSharedPreferences()
              .then((value) => sp.setSignIn().then((value) {
                    facebookController.success();
                    handleAfterSignIn();
                  })));
        }
      });
    });
  }

  Future handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      googleController.reset();
      return;
    }

    await sp.signInWithGoogle().then((value) {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        googleController.reset();
        return;
      } else if (sp.errorCode == 'Stop') {
        googleController.reset();
        return;
      } else {
        // checking whether user exists or not
        sp.checkUserExists().then((value) async {
          if (value == true) {
            // user exists
            await sp.getUserDataFromFirestore(sp.uid.toString()).then((value) =>
                sp
                    .saveDataToSharedPreferences()
                    .then((value) => sp.setSignIn().then((value) {
                          googleController.success();
                          handleAfterSignIn();
                        })));
          } else {
            // user does not exist
            sp.saveDataToFirestore().then((value) async {
              await sp.getUserDataFromFirestore(sp.uid.toString()).then(
                  (value) => sp
                      .saveDataToSharedPreferences()
                      .then((value) => sp.setSignIn().then((value) {
                            googleController.success();
                            handleAfterSignIn();
                          })));
            });
          }
        });
      }
    });
  }

  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, const HomePage());
    });
  }

  void change(int i) {
    if (i == 1) {
      _passwordVisible1 = !_passwordVisible1;
    } else {
      _passwordVisible2 = !_passwordVisible2;
    }
  }

  Future signup() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      registrationController.reset();
      return;
    }
    //check input validity
    if (!checkvalidity()) {
      registrationController.reset();
      return;
    }

    //try signup
    sp
        .signUpWithEmailPassword(
            email: _emailController.text.trim(),
            password: _userPasswordController1.text.trim())
        .then((value) {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        registrationController.reset();
        return;
      } else {
        sp.saveDataToFirestore().then((value) {
          sp.sendEmailVerification(context).then((value) {
            if (sp.hasError == true) {
              showInSnackBar(context, sp.errorCode.toString(), Colors.red);
              registrationController.reset();
              return;
            } else {
              registrationController.reset();
              showMailBoxCheck();
            }
          });
        });
      }
      _emailController.clear();
      _userPasswordController1.clear();
      _userPasswordController2.clear();
    });
  }

  Future showMailBoxCheck() {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.topSlide,
      showCloseIcon: true,
      dismissOnTouchOutside: false,
      title: "Email Verification",
      desc: "Check your Mail box and verify your email",
    ).show();
  }

  bool checkvalidity() {
    if (!EmailValidator.validate(_emailController.text.trim(), true)) {
      showInSnackBar(context, 'Enter a valid Email', Colors.red);
      return false;
    } else if (_userPasswordController1.text.trim().length < 8) {
      showInSnackBar(
          context, 'Password should be a minimum of 8 characters', Colors.red);
      return false;
    } else if (_userPasswordController1.text.trim() !=
        _userPasswordController2.text.trim()) {
      showInSnackBar(context, 'Passwords don\'t match', Colors.red);
      return false;
    } else {
      return true;
    }
  }
}
