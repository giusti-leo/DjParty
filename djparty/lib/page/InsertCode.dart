import 'dart:io';

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
  final TextEditingController textController = TextEditingController();
  bool err = false;
  String code = 'null';

  String uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(128, 53, 74, 62),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(158, 61, 219, 71),
        title: const Text(
          'Join a Party',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
            const SizedBox(
              height: 60,
            ),
            const Divider(color: Color.fromRGBO(30, 215, 96, 0.9)),
            const SizedBox(
              height: 60,
            ),
            const Text(
              'Scan a qr',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(
              height: 20,
            ),
            qrButton(context),
            const SizedBox(
              height: 20,
            ),
          ])
        ],
      ),
    );
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
                validityCode();
              }),
        ),
      ));

  Widget qrButton(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height / 18,
      child: IconButton(
        color: Color.fromARGB(158, 61, 219, 71),
        icon: Icon(Icons.qr_code_sharp),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const QrScanCode()));
        },
      ),
    );
  }

  void validityCode() {
    if (textController.text.length != 5) {
      err = true;
      displayToastMessage('Party Code is 5 characters long', context);
      return;
    } else {
      err = false;
      if (err == false) {
        enterCode(textController.text);
      }
    }
  }

  Future<void> enterCode(String code) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> partySnapshot =
          await FirebaseFirestore.instance
              .collection('parties')
              .doc(code)
              .get();

      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('party')
              .doc(code)
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
            .doc(code)
            .set({
          'PartyName': partySnapshot.get('partyName').toString(),
          'startDate': partySnapshot.get('creationTime'),
          'code': partySnapshot.get('code').toString(),
        });

        await FirebaseFirestore.instance
            .collection('parties')
            .doc(code)
            .update({
          '#partecipant': FieldValue.increment(1),
          'partecipant_list': FieldValue.arrayUnion([uid]),
        });
      }

      Navigator.pushNamed(context, Home.routeName);
    } on FirebaseFirestore catch (e) {
      displayToastMessage(e.toString(), context);
    }
  }
}

class QrScanCode extends StatefulWidget {
  const QrScanCode({Key? key}) : super(key: key);

  @override
  State<QrScanCode> createState() => _QrScanCodeState();
}

class _QrScanCodeState extends State<QrScanCode> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final qrKey = GlobalKey(debugLabel: 'Qr');
  QRViewController? controller;

  Barcode? barcode;

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(158, 61, 219, 71),
          title: const Text('Scan Code'),
          centerTitle: true,
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            buildQrReader(context),
            Positioned(
              bottom: 20,
              child: buildResult(),
            )
          ],
        ),
      ));

  Widget buildResult() => Container(
      height: MediaQuery.of(context).size.height / 25,
      width: MediaQuery.of(context).size.width / 3.5,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Text(
        barcode != null ? 'Result : ${barcode!.code}' : 'Scan a code!',
        maxLines: 3,
      ));

  Widget buildQrReader(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onViewCreated,
        overlay: QrScannerOverlayShape(
            borderRadius: 10,
            borderLength: 20,
            borderWidth: 10,
            cutOutBottomOffset: MediaQuery.of(context).size.height * 0.2),
      );

  void onViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller!.scannedDataStream.listen((barcode) {
      this.barcode = barcode;
    });

    if (barcode != null) {
      enterCode(barcode!.code.toString());
    }
  }

  Future<void> enterCode(String code) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> partySnapshot =
          await FirebaseFirestore.instance
              .collection('parties')
              .doc(code)
              .get();

      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('party')
              .doc(code)
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
            .doc(code)
            .set({
          'PartyName': partySnapshot.get('partyName').toString(),
          'startDate': partySnapshot.get('creationTime'),
          'code': partySnapshot.get('code').toString(),
        });

        await FirebaseFirestore.instance
            .collection('parties')
            .doc(code)
            .update({
          '#partecipant': FieldValue.increment(1),
          'partecipant_list': FieldValue.arrayUnion([uid]),
        });
      }

      Navigator.pushNamed(context, Home.routeName);
    } on FirebaseFirestore catch (e) {
      displayToastMessage(e.toString(), context);
    }
  }
}
