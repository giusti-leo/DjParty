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
  const GeneratorScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final key = GlobalKey();
  File? file;
  final controller = TextEditingController();
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
    return Scaffold(
      backgroundColor: const Color.fromRGBO(25, 20, 20, 0.4),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
        title: const Text('Create your Party'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              //buildTextField(context),
              Center(
                child: (controller.text != null)
                    ? Text(
                        '${controller.text}',
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
              ),
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
                    child: const Text('Generate Qr-Code',
                        style: TextStyle(fontSize: 14)),
                    onPressed: () {
                      controller.text = getRandomString(5);
                      setState(() {});
                    }),
              ),
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
                    child: const Text('Share', style: TextStyle(fontSize: 17)),
                    onPressed: () async {
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
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  
  
  */

}
