import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:office_of_the_dean/services/auth_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('authRequests')
            .where('authorized', isEqualTo: false)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return snapshot.hasData
              ? Column(
                  children: snapshot.data!.docs
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(
                                right: 8.0, left: 8.0, top: 4.0, bottom: 4.0),
                            child: ListTile(
                              onTap: () {
                                firestore
                                    .collection('authRequests')
                                    .doc(e.id)
                                    .update({'seen': true});
                                int age = DateTime.now().year -
                                    (e['DoB'] as Timestamp).toDate().year;
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoAlertDialog(
                                        title: Text(
                                            '${e['firstName']} ${e['lastName']}'),
                                        content: Column(
                                          children: [
                                            Divider(),
                                            Text(
                                                '${(e['school'] as Map).values.toList().join('\n')}',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                            Text(e['regNo']),
                                            Divider(),
                                            Text(
                                              'personal information',
                                              style: TextStyle(fontSize: 10),
                                            ),
                                            Text(
                                                'Date of Birth: ${(e['DoB'] as Timestamp).toDate().toString().substring(0, 10)}'),
                                            Text('Age: $age years'),
                                            Text(e['gender'])
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Ignore')),
                                          TextButton(
                                              onPressed: () {
                                                firestore
                                                    .collection('authRequests')
                                                    .doc(e.id)
                                                    .update({
                                                      'authorized': true,
                                                    })
                                                    .then((value) => firestore
                                                            .collection('users')
                                                            .doc(e.id)
                                                            .update({
                                                          'authorized': true,
                                                        }))
                                                    .then((value) =>
                                                        Navigator.of(context)
                                                            .pop());
                                              },
                                              child: Text('Authorize'))
                                        ],
                                      );
                                    });
                              },
                              leading: Icon(
                                CupertinoIcons.person_alt_circle,
                                size: 60,
                              ),
                              title: Text('${e['firstName']} ${e['lastName']}'),
                              subtitle: Text(
                                  '${(e['school'] as Map).values.toList().join('\n')}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      overflow: TextOverflow.ellipsis)),
                            ),
                          ))
                      .toList(),
                )
              : Center(child: CircularProgressIndicator());
        });
  }
}
