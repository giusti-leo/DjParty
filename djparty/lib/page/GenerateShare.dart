import 'dart:ui';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/Home.dart';
import 'package:djparty/page/SignIn.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../services/FirebaseAuthMethods.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

final TextEditingController partyName = TextEditingController();
FirebaseAuth _auth = FirebaseAuth.instance;

class GeneratorScreen extends StatefulWidget {
  static String routeName = 'qrGeneration';

  @override
  State<GeneratorScreen> createState() => _insertPartyName();
}

class _insertPartyName extends State<GeneratorScreen> {
  TextEditingController controller = TextEditingController();

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime dateTime = DateTime.now();

  String choosenDate = '';
  DateFormat choosenTime = new DateFormat();
  bool showDate = false;
  bool showTime = false;
  bool showDateTime = false;

  final RoundedLoadingButtonController submitController =
      RoundedLoadingButtonController();

  Future getData() async {
    final sp = context.read<SignInProvider>();

    sp.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    dateTime = DateTime.now();
    getData();
  }

  Future<DateTime> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
    return selectedDate;
  }

// Select for Time
  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (selected != null && selected != selectedTime) {
      setState(() {
        selectedTime = selected;
      });
    }
    return selectedTime;
  }

  String getDate() {
    if (!showDate) {
      return 'Select date';
    } else {
      final val = DateFormat('MMM d, yyyy').format(selectedDate);
      choosenDate = val;
      return val;
    }
  }

  String getTime(TimeOfDay tod) {
    if (!showTime) {
      return 'Select time';
    } else {
      final now = DateTime.now();

      final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      final format = DateFormat.jm();
      choosenTime = format;
      return format.format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color.fromARGB(228, 53, 191, 101),
              secondary: const Color.fromARGB(228, 53, 191, 101))),
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 35, 34, 34),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(228, 53, 191, 101),
          title: const Text('Create your Party'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 100,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 15,
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: TextFormField(
                    controller: partyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your Party Name',
                      hintStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(30, 215, 96, 0.9),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                /*
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 18,
                    width: MediaQuery.of(context).size.width / 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                          color: Color.fromARGB(184, 255, 255, 255),
                          width: 5,
                        ),
                        primary: const Color.fromRGBO(
                            30, 215, 96, 0.9), // Background color
                        onPrimary: Colors.white, // Text Color (Foreground color)
                      ),
                      onPressed: () {
                        _selectDate(context);
                        showDate = true;
                      },
                      child: Text(
                        getDate(),
                        style: const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(
                      color: Color.fromRGBO(30, 215, 96, 0.9), height: 64),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 40,
                    child: Text(
                      'Optional information',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 18,
                    width: MediaQuery.of(context).size.width / 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                          color: Color.fromARGB(184, 255, 255, 255),
                          width: 5,
                        ),
                        primary: const Color.fromRGBO(
                            30, 215, 96, 0.9), // Background color
                        onPrimary: Colors.white, // Text Color (Foreground color)
                      ),
                      onPressed: () {
                        _selectTime(context);
                        showTime = true;
                      },
                      child: Text(getTime(selectedTime),
                          style:
                              const TextStyle(color: Colors.black, fontSize: 20)),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),*/
                RoundedLoadingButton(
                  onPressed: () {
                    handleCreation();
                  },
                  controller: submitController,
                  successColor: const Color.fromRGBO(30, 215, 96, 0.9),
                  width: MediaQuery.of(context).size.width * 0.80,
                  elevation: 0,
                  borderRadius: 25,
                  color: const Color.fromRGBO(30, 215, 96, 0.9),
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

  Future<void> handleCreation() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fp = context.read<FirebaseRequests>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
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

    fp
        .createParty(sp.uid.toString(), partyName.text, controller.text)
        .then((value) {
      fp.checkPartyExists(code: controller.text).then((value) {
        fp
            .createPartyForAUser(sp.uid.toString(), sp.uid.toString(),
                partyName.text, controller.text)
            .then((value) {
          if (fp.hasError == true) {
            showInSnackBar(context, sp.errorCode.toString(), Colors.red);
            submitController.reset();
            return;
          }
          submitController.success();
          displayToastMessage(context, 'Party Created', Colors.greenAccent);
          handleAfterSubmit();
        });
      });
    });
  }

  bool isValid() {
    if (partyName.text.isEmpty) {
      displayToastMessage(
          context, 'The Party Name cannot be empty', Colors.red);
      return false;
    }
    return true;
  }

  handleAfterSubmit() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, const Home());
    });
  }

