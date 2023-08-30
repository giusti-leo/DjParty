import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/auth/Login.dart';
import 'package:djparty/page/lobby/Home.dart';
import 'package:djparty/page/lobby/UserProfile.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:djparty/entities/Entities.dart';

class HomePage extends StatefulWidget {
  static String routeName = 'home';
  User loggedUser;
  FirebaseFirestore db;

  HomePage({super.key, required this.loggedUser, required this.db});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ZoomDrawerController drawerController = ZoomDrawerController();
  MenuItem currentItem = MenuItems.home;

  String myToken = "";
  String name = "";

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);

  final Logger _logger = Logger(
    //filter: CustomLogFilter(), // custom logfilter can be used to have logs in release mode
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: zoomDrawer()));
  }

  @override
  void initState() {
    super.initState();
    (getName().then((val) => name = val)).whenComplete(() {
      setState(() {});
    });
    getData();
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  Widget zoomDrawer() {
    return ZoomDrawer(
      controller: drawerController,
      style: DrawerStyle.defaultStyle,
      mainScreen: getScreen(),
      menuScreen: Builder(builder: (context) {
        return MenuScreen(
          loggedUser: widget.loggedUser,
          db: widget.db,
          currentItem: currentItem,
          onSelectedItem: (item) {
            setState(() {
              currentItem = item;
            });
            ZoomDrawer.of(context)!.close();
          },
        );
      }),
      borderRadius: 24.8,
      angle: 0.0,
      menuBackgroundColor: const Color.fromARGB(255, 178, 184, 172),
      slideWidth: MediaQuery.of(context).size.width * .6,
      openCurve: Curves.fastLinearToSlowEaseIn,
      closeCurve: Curves.easeInCirc,
    );
  }

  Future<String> getName() async {
    var doc =
        await widget.db.collection('users').doc(widget.loggedUser.uid).get();
    return doc['username'].toString();
  }

  getScreen() {
    switch (currentItem) {
      case MenuItems.profile:
        return UserProfile(
            drawerController: drawerController,
            loggedUser: FirebaseAuth.instance.currentUser!,
            db: FirebaseFirestore.instance);
      case MenuItems.home:
        return Home(
          drawerController: drawerController,
          loggedUser: FirebaseAuth.instance.currentUser!,
          db: FirebaseFirestore.instance,
        );
    }
  }
}

class MenuScreen extends StatelessWidget {
  MenuItem currentItem;
  ValueChanged<MenuItem> onSelectedItem;
  User loggedUser;
  FirebaseFirestore db;

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);

  MenuScreen(
      {Key? key,
      required this.currentItem,
      required this.onSelectedItem,
      required this.loggedUser,
      required this.db})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData.dark(),
        child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 178, 184, 172),
            body: StreamBuilder(
                stream: db.collection('users').doc(loggedUser.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var utente = Person.getTrackFromFirestore(snapshot.data);

                    return SafeArea(
                        child: Column(children: [
                      DrawerHeader(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          photoBuilder(context, utente),
                          const SizedBox(
                            height: 5,
                          ),
                          nameBuilder(context, utente),
                        ],
                      )),
                      ...MenuItems.all.map(buildMenuItem).toList(),
                      const Spacer(
                        flex: 1,
                      ),
                      logoutBuilder(),
                      const SizedBox(
                        height: 30,
                      )
                    ]));
                  } else {
                    return Container();
                  }
                })));
  }

  Widget logoutBuilder() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
        child: Row(children: [
          Icon(
            Icons.exit_to_app,
            color: Colors.white,
          ),
          SizedBox(
            width: 28,
          ),
          Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16))
        ]),
        onTap: () async {
          {
            FirebaseAuth.instance.signOut();
          }
        },
      ),
    );
  }

  Widget nameBuilder(BuildContext context, Person utente) {
    return isMobile
        ? Row(
            children: [
              Text(utente.username.toString(),
                  style: const TextStyle(color: Colors.white))
            ],
          )
        : Row(
            children: [
              Text(utente.username.toString(),
                  style: const TextStyle(color: Colors.white))
            ],
          );
  }

  Widget photoBuilder(BuildContext context, Person utente) {
    return Row(
      children: [
        ('${utente.imageUrl}' != '')
            ? CircleAvatar(
                radius: 37,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage('${utente.imageUrl}'),
                ),
              )
            : CircleAvatar(
                radius: 37,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.black,
                    child: Text(
                      (utente.username.toString())
                          .toUpperCase()
                          .substring(0, 1),
                      style: TextStyle(
                          color: mainGreen,
                          fontSize: 20,
                          fontStyle: FontStyle.normal),
                    )),
              )
      ],
    );
  }

  Widget buildMenuItem(MenuItem item) => ListTileTheme(
        selectedColor: Colors.white,
        child: ListTile(
          selectedTileColor: Colors.black26,
          selected: currentItem == item,
          minLeadingWidth: 20,
          leading: Icon(item.icon),
          title: Text(item.title),
          onTap: () {
            onSelectedItem(item);
          },
        ),
      );
}

class MenuItem {
  final String title;
  final IconData icon;

  const MenuItem(this.title, this.icon);
}

class MenuItems {
  static const profile = MenuItem('Profile', LineIcons.user);
  static const home = MenuItem('Home', LineIcons.home);

  static const all = <MenuItem>[profile, home];
}
