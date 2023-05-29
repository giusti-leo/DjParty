import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/entities/Party.dart';
import 'package:djparty/page/SpotifyTabController.dart';
import 'package:djparty/page/admin/AdminTabPage.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PartySettings extends StatefulWidget {
  const PartySettings({super.key});

  @override
  State<PartySettings> createState() => _PartySettingsState();
}

class _PartySettingsState extends State<PartySettings> {
  final RoundedLoadingButtonController submitController =
      RoundedLoadingButtonController();
  final TextEditingController controller = TextEditingController();

  late int _currentTimer;
  late int _currentInterval;

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    sp.getDataFromSharedPreferences();
    fr.getPartyDataFromFirestore(fr.partyCode!);

    _currentInterval = fr.votingTimer!;
    _currentTimer = fr.timer!;

    print(fr.votingTimer!);
  }

  @override
  void initState() {
    super.initState();
    getData();

    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(primary: mainGreen, secondary: mainGreen)),
        home: Scaffold(
            backgroundColor: backGround,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: backGround,
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              leading: GestureDetector(
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
                onTap: () {
                  double h = MediaQuery.of(context).size.height;
                  nextScreenReplace(
                      context,
                      AdminTabPage(
                        homeHeigth: h,
                      ));
                },
              ),
            ),
            body: SingleChildScrollView(
                child: Column(children: [
              const SizedBox(
                height: 50,
              ),
              const Text('Select Timer',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500)),
              const SizedBox(
                height: 10,
              ),
              NumberPicker(
                value: _currentTimer,
                minValue: 1,
                maxValue: 100,
                step: 1,
                itemHeight: 100,
                axis: Axis.horizontal,
                textStyle: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
                selectedTextStyle: TextStyle(
                    color: mainGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
                onChanged: (value) => setState(() {
                  _currentTimer = value;
                }),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text('Select Interval',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500)),
              const SizedBox(
                height: 10,
              ),
              NumberPicker(
                value: _currentInterval,
                minValue: 1,
                maxValue: 100,
                step: 1,
                itemHeight: 100,
                axis: Axis.horizontal,
                textStyle: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
                selectedTextStyle: TextStyle(
                    color: mainGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
                onChanged: (value) => setState(() {
                  _currentInterval = value;
                }),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              RoundedLoadingButton(
                onPressed: () {
                  _handleUpdate();
                },
                controller: submitController,
                successColor: mainGreen,
                width: width * 0.80,
                elevation: 0,
                borderRadius: 25,
                color: mainGreen,
                child: Wrap(
                  children: const [
                    Text("Save",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            ]))));
  }

  Future _handleUpdate() async {
    final ip = context.read<InternetProvider>();
    final fr = context.read<FirebaseRequests>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", alertColor);
      submitController.reset();
      return;
    }

    fr
        .updatePartySettings(fr.partyCode!, _currentTimer, _currentInterval)
        .then((value) {
      if (fr.hasError) {
        showInSnackBar(context, fr.errorCode.toString(), alertColor);
        submitController.reset();
        return;
      }
      fr.getPartyDataFromFirestore(fr.partyCode!).then((value) {
        if (fr.hasError) {
          showInSnackBar(context, fr.errorCode.toString(), alertColor);
          submitController.reset();
          return;
        }
        fr.saveDataToSharedPreferences().then((value) {
          submitController.success();
          handlePassToPartyLobby();
        });
      });
    });
  }

  handlePassToPartyLobby() {
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      double h = MediaQuery.of(context).size.height;
      nextScreen(context, AdminTabPage(homeHeigth: h));
    });
  }
}
