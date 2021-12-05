import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:office_of_the_dean/services/auth_service.dart';

class QuickActions extends StatefulWidget {
  const QuickActions({Key? key, this.stream, this.image, this.title})
      : super(key: key);
  final stream;
  final image;
  final title;
  @override
  _QuickActionsState createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  late bool isDean;
  late bool isAdmin;
  late bool isUser;
  String userName = '';
  // double _inputHeight = 50;
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();

  getUserName() async {
    await firestore.collection('users').doc(user!.uid).get().then((value) {
      if (value['authorized'] != null) {
        setState(() {
          userName = '${value['firstName']} ${value['lastName']}';
        });
      }
    });
  }

  // void _checkInputHeight() async {
  //   int count = _controller.text.split('\n').length;

  //   if (count == 0 && _inputHeight == 50.0) {
  //     return;
  //   }
  //   if (count <= 5) {
  //     // use a maximum height of 6 rows
  //     // height values can be adapted based on the font size
  //     var newHeight = count == 0 ? 50.0 : 28.0 + (count * 18.0);
  //     setState(() {
  //       _inputHeight = newHeight;
  //     });
  //   }
  // }

  @override
  void initState() {
    //   _controller.addListener(_checkInputHeight);
    getUserName();
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.title),
      ),
      body: isUser
          ? widget.title.toString().contains('Help')
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20)),
                                width: MediaQuery.of(context).size.width * .7,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Hi ${userName.isEmpty ? user!.email!.split('@').first : userName.split(' ').first}, How may we be of assistance?',
                                      style: GoogleFonts.heebo(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Scrollbar(
                                  controller: _scrollController,
                                  isAlwaysShown: true,
                                  child: TextField(
                                    scrollController: _scrollController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    controller: _controller,
                                    textInputAction: TextInputAction.newline,
                                    onChanged: (s) => {print(s.length)},
                                    decoration: InputDecoration(
                                        isDense: true,
                                        prefixIcon: Icon(
                                          Icons.message,
                                          size: 15,
                                        ),
                                        labelText: 'type here',
                                        labelStyle: TextStyle(fontSize: 12),
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: IconButton(
                                    splashRadius: 24,
                                    onPressed: () {
                                      _controller.text.isEmpty
                                          ? print('empty')
                                          : print(_controller.text);
                                    },
                                    icon: Icon(Icons.send)),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'describe your problem here ☝ and we shall get back at you ASAP',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: widget.stream,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    return snapshot.hasData
                        ? SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: snapshot.data!.docs
                                    .map((e) => Container(
                                          child: Column(
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  style: GoogleFonts.brawler(),
                                                  children: [
                                                    TextSpan(
                                                        text: 'Q: ',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 23,
                                                          color: Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.white
                                                              : Colors.black,
                                                        )),
                                                    TextSpan(
                                                        text:
                                                            '${e['question']}\n',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.red,
                                                            fontSize: 18)),
                                                    TextSpan(
                                                        text: 'A:  ',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 23,
                                                          color: Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.white
                                                              : Colors.blueGrey,
                                                        )),
                                                    TextSpan(
                                                        text:
                                                            ' ${e['answer']}\n',
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            color:
                                                                Colors.green)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          )
                        : Container();
                  })
          : Container(),
    );
  }
}
