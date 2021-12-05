import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:office_of_the_dean/screens/home.dart';
import 'package:office_of_the_dean/services/auth_service.dart';
import 'package:office_of_the_dean/services/firebase_api.dart';
import 'package:path/path.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({
    Key? key,
    required this.appBarText,
    required this.docId,
    required this.img,
  }) : super(key: key);
  final String appBarText;
  final String docId;
  final String img;
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  User? _user = FirebaseAuth.instance.currentUser;
  late List<String> instructions;
  UploadTask? task;
  File? file;
  FilePickerStatus? _status;
  TextEditingController _controller = TextEditingController();
  bool authorized = false;
  String regNo = '';
  String name = '';
  checkAuth() {
    firestore.collection('users').doc(_user!.uid).get().then((value) {
      setState(() {
        if (value['authorized'] == true) {
          authorized = true;
        } else {
          authorized = false;
        }
        value['regNo'] != null ? regNo = value['regNo'] : regNo = '';
        value['firstName'] != null
            ? name = '${value['firstName']} ${value['lastName']}'
            : regNo = '';
      });
    });
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        onFileLoading: (pickerStatus) {
          setState(() {
            _status = pickerStatus;
          });
          print(_status);
        },
        allowMultiple: false,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'xlsx']);

    if (result == null) return;
    final path = result.files.single.path!;
    setState(() => file = File(path));
  }

  Future uploadFile() async {
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    await task!.whenComplete(() async {}).then((value) async {
      final urlDownload = await value.ref.getDownloadURL();

      print('Download-Link: $urlDownload');
      print('im done uploading');
      await firestore
          .collection('requests')
          .doc(widget.docId)
          .collection('requests')
          .doc()
          .set({
        'time': DateTime.now(),
        'sentBy': !authorized ? _user!.email : name,
        'uid': _user!.uid,
        'regNo': !authorized ? '' : regNo,
        'documentUrl': urlDownload,
        'seen': false,
        'approved': false,
        'moreInfo': _controller.text.isNotEmpty
            ? _controller.text
            : 'no more information provided'
      }).then((val) async {
        await firestore
            .collection('requests')
            .doc(widget.docId)
            .set({'latestDocTime': DateTime.now()});
        Fluttertoast.showToast(
            msg: 'uploaded successfully',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM);
        setState(() {
          file = null;
          task = null;
        });
        _controller.clear();
      });
    });
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Text(
              '$percentage %',
              style: GoogleFonts.varela(fontSize: 20),
            );
          } else {
            return Container();
          }
        },
      );

  @override
  void initState() {
    checkAuth();
    instructions = [
      'create a document file with your phone or pc',
      'type a formal letter as you normally would addressed to the Dean of Students requesting for ${widget.docId == 'function' ? 'hosting a function in school' : widget.docId == 'appointments' ? 'an appointment with the dean' : widget.docId == 'vehicle requests' ? 'a vehicle' : widget.docId},\nnote: the letter must be formal',
      'save the file in this device where you can easily access it',
      'attach the file using the button below and send',
      'you may provide more information about your request in the text area'
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fileName =
        file != null ? basename(file!.path) : 'No File Selected yet';
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(title: Text(widget.appBarText), actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              widget.img,
              height: 40,
              width: 40,
            ),
          ),
        ]),
        body: StreamBuilder<DocumentSnapshot>(
          stream:
              firestore.collection('functions').doc(widget.docId).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            return Container(
              height: size.height,
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('instructions: '),
                      ),
                      Container(
                        height: 160,
                        width: size.width,
                        child: ListView.separated(
                          itemCount: instructions.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Text(
                              '${(index + 1).toString()}. ${instructions[index]}',
                              style: GoogleFonts.montserratAlternates(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: 10,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            file == null
                                ? TextButton.icon(
                                    onPressed: () {
                                      selectFile();
                                    },
                                    icon: Icon(
                                      Icons.attach_file,
                                      color: Colors.blueGrey,
                                    ),
                                    label: Text('attach a file'),
                                  )
                                : TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        file = null;
                                        task = null;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    label: Text('remove file'),
                                  ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 12,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: _status == FilePickerStatus.done
                                ? Text(
                                    fileName,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.monda(),
                                  )
                                : _status == FilePickerStatus.picking
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Text(
                                        fileName,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.monda(),
                                      ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Provide more information about your request below',
                          style: GoogleFonts.varela(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          maxLength: 500,
                          controller: _controller,
                          maxLines: 8,
                          decoration: InputDecoration.collapsed(
                              fillColor: Colors.teal.withOpacity(.1),
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              hintText: "Enter your text here"),
                        ),
                      ),
                      file != null
                          ? task == null
                              ? Row(
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => uploadFile(),
                                      icon: Icon(
                                        Icons.send,
                                        color: Colors.green,
                                      ),
                                      label: Text('send'),
                                    ),
                                  ],
                                )
                              : buildUploadStatus(task!)
                          : Container()
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
