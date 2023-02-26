/*

import 'package:flutter/material.dart';

import 'package:djparty/page/InsertCode.dart';
import 'package:djparty/page/Scanner.dart';

class JoinOptions extends StatelessWidget {
  const JoinOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: const Color.fromARGB(228, 53, 191, 101),
                secondary: const Color.fromARGB(228, 53, 191, 101))),
        home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 35, 34, 34),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(228, 53, 191, 101),
            title: const Text('Join a Party'),
            centerTitle: true,
          ),
          body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                    child: const Text('Scan Qr-Code',
                        style: TextStyle(fontSize: 17)),
                    onPressed: () {}),
              ),
              const SizedBox(height: 30),
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
                    child: const Text('Insert Code',
                        style: TextStyle(fontSize: 17)),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InsertCode()));
                    }),
              ),
            ]),
          ),
        ));
  }
}

*/
