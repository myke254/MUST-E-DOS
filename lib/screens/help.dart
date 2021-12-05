import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Help extends StatefulWidget {
  const Help({Key? key, this.title, this.stream, this.image}) : super(key: key);
  final title;
  final stream;
  final image;
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  late bool isDean;
  late bool isAdmin;
  late bool isUser;
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    isDean = user!.email == 'dean@email.com' ? true : false;
    isAdmin = user!.email == 'admin@email.com' ? true : false;
    if (!isAdmin && !isDean) {
      isUser = true;
    } else {
      isUser = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isUser
        ? Scaffold(
            appBar: AppBar(
              leading: Image.asset(widget.image),
              title: Text(widget.title),
            ),
          )
        : isAdmin
            ? Container()
            : Container();
  }
}
