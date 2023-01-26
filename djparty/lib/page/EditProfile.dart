import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/UserProfile.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:djparty/widgets/ProfileWidget.dart';
import 'package:djparty/widgets/TextFieldWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

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

  final RoundedLoadingButtonController updateController =
      RoundedLoadingButtonController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    dataLoadFunction();
    start = false;
  }

  dataLoadFunction() async {
    setState(() {
      _isLoading = true; // your loader has started to load
    });

    // fetch you data over here
    getData();

    setState(() {
      _isLoading = false; // your loder will stop to finish after the data fetch
    });
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fr = context.read<FirebaseRequests>();

    await sp.getUserDataFromFirestore(sp.uid).then((value) {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        return;
      } else {
        sp.saveDataToSharedPreferences();
      }
    });

    currentColorImage = Color(sp.image!);
    text = sp.name!;
    currentColorText = Color(sp.initColor!);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    void changeColorImage(Color color) => setState(() {
          currentColorImage = color;
        });

    void changeText(String newtext) => setState(() {
          text = newtext[0];
        });

    void changeColorText(Color color) => setState(() {
          currentColorText = color;
        });

    final sp = context.watch<SignInProvider>();

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          backgroundColor: const Color.fromARGB(128, 52, 74, 61),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(158, 61, 219, 71),
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
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Color.fromARGB(158, 61, 219, 71),
                  backgroundColor: Color.fromARGB(128, 52, 74, 61),
                  strokeWidth: 10,
                )) // this will show when loading is true
              : Stack(children: [
                  Stack(children: [
                    (sp.imageUrl != '')
                        ? Positioned(
                            top: constraints.minHeight * 0.1,
                            left: constraints.minWidth * 0.3,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: constraints.minWidth * 0.2,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage("${sp.imageUrl}"),
                                maxRadius: constraints.minWidth * 0.2 - 10,
                              ),
                            ))
                        : Positioned(
                            top: constraints.minHeight * 0.1,
                            left: constraints.minWidth * 0.3,
                            child: CircleAvatar(
                                backgroundColor: Colors.white,
                                maxRadius: constraints.minWidth * 0.2,
                                child: CircleAvatar(
                                    maxRadius: constraints.minWidth * 0.2 - 10,
                                    backgroundColor: currentColorImage,
                                    child: Text(
                                      sp.init.toString().toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: currentColorText,
                                          fontSize: 40,
                                          fontStyle: FontStyle.italic),
                                    )))),
                  ]),
                  Stack(children: [
                    const SizedBox(height: 32),
                    sp.imageUrl == ''
                        ? Positioned(
                            top: constraints.minHeight * 0.2,
                            right: constraints.minWidth * 0.1,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: width / 3,
                                  height: height / 18,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        side: const BorderSide(
                                            width: 3, color: Colors.white),
                                        backgroundColor: const Color.fromARGB(
                                            158, 61, 219, 71)),
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
                                                  onColorChanged:
                                                      (Color color) {
                                                    //on color picked
                                                    changeColorImage(color);
                                                  },
                                                ),
                                              ),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  child: const Text('Select'),
                                                  onPressed: () {
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
                                        side: const BorderSide(
                                            width: 3, color: Colors.white),
                                        backgroundColor: const Color.fromARGB(
                                            158, 61, 219, 71)),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Pick a text color'),
                                              content: SingleChildScrollView(
                                                child: BlockPicker(
                                                  pickerColor:
                                                      currentColorImage, //default color
                                                  onColorChanged:
                                                      (Color color) {
                                                    //on color picked
                                                    changeColorText(color);
                                                  },
                                                ),
                                              ),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  child: const Text('Select'),
                                                  onPressed: () {
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
                            ))
                        : Container(),
                    const SizedBox(height: 24),
                    Positioned(
                      bottom: constraints.minHeight * 0.40,
                      left: constraints.maxWidth * 0.05,
                      child: Column(children: [
                        const Text(
                          'Username',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: constraints.maxWidth * 0.9,
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
                                hintText: sp.name,
                                fillColor: Colors.black12,
                                hintStyle: const TextStyle(
                                    color: Color.fromARGB(255, 181, 165, 165),
                                    fontSize: 16),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(158, 61, 219, 71),
                                      width: 3),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(158, 61, 219, 71),
                                      width: 3),
                                )),
                          ),
                        ),
                      ]),
                    ),
                    Positioned(
                      top: constraints.maxHeight * 0.55,
                      left: constraints.maxWidth * 0.05,
                      child: Column(
                        children: [
                          const SizedBox(
                            child: Text(
                              'About me',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: constraints.minWidth * .9,
                            height: constraints.minHeight * .4,
                            child: TextField(
                              controller: _description,
                              maxLines: 3,
                              keyboardType: TextInputType.name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: sp.description == ''
                                    ? 'Describe yourself'
                                    : sp.description,
                                hintStyle: const TextStyle(
                                    color: Color.fromARGB(255, 181, 165, 165),
                                    fontSize: 16),
                                filled: true,
                                fillColor: Colors.black12,
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(158, 61, 219, 71),
                                      width: 3),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(158, 61, 219, 71),
                                      width: 3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: constraints.minHeight * 0.05,
                      left: constraints.maxWidth * 0.1,
                      child: RoundedLoadingButton(
                        onPressed: () {
                          saveChanges();
                        },
                        controller: updateController,
                        successColor: Color.fromRGBO(30, 215, 96, 0.9),
                        width: MediaQuery.of(context).size.width * 0.80,
                        elevation: 0,
                        borderRadius: 25,
                        color: Color.fromRGBO(30, 215, 96, 0.9),
                        child: Wrap(
                          children: const [
                            Icon(
                              FontAwesomeIcons.user,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text("Save changes",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    )
                  ])
                ]));
    });
  }

  Future saveChanges() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fp = context.read<FirebaseRequests>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      updateController.reset();
      return;
    }

    if (!validity()) {
      updateController.reset();
      return;
    }

    sp.checkUserExists().then((value) async {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        updateController.reset();

        return;
      }
      // user exists
      await sp.getUserDataFromFirestore(sp.uid).then((value) {
        if (sp.hasError == true) {
          showInSnackBar(context, sp.errorCode.toString(), Colors.red);
          updateController.reset();

          return;
        }
        sp.saveDataToSharedPreferences().then((value) {
          if (sp.imageUrl != '') {
            sp
                .updateSoft(_username.text, _description.text)
                .then((value) async {
              if (sp.hasError == true) {
                showInSnackBar(context, sp.errorCode.toString(), Colors.red);
                updateController.reset();
                return;
              }
              await sp.getUserDataFromFirestore(sp.uid).then((value) {
                if (sp.hasError == true) {
                  showInSnackBar(context, sp.errorCode.toString(), Colors.red);
                  updateController.reset();

                  return;
                }
                sp.saveDataToSharedPreferences().then((value) {
                  updateController.success();

                  handleSave();
                });
              });
            });
          } else if (_username.text.isEmpty) {
            sp
                .update(sp.name!, _description.text, currentColorImage.value,
                    currentColorText.value)
                .then((value) async {
              if (sp.hasError == true) {
                showInSnackBar(context, sp.errorCode.toString(), Colors.red);
                updateController.reset();
                return;
              }
              await sp.getUserDataFromFirestore(sp.uid).then((value) {
                if (sp.hasError == true) {
                  showInSnackBar(context, sp.errorCode.toString(), Colors.red);
                  updateController.reset();

                  return;
                }
                sp.saveDataToSharedPreferences().then((value) {
                  updateController.success();

                  handleSave();
                });
              });
            });
          }
        });
      });
    });
  }

  handleSave() {
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      nextScreenReplace(context, UserProfile());
    });
  }

  bool validity() {
    if (_description.text.length > 100) {
      displayToastMessage(context,
          'Description must be less than 100 characters long', Colors.red);

      return false;
    }
    return true;
  }
}
