import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:djparty/page/auth/Login.dart';
import 'package:djparty/page/auth/SignUp.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ResetPassword extends StatefulWidget {
  static String routeName = 'resetPassword';

  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);

  TextStyle styleHeading1 =
      const TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold);

  final TextEditingController _emailidController = TextEditingController();

  final RoundedLoadingButtonController resetController =
      RoundedLoadingButtonController();

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
              child: _buildResetForm(context),
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

  Widget _buildResetForm(BuildContext context) {
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
                      heading1('Password', 0.0, 0.0),
                      heading1('Reset', 25.0, 75.0),
                    ],
                  )
                : const Stack(
                    children: [
                      Positioned(
                        bottom: 10,
                        child: Text('Password Reset',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20.0),
          emailField(),
          const SizedBox(height: 20.0),
          submit(),
          const SizedBox(height: 20.0),
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Back to",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  handleToLogin();
                },
                child: Text(
                  ' Login',
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

  handleToLogin() {
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      nextScreenReplace(context, const Login());
    });
  }

  Widget submit() {
    return RoundedLoadingButton(
      onPressed: () {
        passwordReset();
      },
      controller: resetController,
      successColor: mainGreen,
      width: MediaQuery.of(context).size.width * 0.80,
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
          Text("Reset password",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget emailField() {
    return TextFormField(
      controller: _emailidController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          focusColor: mainGreen,
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: mainGreen,
          ),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: mainGreen, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: mainGreen, width: 1),
          ),
          labelText: 'Email',
          labelStyle: TextStyle(color: mainGreen, fontSize: 16),
          iconColor: mainGreen,
          hintText: ''),
    );
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
