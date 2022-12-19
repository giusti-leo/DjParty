import 'package:djparty/page/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:djparty/animations/ScaleRoute.dart';

import 'package:flutter/scheduler.dart';

import 'RegistrationPage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  static bool _passwordVisible = false;
  static bool visible = false;
  static bool gvisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    visible = false;
    gvisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        home: Scaffold(
          key: _scaffoldKey,
          // backgroundColor:  Colors.transparent,
          backgroundColor: Colors.blueGrey[900],
          // backgroundColor: Colors.black45,
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 50.0),
                    child: Center(
                      child: Container(
                          //padding:
                          //  const EdgeInsets.only(top: 30.0, bottom: 30.0),
                          width: 200,
                          height: 150,
                          decoration: BoxDecoration(
                              //color: Colors.white10,
                              borderRadius: BorderRadius.circular(10.0)),
                          child:
                              Image.asset('assets/images/logo.jpg', scale: 4)),
                    ),
                  ),
                  Padding(
                    //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: _emailidController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.black12,
                          enabledBorder: OutlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
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
                        left: 15.0, right: 15.0, top: 10.0, bottom: 30.0),
                    //padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white70,
                          ),
                          suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              }),
                          filled: true,
                          fillColor: Colors.black12,
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
                                BorderSide(color: Colors.white, width: 2),
                          ),
                          labelText: 'Password',
                          hintText: ''),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 350,
                    // decoration: BoxDecoration(
                    //     color: Colors.deepPurple[900],
                    //     borderRadius: BorderRadius.circular(30)),
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_emailidController.text.contains('@')) {
                          displayToastMessage('Invalid Email-ID', context);
                        } else if (_passwordController.text.length < 8) {
                          displayToastMessage(
                              'Password should be a minimum of 8 characters',
                              context);
                        } else {
                          setState(() {
                            visible = load(visible);
                          });
                          login();
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
                      child: const Text('Login'),
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
                              width: 320,
                              margin: const EdgeInsets.only(),
                              child: LinearProgressIndicator(
                                minHeight: 2,
                                backgroundColor: Colors.blueGrey[800],
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.white),
                              )))),
                  SizedBox(
                    height: 30,
                    width: 300,
                    child: TextButton(
                      onPressed: () {
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const Register()));
                          //ResetPass()));
                        });
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  /*
                  Container(
                    height: 60,
                    width: 350,
                    padding: const EdgeInsets.only(top: 10),
                    // decoration: BoxDecoration(
                    //     color: Colors.deepPurple[900],
                    //     borderRadius: BorderRadius.circular(30)),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          gvisible = load(gvisible);
                        });
                        googleSignIn(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Row(
                          children: <Widget>[
                            Image(
                              image: AssetImage("assets/google_logo.png"),
                              height: 30.0,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 40, right: 55),
                              child: Text(
                                'Sign in with Google',
                                style: GoogleFonts.workSans(
                                  fontSize: 19,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  backgroundColor: Colors.transparent,
                                  letterSpacing: 0.0,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.black45,
                        primary: Colors.transparent,
                        onPrimary: Colors.white,
                        shadowColor: Colors.black45,
                        elevation: 8,
                        //side: BorderSide(color: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                            color: Colors.white70,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  */
                  Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: gvisible,
                      child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: Container(
                              width: 320,
                              margin: const EdgeInsets.only(),
                              child: LinearProgressIndicator(
                                minHeight: 2,
                                backgroundColor: Colors.blueGrey[800],
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.white),
                              )))),
                  SizedBox(
                    height: 30,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const Register()));
                      },
                      child: const Text(
                        'New User? Create Account',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("users");

  Future<void> login() async {
    final formState = _formKey.currentState;
    if (formState!.validate()) {
      formState.save();
      try {
        await auth.signInWithEmailAndPassword(
            email: _emailidController.text.trim(),
            password: _passwordController.text.trim());

        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => HomePage()));
          visible = !visible;
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          visible = load(visible);
        });
        displayToastMessage(e.code, context);
      }
    }
  }

  bool load(visible) {
    return visible = !visible;
  }

  @override
  void dispose() {
    _emailidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
