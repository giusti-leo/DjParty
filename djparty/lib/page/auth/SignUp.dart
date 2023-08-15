import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/lobby/HomePage.dart';
import 'package:djparty/page/auth/Login.dart';
import 'package:djparty/page/auth/ResetPassword.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class SignIn extends StatefulWidget {
  static String routeName = '/login-email-password';
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userPasswordController1 =
      TextEditingController();
  final TextEditingController _userPasswordController2 =
      TextEditingController();

  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextStyle styleHeading1 =
      const TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.clear();
    _userPasswordController1.clear();
    _userPasswordController2.clear();
    super.dispose();
  }

  handleStepBack() {
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      nextScreenReplace(context, const Login());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backGround,
        body: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: isMobile ? MediaQuery.of(context).size.width : 600,
            height: isMobile ? MediaQuery.of(context).size.height : 1000,
            child: Form(
              key: _formKey,
              child: _buildSignInForm(context),
            ),
          ),
        ));
  }

  Widget heading1(String text, double x, double y) {
    return Positioned(
      top: y,
      left: x,
      child: Text(text, selectionColor: Colors.white, style: styleHeading1),
    );
  }

  Widget _buildSignInForm(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: ListView(children: [
          const SizedBox(height: 40.0),
          SizedBox(
            height: 175.0,
            width: 200.0,
            child: isMobile
                ? Stack(
                    children: [
                      heading1('Registration', 0.0, 0.0),
                    ],
                  )
                : const Stack(
                    children: [
                      Positioned(
                        bottom: 10,
                        child: Text('Registration',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20.0),
          emailField(),
          const SizedBox(height: 5.0),
          passwordField(),
          const SizedBox(height: 5.0),
          passwordConfirmField(),
          const SizedBox(height: 20.0),
          submit(),
          const SizedBox(height: 10.0),
          Center(
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
                child: Text(
                  ' Log in ',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: mainGreen),
                ),
              ),
            ],
          )),
        ]));
  }

  Widget emailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      toolbarOptions: const ToolbarOptions(
          copy: true, paste: true, selectAll: true, cut: true),
      cursorColor: mainGreen,
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: mainGreen,
          ),
          filled: true,
          fillColor: backGround,
          hintStyle: const TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: mainGreen, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: mainGreen, width: 1),
          ),
          labelText: 'Email',
          labelStyle: TextStyle(fontSize: 14, color: mainGreen),
          hintText: ''),
    );
  }

  Widget passwordField() {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      controller: _userPasswordController1,
      obscureText: !_passwordVisible1,
      style: const TextStyle(color: Colors.white),
      toolbarOptions: const ToolbarOptions(
          copy: true, paste: true, selectAll: true, cut: true),
      cursorColor: mainGreen,
      decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: Color.fromARGB(228, 53, 191, 101),
          ),
          suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible1 ? Icons.visibility : Icons.visibility_off,
                color: mainGreen,
              ),
              onPressed: () async {
                setState(() {
                  change(1);
                });
              }),
          filled: true,
          fillColor: backGround,
          hintStyle: TextStyle(color: mainGreen),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: mainGreen, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: mainGreen, width: 1),
          ),
          labelText: 'New Password',
          labelStyle: const TextStyle(
              fontSize: 16, color: Color.fromARGB(228, 53, 191, 101)),
          hintText: ''),
    );
  }

  Widget passwordConfirmField() {
    return TextFormField(
      controller: _userPasswordController2,
      obscureText: !_passwordVisible2,
      keyboardType: TextInputType.visiblePassword,
      style: const TextStyle(color: Colors.white),
      toolbarOptions: const ToolbarOptions(
          copy: true, paste: true, selectAll: true, cut: true),
      cursorColor: mainGreen,
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: mainGreen,
          ),
          suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible2 ? Icons.visibility : Icons.visibility_off,
                color: mainGreen,
              ),
              onPressed: () async {
                setState(() {
                  change(2);
                });
              }),
          filled: true,
          fillColor: backGround,
          hintStyle: const TextStyle(color: Colors.white54),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: mainGreen, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: mainGreen, width: 1),
          ),
          labelText: 'Confirm New Password',
          labelStyle: TextStyle(fontSize: 16, color: mainGreen),
          hintText: ''),
    );
  }

  Widget submit() {
    return RoundedLoadingButton(
      onPressed: () {
        signup();
      },
      controller: registrationController,
      successColor: mainGreen,
      width: 320,
      elevation: 0,
      borderRadius: 25,
      color: mainGreen,
      child: const Wrap(
        children: [
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
    );
  }

  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(
          context,
          HomePage(
              loggedUser: FirebaseAuth.instance.currentUser!,
              db: FirebaseFirestore.instance));
    });
  }

  void change(int i) {
    if (i == 1) {
      _passwordVisible1 = !_passwordVisible1;
    } else {
      _passwordVisible2 = !_passwordVisible2;
    }
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

  handleToSignIn() {
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      nextScreenReplace(context, const Login());
    });
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
}
