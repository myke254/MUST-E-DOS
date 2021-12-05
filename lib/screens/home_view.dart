import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:office_of_the_dean/screens/register.dart';
import 'package:office_of_the_dean/screens/requests.dart';
import 'package:office_of_the_dean/services/auth_service.dart';
import 'package:office_of_the_dean/widgets/items.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin<HomeView> {
  User? user = FirebaseAuth.instance.currentUser;
  bool authorized = false;
  String regNo = '';
  String name = '';
  late String authStatus;
  checkAuth() {
    DocumentReference reference = firestore.collection('users').doc(user!.uid);
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

  @override
  void initState() {
    checkAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      child: Container(
        height: size.height,
        width: size.width,
        child: StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('functions').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return !snapshot.hasData
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 8,
                          crossAxisCount: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? (size.width / 150).floor()
                              : (size.width / 160).floor()),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot item = snapshot.data!.docs[index];
                        return Cards(
                            label: item['name'],
                            img: item['img'],
                            taps: () {
                              authStatus.isEmpty
                                  ? Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => RegisterForm()))
                                  : authStatus == 'pending'
                                      ? Fluttertoast.showToast(
                                          msg: 'please wait for authorization')
                                      : Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => RequestPage(
                                                    appBarText: item['name'],
                                                    docId: item.id,
                                                    img: item['img'],
                                                  )));
                            });
                      });
            }),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
