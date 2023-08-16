import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/entities/Entities.dart';
import 'package:djparty/page/auth/Login.dart';
import 'package:djparty/page/lobby/HomePage.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class InsertCode extends StatefulWidget {
  User loggedUser;
  FirebaseFirestore db;

  InsertCode({super.key, required this.loggedUser, required this.db});

  @override
  State<InsertCode> createState() => _InsertCodeState();
}

class _InsertCodeState extends State<InsertCode> {
  final TextEditingController textController = TextEditingController();
  bool err = false;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: backGround,
        title: const Text(
          'Join Party',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: backGround,
      body: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: isMobile ? MediaQuery.of(context).size.width * 0.8 : 600,
          height: isMobile ? MediaQuery.of(context).size.height * 0.8 : 1000,
          child: Form(key: _formKey, child: insertCode()),
        ),
      ),
    ));
  }

  Widget insertCode() {
    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: ListView(children: [
              const SizedBox(height: 40.0),
              buildTextField(context),
            ])));
  }

  Widget buildTextField(BuildContext context) => SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextFormField(
        controller: textController,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        decoration: InputDecoration(
          hintText: 'PartyCode',
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: mainGreen,
            ),
          ),
          suffixIcon: IconButton(
              color: mainGreen,
              icon: const Icon(Icons.done, size: 30),
              onPressed: () {
                handleInsert();
              }),
        ),
      ));

  Future handleInsert() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final FirebaseRequests fp = FirebaseRequests(db: widget.db);

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", alertColor);
      return;
    }

    if (!validityCode()) {
      return;
    }

    await sp.checkUserExists(widget.loggedUser.uid).then((value) async {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), alertColor);
        return;
      }
      if (value == false) {
        showInSnackBar(context, 'The user data does not exists', alertColor);
        return;
      }

      await sp.getUserDataFromFirestore(widget.loggedUser.uid).then((value) {
        if (sp.hasError == true) {
          showInSnackBar(context, sp.errorCode.toString(), alertColor);
          return;
        }
        sp.saveDataToSharedPreferences().then((value) async {
          await fp.checkPartyExists(code: textController.text).then((value) {
            if (fp.hasError == true) {
              showInSnackBar(context, sp.errorCode.toString(), alertColor);
              return;
            }
            if (value == false) {
              showInSnackBar(context,
                  'This code does not correspond to any party', alertColor);
              return;
            } else {
              fp.getPartyDataFromFirestore(textController.text).then((value) =>
                  fp.saveDataToSharedPreferences().then((value) => fp
                          .isUserInsideParty(
                              widget.loggedUser.uid, textController.text)
                          .then((value) {
                        if (value == true) {
                          displayToastMessage(context,
                              'You are already part of the party', mainGreen);
                          return;
                        }

                        widget.db
                            .collection("users")
                            .doc(uid)
                            .get()
                            .then((value) {
                          Person person = Person.getTrackFromFirestore(value);

                          fp
                              .userJoinParty(
                                  widget.loggedUser.uid,
                                  textController.text,
                                  person.username!,
                                  person.imageUrl!,
                                  0)
                              .then((value) {
                            if (fp.hasError) {
                              showInSnackBar(
                                  context, sp.errorCode.toString(), alertColor);
                              return;
                            }
                            displayToastMessage(
                                context, 'You join the party', mainGreen);
                            handleAfterSubmit();
                            return;
                          });
                        });
                      })));
            }
          });
        });
      });
    });
  }

  handleAfterSubmit() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(
          context,
          HomePage(
            loggedUser: FirebaseAuth.instance.currentUser!,
            db: FirebaseFirestore.instance,
          ));
    });
  }

  bool validityCode() {
    if (textController.text.length != 5) {
      displayToastMessage(
          context, 'Party Code is 5 characters long', alertColor);
      return false;
    } else {
      return true;
    }
  }
}

class ScannerScreen extends StatefulWidget {
  User loggedUser;
  FirebaseFirestore db;

  ScannerScreen({super.key, required this.loggedUser, required this.db});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey _gLobalkey = GlobalKey();
  QRViewController? controller;
  Barcode? result;

