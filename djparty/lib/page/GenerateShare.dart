import 'dart:ui';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/Home.dart';
import 'package:djparty/page/SignIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
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
  final controller = TextEditingController();

  late String _dateCount;
  late String _range;
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
  late NumberPicker integerNumberPicker;
  int _currentHorizontalIntValue = 30;

  @override
  void initState() {
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    dateTime = DateTime.now();

    super.initState();
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
    User? currentUser = _auth.currentUser;

    int _currentIntValue = 30;

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
          title: const Text('Create your Party'),
          centerTitle: true,
        ),
        body: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
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
                const SizedBox(
                  height: 30,
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
                  height: MediaQuery.of(context).size.height / 15,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
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
                  height: 30,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 15,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
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
                  height: 20,
                ),
                const SizedBox(
                  height: 30,
                  child: Text(
                    'Select a time interval',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                NumberPicker(
                  value: _currentHorizontalIntValue,
                  minValue: 0,
                  maxValue: 100,
                  step: 5,
                  itemHeight: 100,
                  axis: Axis.horizontal,
                  selectedTextStyle: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 30,
                      fontStyle: FontStyle.normal),
                  textStyle: const TextStyle(color: Colors.grey, fontSize: 18),
                  onChanged: (value) =>
                      setState(() => _currentHorizontalIntValue = value),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.greenAccent, style: BorderStyle.solid),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                    child: SizedBox(
                  height: MediaQuery.of(context).size.height / 15,
                  width: MediaQuery.of(context).size.width / 1.3,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (partyName.text.isEmpty) {
                        displayToastMessage(
                            'The Party Name cannot be empty', context);
                        return;
                      }
                      try {
                        CollectionReference<Map<String, dynamic>> parties =
                            FirebaseFirestore.instance.collection('parties');

                        while (true) {
                          controller.text = getRandomString(5);
                          var tmp = await parties
                              .where('code', isEqualTo: controller.text)
                              .get();
                          if (tmp.docs.isEmpty) {
                            break;
                          }
                        }

                        CollectionReference<Map<String, dynamic>> users =
                            FirebaseFirestore.instance.collection('users');

                        if (currentUser != null) {
                          var members = <String>[currentUser.uid.toString()];

                          Map<String, dynamic> party = {
                            'admin': currentUser.uid,
                            'timer': _currentIntValue,
                            'partyName': partyName.text,
                            'code': controller.text,
                            'creationTime': Timestamp.now(),
                            'PartyDate': choosenDate,
                            'PartyTime': choosenTime.toString(),
                            'isStarted': false,
                            '#partecipant': 1,
                            'partecipant_list': members,
                          };

                          await parties
                              .doc(controller.text)
                              .set(party)
                              .then((value) => print('Party added'));

                          final userDoc = users
                              .doc(currentUser.uid)
                              .collection('party')
                              .doc(controller.text);

                          if (userDoc != null) {
                            userDoc.set({
                              'PartyName': partyName.text,
                              'startDate': Timestamp.now(),
                              'code': controller.text,
                              'admin': currentUser.uid,
                            });
                          }
                          displayToastMessage('Party Created', context);
                        }
                      } on FirebaseAuthException catch (e) {
                        displayToastMessage(e.message.toString(), context);
                      }
                      partyName.clear();

                      Navigator.pushNamed(context, Home.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
                      surfaceTintColor: const Color.fromRGBO(30, 215, 96, 0.9),
                      foregroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
                      shadowColor: const Color.fromRGBO(30, 215, 96, 0.9),
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
                      'Confirm',
                      selectionColor: Colors.black,
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                  ),
                ))
              ],
            ),
          );
        }));
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
