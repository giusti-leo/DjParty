import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';

import './SignInPage.dart';
import './HomePage.dart';

FirebaseAuth auth = FirebaseAuth.instance;
DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("users");

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: _RegisterPage(), routes: {
      'homepage': (context) => HomePage(),
      'login': (context) => const SignInPage(),
    });
  }
}

class _RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<_RegisterPage> {
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;
  static bool visible = false;

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
        body: Scaffold(
          backgroundColor: Colors.blueGrey[900],
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(top: 150.0, bottom: 50),
                    child: const Text('Create Account'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 20, bottom: 0),
                    //  padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(
                            // Based on passwordVisible state choose the icon
                            Icons.mail_outline_rounded,
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.black12,
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: OutlineInputBorder(
                            //gapPadding: 4.0,
                            //borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            //gapPadding: .0,
                            //borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.5),
                          ),
                          labelText: 'Email',
                          hintText: ''),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 10, bottom: 0),
                    //  padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(
                            // Based on passwordVisible state choose the icon
                            Icons.account_circle_outlined,
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.black12,
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: OutlineInputBorder(
                            //gapPadding: 4.0,
                            //borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            //gapPadding: .0,
                            //borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.5),
                          ),
                          labelText: 'Full Name',
                          hintText: ''),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 10.0, bottom: 0.0),
                    //padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _userPasswordController1,
                      obscureText: !_passwordVisible1,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            // Based on passwordVisible state choose the icon
                            Icons.lock_outline_rounded,
                            color: Colors.white70,
                          ),
                          suffixIcon: IconButton(
                              icon: Icon(
                                // Based on passwordVisible state choose the icon
                                _passwordVisible1
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                // Update the state i.e. toogle the state of passwordVisible variable
                                setState(() {
                                  _passwordVisible1 = !_passwordVisible1;
                                });
                              }),
                          filled: true,
                          fillColor: Colors.black12,
                          hintStyle: const TextStyle(color: Colors.white54),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.5),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.5),
                          ),
                          labelText: 'New Password',
                          hintText: ''),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 10.0, bottom: 40.0),
                    //padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: TextFormField(
                      controller: _userPasswordController2,
                      obscureText: !_passwordVisible2,
                      keyboardType: TextInputType.visiblePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            // Based on passwordVisible state choose the icon
                            Icons.lock_outline_rounded,
                            color: Colors.white70,
                          ),
                          suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible2
                                    ? Icons.visibility
                                    : Icons
                                        .visibility_off, // Based on passwordVisible state choose the icon
                                color: Colors.white70,
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
                          enabledBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.5),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.5),
                          ),
                          labelText: 'Confirm New Password',
                          hintText: ''),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 350,
                    //padding: const EdgeInsets.only(bottom: 50.0),
                    // decoration: BoxDecoration(
                    //     color: Colors.deepPurple[900],
                    //     borderRadius: BorderRadius.circular(30)),
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_emailController.text.contains('@')) {
                          displayToastMessage('Enter a valid Email', context);
                        } else if (_usernameController.text.isEmpty) {
                          displayToastMessage('Enter your name', context);
                        } else if (_userPasswordController1.text.length < 8) {
                          displayToastMessage(
                              'Password should be a minimum of 8 characters',
                              context);
                        } else if (_userPasswordController1.text !=
                            _userPasswordController2.text) {
                          displayToastMessage(
                              'Passwords don\'t match', context);
                        } else {
                          setState(() {
                            load();
                            //   showInSnackBar('Processing...',context);
                          });
                          registerNewUser(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black45,
                        onPrimary: Colors.white,
                        shadowColor: Colors.black45,
                        elevation: 8,
                        //side: BorderSide(color: Colors.white70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(
                            color: Colors.white70,
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text('Register'),
                    ),
                  ),
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: visible,
                    child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
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

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> registerNewUser(BuildContext context) async {
    User? currentuser;
    try {
      currentuser = (await auth.createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _userPasswordController1.text.trim()))
          .user;

      if (currentuser != null) {
        dbRef.child(currentuser.uid);
        Map userDataMap = {
          'name': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
        };
        dbRef.child(currentuser.uid).set(userDataMap);
        _formKey.currentState?.initState();

        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => HomePage()));

        displayToastMessage('Account Created', context);
      } else {
        setState(() {
          load();
        });
        displayToastMessage('Account has not been created', context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        load();
      });
      displayToastMessage(e.code, context);
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
  ScaffoldMessenger.of(context)
      .showSnackBar(new SnackBar(content: new Text(value)));
}