/*



  Widget _qrScreen(BuildContext context) {
    final key = GlobalKey();
    File? file;

    User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(25, 20, 20, 0.4),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
        title: const Text('Create your Party'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
            left: 15.0, right: 15.0, top: 10.0, bottom: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: partyName,
              keyboardType: TextInputType.none,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              decoration: const InputDecoration(
                focusColor: Colors.greenAccent,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent, width: 3),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent, width: 3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent, width: 3),
                ),
                labelText: 'Party name',
                labelStyle: TextStyle(color: Colors.greenAccent, fontSize: 16),
                iconColor: Colors.greenAccent,
                hintText: '',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(
              height: 130,
            ),
            Center(
              child: RepaintBoundary(
                key: key,
                child: QrImage(
                  data: controller.text,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
                child: Text(
              'Code: ' + '${controller.text}',
              style: const TextStyle(
                color: Colors.white,
              ),
            )),
            const SizedBox(height: 40),
            const SizedBox(height: 40),
            SizedBox(
              height: 40,
              width: 170,
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: const MaterialStatePropertyAll<Color>(
                        Color.fromRGBO(30, 215, 96, 0.9)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  child: const Text('Confirm', style: TextStyle(fontSize: 17)),
                  onPressed: () async {
                    try {
                      CollectionReference<Map<String, dynamic>> parties =
                          FirebaseFirestore.instance.collection('parties');
                      CollectionReference<Map<String, dynamic>> users =
                          FirebaseFirestore.instance.collection('users');

                      if (currentUser != null) {
                        Map<String, dynamic> party = {
                          'admin': currentUser.uid,
                          'timer': 60,
                          'partyName': partyName.text,
                          'code': controller.text,
                          'creationTime': Timestamp.now()
                        };

                        await parties
                            .doc(controller.text)
                            .set(party)
                            .then((value) => print('Party added'));

                        final userDoc = FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .collection('party')
                            .doc(controller.text);

                        if (userDoc != null) {
                          userDoc.set({
                            'PartyName': partyName.text,
                            'startDate': Timestamp.now(),
                            'code': controller.text
                          });
                        }
                        displayToastMessage('Party Created', context);
                      }
                    } on FirebaseAuthException catch (e) {
                      displayToastMessage(e.message.toString(), context);
                    }

                    try {
                      RenderRepaintBoundary boundary = key.currentContext!
                          .findRenderObject() as RenderRepaintBoundary;
                      var image = await boundary.toImage();
                      ByteData? byteData =
                          await image.toByteData(format: ImageByteFormat.png);
                      Uint8List pngBytes = byteData!.buffer.asUint8List();
                      final appDir = await getApplicationDocumentsDirectory();
                      var datetime = DateTime.now();
                      file =
                          await File('${appDir.path}/$datetime.png').create();
                      await file?.writeAsBytes(pngBytes);

                      await Share.shareFiles(
                        [file!.path],
                        mimeTypes: ["image/png"],
                        text:
                            "Scan this Qr-Code to join my SpotiParty! or instert this code: ${controller.text}",
                      );
                    } catch (e) {
                      print(e.toString());
                    }
                    partyName.clear();

                    Navigator.pushNamed(context, Home.routeName);
                  }),
            ),
          ],
        ),
      ),
    );
  }
  
  
  
  */

}
