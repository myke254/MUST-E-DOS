import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:office_of_the_dean/screens/deans_page.dart';
import 'package:office_of_the_dean/screens/home_view.dart';
import 'package:office_of_the_dean/screens/settings.dart';
import 'package:office_of_the_dean/services/bottom_sheet_data.dart';
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
  late bool isAdmin;
  SolidController _controller = SolidController();
  PageController _pageController = PageController();
  late AnimationController _animationController;
  PreferredSizeWidget appBar() {
    return AppBar(
      toolbarHeight: 110,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(45),
            onTap: () {},
            child: Image.asset(
              isAdmin ? 'assets/avatar2.png' : 'assets/avatar.png',
              height: 90,
              width: 90,
              fit: BoxFit.fill,
            ),
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user!.email.toString(),
                  style: GoogleFonts.varela(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isAdmin ? 'Dean of Students' : 'reg.no.',
                  style: GoogleFonts.varela(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    isAdmin = _user!.email == 'admin@email.com' ? true : false;
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: appBar(),
        body: Padding(
          padding: EdgeInsets.only(bottom: 64),
          child: PageView(
            controller: _pageController,
            onPageChanged: (int i) {
              setState(() {
                index = i;
              });
              print(index);
            },
            children: [isAdmin ? Dean() : HomeView(), SettingsPage()],
          ),
        ),
        bottomSheet: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 6,
          child: SolidBottomSheet(
            smoothness: Smoothness.high,
            controller: _controller,
            draggableBody: true,
            headerBar: Container(
                color: Colors.transparent,
                height: 58,
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
                                : Colors.greenAccent
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
                                : Colors.greenAccent
                            : Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                : Colors.white),
                  ],
                )),
            body: Material(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  var data = BottomSheetData().bottomSheetTiles[index];
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
              // child: ListView(
              //     children: BottomSheetData().bottomSheetTiles.entries.map((e) {
              //   var index = BottomSheetData().bottomSheetTiles.keys.length;
              //   return BottomBarTiles(
              //     index: index,
              //     image: e.value['image'],
              //     title: e.value['title'],
              //     subtitle: e.value['sub'],
              //     hasSubtitle: e.value['hasSub'],
              //   );
              // }).toList()),
            )),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Material(
          color: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: AnimatedIconButton(
            animationController: _animationController,
            splashRadius: 30,
            //size: 30,
            onPressed: () {
              _controller.isOpened ? _controller.hide() : _controller.show();

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
