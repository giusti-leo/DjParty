import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/main.dart';
import 'package:djparty/page/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:email_validator/email_validator.dart';

import 'SignIn.dart';
import './HomePage.dart';

class SignUp extends StatefulWidget {
  static String routeName = '/signup';
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;
  static bool visible = false;
  bool err = false;

  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    visible = false;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _userPasswordController1 =
      TextEditingController();
  final TextEditingController _userPasswordController2 =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          shadowColor: mainGreen,
          title: Text('Registration',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 24, color: mainGreen)),
          centerTitle: true,
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.pushNamed(context, Login.routeName);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 150.0, bottom: 50),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                        fontSize: 25,
                        color: mainGreen,
                        fontStyle: FontStyle.normal),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 20, bottom: 0),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          // Based on passwordVisible state choose the icon
                          Icons.mail_outline_rounded,
                          color: mainGreen,
                        ),
                        filled: true,
                        fillColor: Colors.black12,
                        hintStyle: TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: mainGreen, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: mainGreen, width: 1.5),
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(fontSize: 14, color: mainGreen),
                        hintText: ''),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 10, bottom: 0),
                  child: TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: Colors.greenAccent),
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          // Based on passwordVisible state choose the icon
                          Icons.account_circle_outlined,
                          color: mainGreen,
                        ),
                        filled: true,
                        fillColor: Colors.black12,
                        hintStyle: TextStyle(color: mainGreen),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: mainGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: mainGreen),
                        ),
                        labelText: 'Full Name',
                        labelStyle: TextStyle(fontSize: 16, color: mainGreen),
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
                        prefixIcon: Icon(
                          // Based on passwordVisible state choose the icon
                          Icons.lock_outline_rounded,
                          color: mainGreen,
                        ),
                        suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _passwordVisible1
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: mainGreen,
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                _passwordVisible1 = !_passwordVisible1;
                              });
                            }),
                        filled: true,
                        fillColor: Colors.black12,
                        hintStyle: TextStyle(color: mainGreen),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: mainGreen, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: mainGreen, width: 1.5),
                        ),
                        labelText: 'New Password',
                        labelStyle: TextStyle(fontSize: 16, color: mainGreen),
                        hintText: ''),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 10.0, bottom: 40.0),
                  child: TextFormField(
                    controller: _userPasswordController2,
                    obscureText: !_passwordVisible2,
                    keyboardType: TextInputType.visiblePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          // Based on passwordVisible state choose the icon
                          Icons.lock_outline_rounded,
                          color: mainGreen,
                        ),
                        suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible2
                                  ? Icons.visibility
                                  : Icons
                                      .visibility_off, // Based on passwordVisible state choose the icon
                              color: mainGreen,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible2 =
                                    !_passwordVisible2; // Update the state i.e. toogle the state of passwordVisible variable
                              });
                            }),
                        filled: true,
                        fillColor: Colors.black12,
                        hintStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: mainGreen, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: mainGreen, width: 1.5),
                        ),
                        labelText: 'Confirm New Password',
                        labelStyle: TextStyle(fontSize: 16, color: mainGreen),
                        hintText: ''),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!EmailValidator.validate(
                          _emailController.text, true)) {
                        displayToastMessage('Enter a valid Email', context);
                        err = true;
                      } else if (_usernameController.text.isEmpty) {
                        displayToastMessage('Enter your name', context);
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
                        setState(() {
                          load();
                          err = false;
                        });
                      }
                      if (err == false) {
                        registerNewUser(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignIn()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      surfaceTintColor: mainGreen,
                      foregroundColor: mainGreen,
                      shadowColor: mainGreen,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(
                          color: mainGreen,
                          width: 5,
                        ),
                      ),
                    ),
                    child: Text(
                      'Register',
                      selectionColor: mainGreen,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: visible,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Container(
                          width: 290,
                          margin: const EdgeInsets.only(),
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            backgroundColor: Colors.blueGrey[800],
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                          ))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _emailController.dispose();
    _userPasswordController1.dispose();
    _userPasswordController2.dispose();
    _usernameController.dispose();
    super.dispose();
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

  void load() {
    visible = !visible;
  }
}

displayToastMessage(String msg, BuildContext context) {
  Fluttertoast.showToast(msg: msg);
}

void showInSnackBar(String value, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
}
