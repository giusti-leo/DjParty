import 'dart:ui';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/Home.dart';
import 'package:djparty/page/HomePage.dart';
import 'package:djparty/page/SignIn.dart';
import 'package:djparty/page/UserProfile.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../services/FirebaseAuthMethods.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

class GeneratorScreen extends StatefulWidget {
  static String routeName = 'qrGeneration';

  GeneratorScreen({
    super.key,
  });

  @override
  State<GeneratorScreen> createState() => _insertPartyName();
}

class _insertPartyName extends State<GeneratorScreen> {
  final TextEditingController controller = TextEditingController();

  final TextEditingController partyName = TextEditingController();

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  final RoundedLoadingButtonController submitController =
      RoundedLoadingButtonController();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

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
            'Create Party',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        backgroundColor: backGround,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 15,
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: TextFormField(
                    toolbarOptions: const ToolbarOptions(
                        copy: true, paste: true, selectAll: true, cut: true),
                    cursorColor: mainGreen,
                    controller: partyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Party Name',
                      hintStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: mainGreen),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: mainGreen,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                RoundedLoadingButton(
                  onPressed: () {
                    handleCreation();
                  },
                  controller: submitController,
                  successColor: mainGreen,
                  width: MediaQuery.of(context).size.width * 0.80,
                  elevation: 0,
                  borderRadius: 25,
                  color: mainGreen,
                  child: Wrap(
                    children: const [
                      Text(
                        'Confirm',
                        selectionColor: Colors.black,
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  Future<void> handleCreation() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fp = context.read<FirebaseRequests>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      submitController.reset();
      return;
    }
    if (!isValid()) {
      submitController.reset();
      return;
    }

    bool found = false;

    while (!found) {
      controller.text = getRandomString(5);
      await fp.checkPartyExists(code: controller.text).then((value) {
        if (value == false) {
          found = true;
        }
      });
    }

    await sp.checkUserExists().then((value) async {
      if (sp.hasError == true) {
        displayToastMessage(context, sp.errorCode.toString(), alertColor);
        return;
      }
      if (value == false) {
        displayToastMessage(
            context, 'The user data does not exists', alertColor);
        return;
      }
      fp
          .addParty(sp.uid!, partyName.text, controller.text, sp.image!,
              sp.name!, sp.imageUrl!)
          .then((value) {
        if (fp.hasError == true) {
          displayToastMessage(context, sp.errorCode.toString(), alertColor);
          submitController.reset();
          return;
        }
        submitController.success();
        displayToastMessage(context, 'Party Created', mainGreen);
        handleAfterSubmit();
      });
    });
  }

  bool isValid() {
    if (partyName.text.isEmpty) {
      displayToastMessage(
          context, 'The Party Name cannot be empty', alertColor);
      return false;
    }
    return true;
  }

  handleAfterSubmit() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, const HomePage());
    });
  }
}
