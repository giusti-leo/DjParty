import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/Home.dart';
import 'package:djparty/page/HomePage.dart';
import 'package:djparty/page/UserProfile.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/FirebaseAuthMethods.dart';

class InsertCode extends StatefulWidget {
  InsertCode({
    super.key,
  });

  @override
  State<InsertCode> createState() => _InsertCodeState();
}

class _InsertCodeState extends State<InsertCode> {
  final TextEditingController textController = TextEditingController();
  bool err = false;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    super.initState();
    getData();
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
        backgroundColor: const Color.fromARGB(255, 35, 34, 34),
        title: const Text(
          'Join Party',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 35, 34, 34),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Enter a Party Code',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(
                height: 20,
              ),
              buildTextField(context),
            ]),
      )),
    ));
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
            borderSide: const BorderSide(
              color: Color.fromRGBO(30, 215, 96, 0.9),
            ),
          ),
          suffixIcon: IconButton(
              color: const Color.fromRGBO(30, 215, 96, 0.9),
              icon: const Icon(Icons.done, size: 30),
              onPressed: () {
                handleInsert();
              }),
        ),
      ));

  Future handleInsert() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fp = context.read<FirebaseRequests>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      return;
    }

    if (!validityCode()) {
      return;
    }

    await sp.checkUserExists().then((value) async {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        return;
      }
      if (value == false) {
        showInSnackBar(context, 'The user data does not exists', Colors.red);
        return;
      }

      await sp.getUserDataFromFirestore(sp.uid!).then((value) {
        if (sp.hasError == true) {
          showInSnackBar(context, sp.errorCode.toString(), Colors.red);
          return;
        }
        sp.saveDataToSharedPreferences().then((value) async {
          await fp.checkPartyExists(code: textController.text).then((value) {
            if (fp.hasError == true) {
              showInSnackBar(context, sp.errorCode.toString(), Colors.red);
              return;
            }
            if (value == false) {
              showInSnackBar(context,
                  'This code does not correspond to any party', Colors.red);
              return;
            } else {
              fp.getPartyDataFromFirestore(textController.text).then((value) =>
                  fp.saveDataToSharedPreferences().then((value) =>
                      fp.isUserInsideParty(sp.uid!).then((value) {
                        if (value == true) {
                          displayToastMessage(
                              context,
                              'You are already part of the party',
                              Colors.green);
                          return;
                        }

                        fp
                            .userJoinParty(sp.uid!, textController.text,
                                sp.name!, sp.imageUrl!, sp.image!)
                            .then((value) {
                          if (fp.hasError) {
                            showInSnackBar(
                                context, sp.errorCode.toString(), Colors.red);
                            return;
                          }
                          displayToastMessage(
                              context, 'You join the party', Colors.green);
                          return;
                        });
                      })));
            }
          });
        });
      });
    });
  }

  bool validityCode() {
    if (textController.text.length != 5) {
      displayToastMessage(
          context, 'Party Code is 5 characters long', Colors.red);
      return false;
    } else {
      return true;
    }
  }
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey _gLobalkey = GlobalKey();
  QRViewController? controller;
  Barcode? result;

  String error = '';
  String newError = '';

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
    final fp = context.read<FirebaseRequests>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      return;
    }

    if (!validityCode()) {
      if (isErrorNew()) {
        displayToastMessage(context, error, Colors.red);
      }
      setState(() {
        controller!.pauseCamera();
        handleStepBack();
      });
      return;
    }

    await sp.checkUserExists().then((value) async {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        return;
      }
      if (value == false) {
        showInSnackBar(context, 'The user data does not exists', Colors.red);
        return;
      }

      await sp.getUserDataFromFirestore(sp.uid!).then((value) {
        if (sp.hasError == true) {
          showInSnackBar(context, sp.errorCode.toString(), Colors.red);
          return;
        }
        sp.saveDataToSharedPreferences().then((value) async {
          await fp
              .checkPartyExists(code: result!.code.toString())
              .then((value) {
            if (fp.hasError == true) {
              showInSnackBar(context, sp.errorCode.toString(), Colors.red);
              controller!.pauseCamera();
              handleStepBack();
              return;
            }
            if (value == false) {
              showInSnackBar(context,
                  'This code does not correspond to any party', Colors.red);
              controller!.pauseCamera();
              handleStepBack();

              return;
            }
            fp.getPartyDataFromFirestore(result!.code.toString()).then(
                (value) => fp.saveDataToSharedPreferences().then(
                    (value) => fp.isUserInsideParty(sp.uid!).then((value) {
                          if (value == true) {
                            displayToastMessage(
                                context,
                                'You are already part of the party',
                                Colors.green);
                            return;
                          }
                          fp
                              .userJoinParty(sp.uid!, result!.code.toString(),
                                  sp.name!, sp.imageUrl!, sp.image!)
                              .then((value) {
                            if (fp.hasError) {
                              showInSnackBar(
                                  context, sp.errorCode.toString(), Colors.red);
                              return;
                            }
                            displayToastMessage(
                                context, 'You join the party', Colors.green);
                            return;
                          });
                        })));
          });
        });
      });
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
      nextScreenReplace(context, const HomePage());
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double heigth = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 35, 34, 34),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 35, 34, 34),
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
                  borderColor: const Color.fromRGBO(30, 215, 96, 0.9),
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
