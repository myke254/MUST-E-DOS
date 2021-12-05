import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:office_of_the_dean/screens/admin_page.dart';
import 'package:office_of_the_dean/screens/deans_page.dart';
import 'package:office_of_the_dean/screens/home_view.dart';
import 'package:office_of_the_dean/screens/register.dart';
import 'package:office_of_the_dean/screens/settings.dart';
import 'package:office_of_the_dean/services/tilesData.dart';
import 'package:office_of_the_dean/widgets/items.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  var size;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? _user = FirebaseAuth.instance.currentUser;
  int index = 0;
  late bool isDean;
  late bool isAdmin;
  late bool isUser;
  SolidController _controller = SolidController();
  PageController _pageController = PageController();
  late AnimationController _animationController;

  bool authorized = false;
  String regNo = '';
  String name = '';
  late String authStatus;
  checkAuth() {
    DocumentReference reference = firestore.collection('users').doc(_user!.uid);
    reference.snapshots().listen((value) {
      value['authorized'] == null
          ? print('djshdhjfgdfhsgdfkfkfkfkfkfkfkfkj')
          : print('it works');
      setState(() {
        if (value['authorized'] == null) {
          authorized = false;
          authStatus = '';
        } else if (value['authorized'] == true) {
          authorized = true;
          authStatus = 'authorized';
        } else {
          authorized = false;
          authStatus = 'pending';
        }
        value['regNo'] != null ? regNo = value['regNo'] : regNo = '';
        value['firstName'] != null
            ? name = '${value['firstName']} ${value['lastName']}'
            : regNo = '';
      });
    });
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Touch again to exit');
      return Future.value(false);
    }
    return Future.value(true);
  }

  Widget bottomBarRow() {
    return Padding(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Items(
              size: size,
              icon: Icons.home,
              onTap: () {
                _animationController.reset();
                _pageController.animateToPage(0,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInCubic);
              },
              label: 'Home',
              color: index == 0
                  ? Theme.of(context).brightness == Brightness.light
                      ? Colors.teal
                      : Colors.red
                  : Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white),
          Items(
              size: size,
              icon: Icons.settings,
              onTap: () {
                _pageController.animateToPage(1,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInCubic);
              },
              label: 'Settings',
              color: index == 1
                  ? Theme.of(context).brightness == Brightness.light
                      ? Colors.teal
                      : Colors.red
                  : Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white),
        ],
      ),
    );
  }

  Widget drawer() {
    return Material(
      child: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(.1)
            : Colors.white.withOpacity(.1),
        width: size.width / 1.27,
        child: Column(
          children: [
            DrawerHeader(
                decoration: BoxDecoration(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(45),
                      onTap: isUser
                          ? () {
                              authStatus.isEmpty
                                  ? Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => RegisterForm()))
                                  : authStatus == 'pending'
                                      ? Fluttertoast.showToast(
                                          msg: 'please wait for authorization')
                                      : print('authorized');
                            }
                          : () {},
                      child: Image.asset(
                        isDean
                            ? 'assets/avatar2.png'
                            : isAdmin
                                ? 'assets/admin.png'
                                : 'assets/avatar.png',
                        height: 80,
                        width: 80,
                        fit: BoxFit.fill,
                      ),
                    ),
                    VerticalDivider(
                      indent: 20,
                      endIndent: 20,
                    ),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isUser
                              ? Text(
                                  !authorized
                                      ? 'Awaiting authorization'
                                      : 'Authorized',
                                  style: GoogleFonts.varela(
                                      fontSize: 10,
                                      color: !authorized
                                          ? Colors.red
                                          : Colors.green),
                                )
                              : Container(),
                          Text(
                            name.isEmpty ? _user!.email.toString() : name,
                            style: GoogleFonts.varela(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isDean
                                ? 'Dean of Students'
                                : isAdmin
                                    ? 'admin'
                                    : regNo.isEmpty
                                        ? 'reg.no.'
                                        : regNo,
                            style: GoogleFonts.varela(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    var data = DrawerData().drawerTiles[index];
                    return DrawerTiles(
                      color: data['color'],
                      title: data['title'],
                      index: index,
                      image: data['image'],
                      subtitle: data['sub'],
                      hasSubtitle: data['hasSub'],
                    );
                  },
                  itemCount: DrawerData().drawerTiles.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    checkAuth();
    if (mounted) {
      _animationController = AnimationController(
          duration: const Duration(seconds: 1), vsync: this);
    }
    isDean = _user!.email == 'dean@email.com' ? true : false;
    isAdmin = _user!.email == 'admin@email.com' ? true : false;
    if (!isAdmin && !isDean) {
      isUser = true;
    } else {
      isUser = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
        extendBody: true,
        appBar: AppBar(
          leading: Image.asset(
            isDean
                ? 'assets/avatar2.png'
                : isAdmin
                    ? 'assets/admin.png'
                    : 'assets/avatar.png',
            fit: BoxFit.fill,
          ),
          titleTextStyle:
              GoogleFonts.varelaRound(fontSize: 17, color: Colors.blueGrey),
          iconTheme: IconThemeData(color: Colors.blueGrey),
          backgroundColor: Colors.white.withOpacity(.1),
          elevation: 0,
          // backgroundColor: Theme.of(context).brightness==Brightness.dark?Colors.red:Colors.grey,
          title: Text(
            'M.U.S.T E.D.O.S chapchap',
          ),
        ),
        endDrawer: drawer(),
        body: WillPopScope(
          onWillPop: onWillPop,
          child: Padding(
            padding: EdgeInsets.only(bottom: isAdmin ? 50 : 64),
            child: PageView(
              controller: _pageController,
              onPageChanged: (int i) {
                setState(() {
                  index = i;
                });
                print(index);
              },
              children: [
                isAdmin
                    ? AdminPage()
                    : isDean
                        ? Dean()
                        : HomeView(),
                SettingsPage()
              ],
            ),
          ),
        ),
        bottomSheet: !isAdmin
            ? !isDean
                ? BottomAppBar(
                    shape: CircularNotchedRectangle(),
                    notchMargin: 6,
                    child: SolidBottomSheet(
                      smoothness: Smoothness.high,
                      controller: _controller,
                      draggableBody: true,
                      headerBar: Container(
                          color: Colors.transparent,
                          height: 58,
                          child: bottomBarRow()),
                      body: Material(
                          child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            var data =
                                BottomSheetData().bottomSheetTiles[index];
                            return BottomBarTiles(
                              color: data['color'],
                              title: data['title'],
                              index: index,
                              image: data['image'],
                              subtitle: data['sub'],
                              hasSubtitle: data['hasSub'],
                            );
                          },
                          itemCount: BottomSheetData().bottomSheetTiles.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider();
                          },
                        ),
                      )),
                    ),
                  )
                : BottomAppBar(
                    child: bottomBarRow(),
                  )
            : BottomAppBar(
                child: bottomBarRow(),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: isAdmin
            ? Container()
            : isDean
                ? Container()
                : Material(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    child: AnimatedIconButton(
                      animationController: _animationController,
                      splashRadius: 30,
                      //size: 30,
                      onPressed: () {
                        _controller.isOpened
                            ? _controller.hide()
                            : _controller.show();

                        print(_controller.value);
                        print(_animationController.value);
                      },

                      icons: [
                        AnimatedIconItem(icon: Icon(Icons.arrow_upward)),
                        AnimatedIconItem(icon: Icon(Icons.arrow_downward)),
                      ],
                    ),
                  ));
  }
}
