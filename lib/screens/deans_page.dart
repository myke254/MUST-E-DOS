import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:office_of_the_dean/services/auth_service.dart';
import 'package:office_of_the_dean/widgets/items.dart';

class Dean extends StatefulWidget {
  const Dean({Key? key}) : super(key: key);

  @override
  _DeanState createState() => _DeanState();
}

class _DeanState extends State<Dean> with AutomaticKeepAliveClientMixin<Dean> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.height,
      child: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('functions').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return snapshot.hasData
              ? ListView.separated(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, index) {
                    DocumentSnapshot item = snapshot.data!.docs[index];
                    return StreamBuilder<QuerySnapshot>(
                        stream: firestore
                            .collection('requests')
                            .doc(item.id)
                            .collection('requests')
                            .where('seen', isEqualTo: false)
                            .snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snap2) {
                          return snap2.hasData
                              ? Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Tiles(
                                    img: item['img'],
                                    label: item.id,
                                    docLength: snap2.data!.docs.length,
                                  ),
                                )
                              : Container();
                        });
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      indent: 40,
                      endIndent: 40,
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Test extends StatelessWidget {
  const Test({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