  String error = '';
  String newError = '';

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  void qr(QRViewController controller) {
    if (Platform.isAndroid) {
      controller.resumeCamera();
    }
    this.controller = controller;
    controller.scannedDataStream.listen((event) {
      setState(() {
        result = event;
      });
      handleInsert();
    });
  }

  bool validityCode() {
    if (result!.code.toString().contains('//')) {
      newError = 'This Qr is a link';
      return false;
    }
    if (result!.code.toString().length != 5) {
      newError = 'Sorry, this Qr is not a PartyCode';
      return false;
    } else {
      return true;
    }
  }

  Future handleInsert() async {
    setState(() {
      controller!.pauseCamera();
    });

    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final FirebaseRequests fp = FirebaseRequests(db: widget.db);

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      return;
    }

    if (!validityCode()) {
      if (isErrorNew()) {
        displayToastMessage(context, error, alertColor);
      }
      setState(() {
        controller!.pauseCamera();
        handleStepBack();
      });
      return;
    }

    await sp.checkUserExists(widget.loggedUser.uid).then((value) async {
      if (sp.hasError == true) {
        displayToastMessage(context, sp.errorCode.toString(), alertColor);
        return;
      }
      if (value == false) {
        displayToastMessage(
            context, 'The user data does not exists', alertColor);
        return;
      }

      await sp.getUserDataFromFirestore(widget.loggedUser.uid).then((value) {
        if (sp.hasError == true) {
          displayToastMessage(context, sp.errorCode.toString(), alertColor);
          return;
        }
        sp.saveDataToSharedPreferences().then((value) async {
          await fp
              .checkPartyExists(code: result!.code.toString())
              .then((value) {
            if (fp.hasError == true) {
              displayToastMessage(context, sp.errorCode.toString(), alertColor);
              controller!.pauseCamera();
              handleStepBack();
              return;
            }
            if (value == false) {
              displayToastMessage(context,
                  'This code does not correspond to any party', alertColor);
              controller!.pauseCamera();
              handleStepBack();

              return;
            }
            fp.getPartyDataFromFirestore(result!.code.toString()).then(
                (value) => fp.saveDataToSharedPreferences().then((value) => fp
                        .isUserInsideParty(
                            widget.loggedUser.uid, result!.code.toString())
                        .then((value) {
                      if (value == true) {
                        displayToastMessage(context,
                            'You are already part of the party', mainGreen);
                        handleAfterSubmit();
                        return;
                      }
                      fp
                          .userJoinParty(
                              widget.loggedUser.uid,
                              result!.code.toString(),
                              widget.loggedUser.displayName!,
                              widget.loggedUser.photoURL!,
                              0)
                          .then((value) {
                        if (fp.hasError) {
                          displayToastMessage(
                              context, sp.errorCode.toString(), alertColor);
                          return;
                        }
                        displayToastMessage(
                            context, 'You join the party', mainGreen);
                        handleAfterSubmit();
                        return;
                      });
                    })));
          });
        });
      });
    });
  }

  handleAfterSubmit() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(
          context,
          HomePage(
            loggedUser: widget.loggedUser,
            db: widget.db,
          ));
    });
  }

  handleAfterError() {
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      Navigator.pop(context);
    });
  }

  handleStepBack() {
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      Navigator.pop(context);
    });
  }

  handleAfterAdd() {
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      nextScreenReplace(
          context,
          HomePage(
            loggedUser: widget.loggedUser,
            db: widget.db,
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double heigth = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backGround,
      appBar: AppBar(
        backgroundColor: backGround,
        centerTitle: true,
        title: const Text(
          'Qr Scanner',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onTap: () {
            controller!.pauseCamera();
            handleStepBack();
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: heigth * .6,
            width: width,
            child: QRView(
              key: _gLobalkey,
              onQRViewCreated: qr,
              overlay: QrScannerOverlayShape(
                  borderColor: mainGreen,
                  borderRadius: 10,
                  borderLength: 20,
                  borderWidth: 10),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: (result != null)
                ? Text(
                    '${result!.code}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Scan a code',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
          )
        ],
      ),
    );
  }

  bool isErrorNew() {
    if (error == newError) {
      return false;
    } else {
      error = newError;
      return true;
    }
  }
}
