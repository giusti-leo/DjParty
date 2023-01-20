import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/UserProfile.dart';
import 'package:djparty/widgets/ProfileWidget.dart';
import 'package:djparty/widgets/TextFieldWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:path/path.dart';

import '../services/FirebaseAuthMethods.dart';

Color currentColorImage = new Color(0);
Color currentColorText = new Color(0);
String text = '';
String description = '';
String username = '';

class EditProfile extends StatefulWidget {
  static String routeName = 'editProfile';

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool start = true;

  final TextEditingController _description = TextEditingController();
  final TextEditingController _username = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    @override
    void initState() {
      super.initState();
      start = false;
    }

    Widget updateImage(Color backgroundColor, Color textColor, String text) {
      return CircleAvatar(
          backgroundColor: Colors.white,
          minRadius: 90.0,
          child: CircleAvatar(
              backgroundColor: backgroundColor,
              minRadius: 80,
              child: Text(
                text.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 40,
                ),
              )));
    }

    void changeColorImage(Color color) => setState(() {
          currentColorImage = color;
        });

    void changeText(String newtext) => setState(() {
          text = newtext[0];
        });

    void changeColorText(Color color) => setState(() {
          currentColorText = color;
        });

    return Scaffold(
        backgroundColor: Color.fromARGB(128, 52, 74, 61),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(158, 61, 219, 71),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(children: [
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.none) {
                    return const Center(
                        child: CircularProgressIndicator(
                      backgroundColor: Colors.green,
                      color: Color.fromARGB(210, 193, 172, 172),
                      strokeWidth: 3,
                    ));
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No data'),
                    );
                  }
                  if (start) {
                    text = snapshot.data!.get('username')[0].toString();
                    description = snapshot.data!.get('description').toString();
                    currentColorImage = Color(snapshot.data!.get('image'));
                    currentColorText = Color(snapshot.data!.get('initColor'));
                    username = snapshot.data!.get('username').toString();
                    start = false;
                  }

                  return Column(
                    children: [
                      const SizedBox(height: 32),
                      updateImage(currentColorImage, currentColorText, text),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: width / 3,
                            height: height / 18,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  side:
                                      BorderSide(width: 3, color: Colors.white),
                                  backgroundColor:
                                      Color.fromARGB(158, 61, 219, 71)),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Pick a background color'),
                                        content: SingleChildScrollView(
                                          child: BlockPicker(
                                            pickerColor:
                                                currentColorImage, //default color
                                            onColorChanged: (Color color) {
                                              //on color picked
                                              changeColorImage(color);
                                            },
                                          ),
                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            child: const Text('Select'),
                                            onPressed: () {
                                              updateImage(currentColorImage,
                                                  currentColorText, text);

                                              Navigator.of(context)
                                                  .pop(); //dismiss the color picker
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                              child: const Text(
                                "Background",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 50,
                          ),
                          SizedBox(
                            width: width / 3,
                            height: height / 18,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  side:
                                      BorderSide(width: 3, color: Colors.white),
                                  backgroundColor:
                                      const Color.fromARGB(158, 61, 219, 71)),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Pick a text color'),
                                        content: SingleChildScrollView(
                                          child: BlockPicker(
                                            pickerColor:
                                                currentColorImage, //default color
                                            onColorChanged: (Color color) {
                                              //on color picked
                                              changeColorText(color);
                                            },
                                          ),
                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            child: const Text('Select'),
                                            onPressed: () {
                                              updateImage(currentColorImage,
                                                  currentColorText, text);

                                              Navigator.of(context)
                                                  .pop(); //dismiss the color picker
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                              child: const Text(
                                "Text",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(
                        child: Text(
                          'Username',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: width / 1.1,
                        height: height / 12,
                        child: TextField(
                          onChanged: (username) {
                            changeText(username);
                          },
                          controller: _username,
                          keyboardType: TextInputType.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                              filled: true,
                              hintText: username,
                              fillColor: Colors.black12,
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 16),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(158, 61, 219, 71),
                                    width: 3),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(158, 61, 219, 71),
                                    width: 3),
                              )),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(
                        child: Text(
                          'About me',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: width / 1.1,
                        height: height / 8,
                        child: TextField(
                          controller: _description,
                          keyboardType: TextInputType.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: description,
                            filled: true,
                            fillColor: Colors.black12,
                            hintStyle:
                                TextStyle(color: Colors.white, fontSize: 16),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(158, 61, 219, 71),
                                  width: 3),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(158, 61, 219, 71),
                                  width: 3),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 15,
                          width: MediaQuery.of(context).size.width / 1.3,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_username.text.length == 0) {
                                _username.text = username;
                              }
                              if (_description.text.length > 150) {
                                displayToastMessage(
                                    'Description must be less than 150 characters long',
                                    context);
                                return;
                              }
                              await update(context);

                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(158, 61, 219, 71),
                              surfaceTintColor:
                                  Color.fromARGB(158, 61, 219, 71),
                              foregroundColor: Color.fromARGB(158, 61, 219, 71),
                              shadowColor: Color.fromARGB(158, 61, 219, 71),
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
                              'Save',
                              selectionColor: Colors.black,
                              style:
                                  TextStyle(fontSize: 22, color: Colors.black),
                            ),
                          ))
                    ],
                  );
                }),
          ]),
        ));
  }

  Future<void> update(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
            'username': _username.text,
            'image': currentColorImage.value,
            'description': _description.text,
            'initColor': currentColorText.value,
            'init': _username.text[0],
          })
          .then((_) => print('Success'))
          .catchError((error) => print('Failed: $error'));
    } on FirebaseAuthException catch (e) {
      displayToastMessage(e.code, context);
    }
  }
}
