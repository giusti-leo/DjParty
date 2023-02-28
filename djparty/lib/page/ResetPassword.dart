import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/Login.dart';
import 'package:djparty/page/SignIn.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../services/FirebaseAuthMethods.dart';

class ResetPassword extends StatefulWidget {
  static String routeName = 'resetPassword';

  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _emailidController = TextEditingController();

  final RoundedLoadingButtonController resetController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color.fromARGB(128, 53, 74, 62),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(128, 53, 74, 62),
              shadowColor: const Color.fromARGB(128, 83, 99, 90),
              title: const Text('Reset your password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white)),
              centerTitle: true,
              leading: GestureDetector(
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextFormField(
                          controller: _emailidController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              focusColor: Color.fromRGBO(30, 215, 96, 0.9),
                              prefixIcon: Icon(
                                Icons.mail_outline_rounded,
                                color: Color.fromRGBO(30, 215, 96, 0.9),
                              ),
                              filled: true,
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
                                  color: Color.fromRGBO(30, 215, 96, 0.9),
                                  fontSize: 16),
                              iconColor: Color.fromRGBO(30, 215, 96, 0.9),
                              hintText: ''),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      RoundedLoadingButton(
                        onPressed: () {
                          passwordReset();
                        },
                        controller: resetController,
                        successColor: Color.fromRGBO(30, 215, 96, 0.9),
                        width: MediaQuery.of(context).size.width * 0.80,
                        elevation: 0,
                        borderRadius: 25,
                        color: Color.fromRGBO(30, 215, 96, 0.9),
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
                            Text("Reset password",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ])))));
  }

  Future passwordReset() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      resetController.reset();
      return;
    }

    if (!isValid()) {
      resetController.reset();
      return;
    }

    sp.resetPassword(_emailidController.text).then((value) {
      if (sp.hasError) {
        showInSnackBar(context, sp.errorCode!.toString(), Colors.red);
        resetController.reset();
        return;
      } else {
        resetController.reset();
        showMailBoxCheck();
      }
    });
  }

  Future showMailBoxCheck() {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.topSlide,
      showCloseIcon: true,
      dismissOnTouchOutside: false,
      title: "Password Reset Request",
      desc: "Check your Mail box",
    ).show();
  }

  handleAfterReset() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, const SignIn());
    });
  }

  bool isValid() {
    if (!_emailidController.text.contains('@')) {
      displayToastMessage(context, 'Invalid Email-ID', Colors.red);

      return false;
    } else if (_emailidController.text.isEmpty) {
      displayToastMessage(context, 'Please. Insert your Email-ID', Colors.red);

      return false;
    } else {
      return true;
    }
  }
}
