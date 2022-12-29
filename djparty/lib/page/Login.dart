import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/SignIn.dart';
import 'package:djparty/services/FirebaseAuthMethods.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

DatabaseReference dbRef = FirebaseDatabase.instance.ref();
final FirebaseAuth auth = FirebaseAuth.instance;

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _usernameController = TextEditingController();
final TextEditingController _userPasswordController1 = TextEditingController();
final TextEditingController _userPasswordController2 = TextEditingController();

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black,
        shadowColor: Colors.greenAccent,
        title: const Text('Create Dj Party account',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.greenAccent)),
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
                    decoration: const InputDecoration(
                        prefixIcon: Icon(
                          // Based on passwordVisible state choose the icon
                          Icons.mail_outline_rounded,
                          color: Colors.greenAccent,
                        ),
                        filled: true,
                        fillColor: Colors.black12,
                        hintStyle: TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.greenAccent, width: 3),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.greenAccent, width: 3),
                        ),
                        labelText: 'Email',
                        labelStyle:
                            TextStyle(fontSize: 14, color: Colors.greenAccent),
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
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          // Based on passwordVisible state choose the icon
                          Icons.lock_outline_rounded,
                          color: Colors.greenAccent,
                        ),
                        suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _passwordVisible1
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.greenAccent,
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
                        fillColor: Colors.black12,
                        hintStyle: const TextStyle(color: Colors.greenAccent),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide:
                              BorderSide(color: Colors.greenAccent, width: 3),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide:
                              BorderSide(color: Colors.greenAccent, width: 3),
                        ),
                        labelText: 'New Password',
                        labelStyle: const TextStyle(
                            fontSize: 16, color: Colors.greenAccent),
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
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          // Based on passwordVisible state choose the icon
                          Icons.lock_outline_rounded,
                          color: Colors.greenAccent,
                        ),
                        suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible2
                                  ? Icons.visibility
                                  : Icons
                                      .visibility_off, // Based on passwordVisible state choose the icon
                              color: Colors.greenAccent,
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
                        fillColor: Colors.black12,
                        hintStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide:
                              BorderSide(color: Colors.greenAccent, width: 3),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide:
                              BorderSide(color: Colors.greenAccent, width: 3),
                        ),
                        labelText: 'Confirm New Password',
                        labelStyle: const TextStyle(
                            fontSize: 16, color: Colors.greenAccent),
                        hintText: ''),
                  ),
                ),
                SizedBox(
                  height: 70,
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!EmailValidator.validate(
                          _emailController.text, true)) {
                        displayToastMessage('Enter a valid Email', context);
                        err = true;
                      } else if (_userPasswordController1.text.length < 8) {
                        displayToastMessage(
                            'Password should be a minimum of 8 characters',
                            context);
                        err = true;
                      } else if (_userPasswordController1.text !=
                          _userPasswordController2.text) {
                        displayToastMessage('Passwords don\'t match', context);
                        err = true;
                      } else {
                        err = false;
                      }
                      if (err == false) {
                        registerNewUser(context);
                        Navigator.pushNamed(context, SignIn.routeName);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      surfaceTintColor: Colors.greenAccent,
                      foregroundColor: Colors.greenAccent,
                      shadowColor: Colors.greenAccent,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                          color: Color.fromARGB(184, 255, 255, 255),
                          width: 5,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      selectionColor: Colors.black,
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, SignIn.routeName);
                    },
                    child: const Text(
                      '----------------------- or -----------------------',
                      selectionColor: Colors.white,
                      style: TextStyle(fontSize: 16, color: Colors.greenAccent),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      side: const BorderSide(
                          color: Color.fromARGB(255, 26, 80, 28), width: 5),
                    ),
                    onPressed: () async {
                      context
                          .read<FirebaseAuthMethods>()
                          .signInWithGoogle(context);
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.greenAccent,
                    ),
                    label: const Text(
                      "Sign Up with Google",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    )),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      side: const BorderSide(
                          color: Color.fromARGB(255, 26, 80, 28), width: 5),
                    ),
                    onPressed: () async {
                      context
                          .read<FirebaseAuthMethods>()
                          .signInWithFacebook(context);
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.facebook,
                      color: Colors.greenAccent,
                    ),
                    label: const Text(
                      "Sign Up with Facebook",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    )),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, SignIn.routeName);
                    },
                    child: const Text(
                      'Have already an account? Log in ',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void change(int i) {
    if (i == 1) {
      _passwordVisible1 = !_passwordVisible1;
    } else {
      _passwordVisible2 = !_passwordVisible2;
    }
  }
}

Future<void> registerNewUser(BuildContext context) async {
  User? currentuser;

  try {
    currentuser = (await auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _userPasswordController1.text.trim()))
        .user;

    CollectionReference<Map<String, dynamic>> users =
        FirebaseFirestore.instance.collection('users');

    if (currentuser != null) {
      Map<String, dynamic> userDataMap = {
        'name': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
      };

      await users
          .doc(currentuser.uid)
          .set(userDataMap)
          .then((value) => print('User added'));

      //_formKey.currentState?.initState();

      displayToastMessage('Account Created', context);
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      displayToastMessage('The password provided is too weak.', context);
    } else if (e.code == 'email-already-in-use') {
      displayToastMessage(
          'The account already exists for that email.', context);
    }
  }
}

displayToastMessage(String msg, BuildContext context) {
  Fluttertoast.showToast(msg: msg);
}

void showInSnackBar(String value, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
}
