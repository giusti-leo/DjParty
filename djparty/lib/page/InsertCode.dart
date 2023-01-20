import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/FirebaseAuthMethods.dart';

class InsertCode extends StatefulWidget {
  const InsertCode({super.key, required this.title});
  final String title;

  @override
  State<InsertCode> createState() => _InsertCodeState();
}

class _InsertCodeState extends State<InsertCode> {
  final GlobalKey _gLobalkey = GlobalKey();
  QRViewController? controller;
  Barcode? result;
  void qr(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((event) {
      setState(() {
        result = event;
      });
    });
  }

  final TextEditingController controllertext = TextEditingController();
  bool err = false;
  String code = 'null';

  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(25, 20, 20, 0.4),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
        title: const Text('Join a Party'),
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
            buildTextField(context),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(BuildContext context) => TextFormField(
        controller: controllertext,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        decoration: InputDecoration(
          hintText: 'Enter Your Code',
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
                validityCode();
              }),
        ),
      );

  void validityCode() {
    if (controllertext.text.length != 5) {
      err = true;
      displayToastMessage('Party Code is 5 characters long', context);
      return;
    } else {
      err = false;
      if (err == false) {
        enterCode();
      }
    }
  }

  Future<void> enterCode() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> partySnapshot =
          await FirebaseFirestore.instance
              .collection('parties')
              .doc(controllertext.text)
              .get();

      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('party')
              .doc(controllertext.text)
              .get();

      if (partySnapshot.data()!.isEmpty) {
        displayToastMessage(
            'This code does not correspond to any party', context);
        return;
      }

      if (userSnapshot.exists) {
        displayToastMessage('You are already part of the party', context);
        return;
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('party')
            .doc(controllertext.text)
            .set({
          'PartyName': partySnapshot.get('partyName').toString(),
          'startDate': partySnapshot.get('creationTime'),
          'code': partySnapshot.get('code').toString(),
        });

        await FirebaseFirestore.instance
            .collection('parties')
            .doc(controllertext.text)
            .snapshots()
            .any((element) =>
                element.data()!.update('#partecipant', (value) => value + 1));
      }

      controllertext.clear();

      Navigator.pushNamed(context, Home.routeName);
    } on FirebaseFirestore catch (e) {
      displayToastMessage(e.toString(), context);
    }
  }
}
