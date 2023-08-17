import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/entities/Entities.dart';
import 'package:djparty/page/auth/Login.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class UserProfile extends StatefulWidget {
  static String routeName = 'userProfile';
  ZoomDrawerController drawerController;
  User loggedUser;
  FirebaseFirestore db;

  UserProfile(
      {super.key,
      required this.drawerController,
      required this.loggedUser,
      required this.db});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController _description = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final RoundedLoadingButtonController updateController =
      RoundedLoadingButtonController();

  late String name = '';
  late String descr = '';
  String description = '';
  int image = 0;
  String imageUrl = '';
  int initColor = 0;

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _description.clear();
    _username.clear();
    getData();
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(primary: mainGreen, secondary: backGround)),
        home: Scaffold(
            backgroundColor: backGround,
            appBar: AppBar(
              backgroundColor: backGround,
              title: const Text(
                'Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              leading: InkWell(
                  onTap: (() => widget.drawerController.toggle!()),
                  child: const Icon(Icons.menu)),
            ),
            body: Container(
                padding: isMobile
                    ? const EdgeInsets.only(top: 0)
                    : const EdgeInsets.only(left: 70, right: 70),
                child: StreamBuilder(
                    stream: widget.db
                        .collection('users')
                        .doc(widget.loggedUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Person utente =
                            Person.getTrackFromFirestore(snapshot.data);

                        return ListView(
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .1,
                                ),
                                roundedImage(utente),
                                nameBuilder(utente),
                                descriptionBuilder(utente),
                                saveButton(),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .1,
                                ),
                              ],
                            )
                          ],
                        );
                      }

                      return Container();
                    }))));
  }

  Widget descriptionBuilder(Person utente) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Text(
          'About me',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * .6,
          height: MediaQuery.of(context).size.height * .1,
          child: TextField(
            controller: _description,
            keyboardType: TextInputType.name,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: utente.description,
              hintStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.black12,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1),
              ),
              labelStyle: const TextStyle(
                  color: Color.fromRGBO(30, 215, 96, 0.9), fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget nameBuilder(Person utente) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Text(
          'Name',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * .6,
          height: MediaQuery.of(context).size.height * .1,
          child: TextField(
            controller: _username,
            keyboardType: TextInputType.name,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              hintText: utente.username,
              fillColor: Colors.black12,
              hintStyle: const TextStyle(color: Colors.white, fontSize: 14),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1),
              ),
              labelStyle: const TextStyle(
                  color: Color.fromRGBO(30, 215, 96, 0.9), fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget roundedImage(Person utente) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (utente.imageUrl != '' && utente.imageUrl != ' ')
              ? (height > width)
                  ? CircleAvatar(
                      backgroundColor: Colors.white,
                      maxRadius: width * 0.15,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(utente.imageUrl!),
                        maxRadius: width * 0.15 - 2,
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.white,
                      maxRadius: height * 0.15,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(utente.imageUrl!),
                        maxRadius: height * 0.15 - 2,
                      ),
                    )
              : (height > width)
                  ? CircleAvatar(
                      backgroundColor: Colors.white,
                      maxRadius: width * 0.15,
                      child: CircleAvatar(
                          maxRadius: width * 0.15 - 2,
                          backgroundColor: Colors.black,
                          child: Text(
                            utente.username![0].toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: mainGreen,
                                fontSize: 40,
                                fontStyle: FontStyle.normal),
                          )))
                  : CircleAvatar(
                      backgroundColor: Colors.white,
                      maxRadius: height * 0.15,
                      child: CircleAvatar(
                          maxRadius: height * 0.15 - 2,
                          backgroundColor: Colors.black,
                          child: Text(
                            utente.username![0].toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: mainGreen,
                                fontSize: 40,
                                fontStyle: FontStyle.normal),
                          ))),
        ]);
  }

  Widget saveButton() {
    return RoundedLoadingButton(
      onPressed: () {
        saveChanges();
      },
      controller: updateController,
      successColor: mainGreen,
      width: MediaQuery.of(context).size.width * 0.3,
      elevation: 0,
      borderRadius: 25,
      color: mainGreen,
      child: const Wrap(
        children: [
          Text("Save",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future saveChanges() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      updateController.reset();
      return;
    }

    if (!validity()) {
      updateController.reset();
      return;
    }

    if (_description.text.isEmpty) {
      description = descr;
    } else {
      description = _description.text;
    }
    if (_username.text.isEmpty) {
      name = sp.name.toString();
    } else {
      name = _username.text;
    }

    sp.checkUserExists(widget.loggedUser.uid).then((value) async {
      if (sp.hasError == true) {
        displayToastMessage(context, sp.errorCode.toString(), alertColor);
        updateController.reset();
        return;
      }
      await sp.update(name, description).then((value) async {
        if (sp.hasError == true) {
          displayToastMessage(context, sp.errorCode.toString(), alertColor);
          updateController.reset();
          return;
        }
      });

      sp.getUserDataFromFirestore(widget.loggedUser.uid).then((value) async {
        if (sp.hasError == true) {
          displayToastMessage(context, sp.errorCode.toString(), alertColor);
          updateController.reset();
          return;
        }
        await sp.saveDataToSharedPreferences().then((value) async {
          await Future.delayed(const Duration(milliseconds: 800));
          displayToastMessage(context, 'Changes saved', mainGreen);
          updateController.reset();
        });
      });
    });
  }

  bool validity() {
    if (_description.text.length > 100) {
      displayToastMessage(context,
          'Description must be less than 100 characters long', alertColor);
      return false;
    }
    if (_username.text.length > 10) {
      displayToastMessage(
          context, 'Name must be less than 50 characters long', alertColor);
      return false;
    }
    return true;
  }

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
