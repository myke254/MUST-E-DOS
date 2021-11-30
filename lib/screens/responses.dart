import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:office_of_the_dean/screens/specific_requests.dart';
import 'package:office_of_the_dean/services/auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReceivedRequests extends StatefulWidget {
  const ReceivedRequests({
    Key? key,
    required this.appBarText,
    required this.docId,
    required this.img,
  }) : super(key: key);
  final appBarText;
  final docId;
  final img;

  @override
  _ReceivedRequestsState createState() => _ReceivedRequestsState();
}

class _ReceivedRequestsState extends State<ReceivedRequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.blueGrey),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.appBarText,
          style: TextStyle(color: Colors.blueGrey),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CachedNetworkImage(
              height: 40,
              width: 40,
              imageUrl: widget.img,
              placeholder: (context, url) => Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Center(
                    child: CircularProgressIndicator(),
                  )),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('requests')
              .doc(widget.docId)
              .collection('requests')
              .where('seen', isEqualTo: false)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return snapshot.hasData
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot docSnap = snapshot.data!.docs[index];
                        return ListTile(
                          tileColor: Colors.grey.withOpacity(.3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          isThreeLine: true,
                          leading: CircleAvatar(
                            child: Text(docSnap['sentBy']
                                .toString()
                                .substring(0, 1)
                                .toUpperCase()),
                          ),
                          title:
                              Text('sent by: ${docSnap['sentBy'].toString()}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('pending approval'),
                              Text(
                                  '${timeago.format(docSnap['time'].toDate())}')
                            ],
                          ),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => Request(
                                      category: widget.docId,
                                      documentId: docSnap.id,
                                      name: docSnap['sentBy'],
                                      time: timeago
                                          .format(docSnap['time'].toDate()),
                                      approved: docSnap['approved'],
                                      seen: docSnap['seen'],
                                      uid: docSnap['uid'],
                                      moreInfo: docSnap['moreInfo'],
                                      fileUrl: docSnap['documentUrl']))),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider();
                      },
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          }),
    );
  }
}
