import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

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

  void resetPassword() {
    context.read<FirebaseAuthMethods>().resetPassword(
          email: _emailidController.text,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: MaterialApp(
            home: Scaffold(
                key: _scaffoldKey,
                backgroundColor: Colors.black12,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  shadowColor: const Color.fromRGBO(30, 215, 96, 0.9),
                  title: const Text('Reset your password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color.fromRGBO(30, 215, 96, 0.9))),
                  centerTitle: true,
                  leading: GestureDetector(
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color.fromRGBO(30, 215, 96, 0.9),
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
                                        width: 3),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(30, 215, 96, 0.9),
                                        width: 3),
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
                          SizedBox(
                            height: 70,
                            width: 350,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!_emailidController.text.contains('@')) {
                                  displayToastMessage(
                                      'Invalid Email-ID', context);
                                  return;
                                } else if (_emailidController.text.isEmpty) {
                                  displayToastMessage(
                                      'Please. Insert your Email-ID', context);
                                  return;
                                }
                                checkIfExist();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(30, 215, 96, 0.9),
                                surfaceTintColor:
                                    const Color.fromRGBO(30, 215, 96, 0.9),
                                foregroundColor:
                                    const Color.fromRGBO(30, 215, 96, 0.9),
                                shadowColor:
                                    const Color.fromRGBO(30, 215, 96, 0.9),
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
                                'Reset',
                                selectionColor: Colors.white,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                            ),
                          )
                        ]))))));
  }

  Future<void> checkIfExist() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: _emailidController.text)
        .get()
        .then((value) => resetPassword())
        .onError((error, stackTrace) =>
            displayToastMessage('Wait. Email-ID not found', context));
  }
}
