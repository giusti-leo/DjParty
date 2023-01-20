import 'package:flutter/material.dart';

import 'package:djparty/page/InsertCode.dart';
import 'package:djparty/page/Scanner.dart';

class JoinOptions extends StatelessWidget {
  const JoinOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(25, 20, 20, 0.9),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
        title: const Text('Join a Party'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                child:
                    const Text('Scan Qr-Code', style: TextStyle(fontSize: 17)),
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //             ScannerScreen(title: 'Join Party')));
                }),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 40,
            width: 170,
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(
                      Color.fromRGBO(30, 215, 96, 0.9)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                child:
                    const Text('Insert Code', style: TextStyle(fontSize: 17)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              InsertCode(title: 'Join a Party')));
                }),
          ),
        ]),
      ),
    );
  }
}
