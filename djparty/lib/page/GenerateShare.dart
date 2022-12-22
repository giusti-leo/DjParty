import 'dart:ui';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

final controller = TextEditingController();

// class GeneratorScreen extends StatefulWidget {
//   const GeneratorScreen({Key? key, required this.title}) : super(key: key);
//   final String title;

//   @override
//   State<GeneratorScreen> createState() => _GeneratorScreenState();
// }

// class _GeneratorScreenState extends State<GeneratorScreen> {
//   final key = GlobalKey();
//   File? file;
//   final _chars =
//       'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
//   Random _rnd = Random();

//   String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
//       length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromRGBO(25, 20, 20, 0.4),
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
//         title: const Text('Create your Party'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 40,
//                 width: 170,
//                 child: ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor: const MaterialStatePropertyAll<Color>(
//                           Color.fromRGBO(30, 215, 96, 0.9)),
//                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20.0),
//                         ),
//                       ),
//                     ),
//                     child: const Text('Generate Qr-Code',
//                         style: TextStyle(fontSize: 14)),
//                     onPressed: () {

//                     }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class GeneratedCode extends StatefulWidget {
  const GeneratedCode({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<GeneratedCode> createState() => _GeneratedCodeState();
}

class _GeneratedCodeState extends State<GeneratedCode> {
  final key = GlobalKey();
  File? file;
  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  Widget build(BuildContext context) {
    controller.text = getRandomString(5);
    setState(() {});
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
}
