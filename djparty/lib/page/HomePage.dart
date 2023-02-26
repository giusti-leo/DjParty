import 'package:djparty/Icons/spotify_icons.dart';
import 'package:djparty/page/GenerateShare.dart';
import 'package:djparty/page/Home.dart';
import 'package:djparty/page/InsertCode.dart';
import 'package:djparty/page/SignIn.dart';
import 'package:djparty/page/UserProfile.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  static String routeName = 'home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _connected = false;
  final ZoomDrawerController drawerController = ZoomDrawerController();
  MenuItem currentItem = MenuItems.home;

  bool _loading = false;
  String myToken = "";

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
    return SafeArea(
        child: Scaffold(
      body: ZoomDrawer(
        controller: drawerController,
        style: DrawerStyle.defaultStyle,
        mainScreen: getScreen(),
        menuScreen: Builder(builder: (context) {
          return MenuScreen(
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
        slideWidth: MediaQuery.of(context).size.width * .5,
        openCurve: Curves.fastLinearToSlowEaseIn,
        closeCurve: Curves.easeInCirc,
      ),
    ));
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  getScreen() {
    switch (currentItem) {
      case MenuItems.profile:
        return UserProfile(
          drawerController: drawerController,
        );
      case MenuItems.home:
        return Home(
          drawerController: drawerController,
        );
    }
  }
}

class MenuScreen extends StatelessWidget {
  MenuItem currentItem;
  ValueChanged<MenuItem> onSelectedItem;

  MenuScreen({
    Key? key,
    required this.currentItem,
    required this.onSelectedItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 178, 184, 172),
          body: SafeArea(
              child: Column(children: [
            DrawerHeader(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    (sp.imageUrl != '')
                        ? CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage("${sp.imageUrl}"),
                            radius: 35,
                          )
                        : CircleAvatar(
                            backgroundColor: Color(sp.image!),
                            child: Text(
                              sp.init.toString().toUpperCase(),
                              style: TextStyle(
                                color: Color(sp.initColor!),
                                fontSize: 20,
                              ),
                            ))
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text(sp.name!,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12))
                  ],
                )
              ],
            )),
            Spacer(
              flex: 1,
            ),
            ...MenuItems.all.map(buildMenuItem).toList(),
            Spacer(
              flex: 2,
            ),
            /*
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: (() => nextScreen(context, const HomePage())),
                child: Row(children: const [
                  Icon(
                    Icons.home,
                    color: Color.fromARGB(255, 215, 208, 208),
                  ),
                  SizedBox(
                    width: 28,
                  ),
                  Text('Home',
                      style: TextStyle(
                          color: Color.fromARGB(255, 215, 208, 208),
                          fontSize: 20))
                ]),
              ),
            ),
            const Divider(
              thickness: 2,
              color: Color.fromARGB(255, 215, 208, 208),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                child: Row(children: const [
                  Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 215, 208, 208),
                  ),
                  SizedBox(
                    width: 28,
                  ),
                  Text('Profile',
                      style: TextStyle(
                          color: Color.fromARGB(255, 215, 208, 208),
                          fontSize: 20))
                ]),
                onTap: () => nextScreen(context, UserProfile()),
              ),
            ),
            const Spacer(),
            const Divider(
              thickness: 2,
              color: Color.fromARGB(255, 215, 208, 208),
            ),*/
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                child: Row(children: const [
                  Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 28,
                  ),
                  Text('Logout',
                      style: TextStyle(color: Colors.white, fontSize: 12))
                ]),
                onTap: () async {
                  {
                    await sp.userSignOut();
                  }
                },
              ),
            ),
            const SizedBox(
              height: 30,
            )
          ]))),
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
