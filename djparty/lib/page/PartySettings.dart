import 'package:djparty/page/SpotifyTabController.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
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

  int _currentTimer = 0;
  int _currentInterval = 0;
  String _partyName = '';

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();

    _currentTimer = fr.timer!;
    _currentInterval = fr.votingTimer!;
    _partyName = fr.partyName!;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final fr = context.read<FirebaseRequests>();

    final width = MediaQuery.of(context).size.width;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: const Color.fromARGB(228, 53, 191, 101),
                secondary: const Color.fromARGB(228, 53, 191, 101))),
        home: Scaffold(
            backgroundColor: const Color.fromARGB(255, 35, 34, 34),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color.fromARGB(255, 35, 34, 34),
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
                  nextScreenReplace(context, SpotifyTabController());
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Column(children: [
                /*
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 15,
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: TextFormField(
                    controller: controller,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      hintText: fr.partyName,
                      hintStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(30, 215, 96, 0.9),
                        ),
                      ),
                    ),
                  ),
                ),*/
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
                  selectedTextStyle: const TextStyle(
                      color: Color.fromRGBO(30, 215, 96, 0.9),
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
                  selectedTextStyle: const TextStyle(
                      color: Color.fromRGBO(30, 215, 96, 0.9),
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
                  height: 30,
                ),
                RoundedLoadingButton(
                  onPressed: () {
                    _handleUpdate();
                  },
                  controller: submitController,
                  successColor: const Color.fromRGBO(30, 215, 96, 0.9),
                  width: width * 0.80,
                  elevation: 0,
                  borderRadius: 25,
                  color: const Color.fromRGBO(30, 215, 96, 0.9),
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
              ]),
            )));
  }

  Future _handleUpdate() async {
    final ip = context.read<InternetProvider>();
    final fr = context.read<FirebaseRequests>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      submitController.reset();
      return;
    }

    fr
        .updateParty(fr.partyCode!, _currentTimer, _currentInterval)
        .then((value) {
      if (fr.hasError) {
        showInSnackBar(context, fr.errorCode.toString(), Colors.red);
        submitController.reset();
        return;
      }
      fr.getPartyDataFromFirestore(fr.partyCode!).then((value) {
        if (fr.hasError) {
          showInSnackBar(context, fr.errorCode.toString(), Colors.red);
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
      nextScreen(context, const SpotifyTabController());
    });
  }
}
