import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:office_of_the_dean/services/auth_service.dart';
import 'package:office_of_the_dean/services/firebase_api.dart';
import 'package:path/path.dart';

class ResponseDialog extends StatefulWidget {
  const ResponseDialog(
      {Key? key,
      this.title,
      this.content,
      this.category,
      this.documentId,
      required this.controller,
      required this.approved})
      : super(key: key);
  final title;
  final content;
  final category;
  final documentId;
  final bool approved;
  final TextEditingController controller;
  @override
  _ResponseDialogState createState() => _ResponseDialogState();
}

class _ResponseDialogState extends State<ResponseDialog> {
  File? file;
  FilePickerStatus? _status;
  //User? _user = FirebaseAuth.instance.currentUser;
  late List<String> instructions;
  UploadTask? task;
  String percentage1 = '0';

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
          .doc(widget.category)
          .collection('requests')
          .doc(widget.documentId)
          .set({
        'responseDocumentUrl': urlDownload,
        'seen': true,
        'approved': widget.approved,
        'moreInfoFromDean': widget.controller.text.isNotEmpty
            ? widget.controller.text
            : 'no more information provided'
      }, SetOptions(merge: true));
    });
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          task.whenComplete(() {
            Navigator.of(context).popUntil((route) => route.isFirst);
            return Navigator.of(context)
                .pushReplacement(MaterialPageRoute(
                    builder: (context) => AuthService().handleAuth()))
                .then((value) => Fluttertoast.showToast(msg: 'done'));
          });
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final percentage;
            final progress = snap.bytesTransferred / snap.totalBytes;
            percentage = (progress * 100).toStringAsFixed(2);

            percentage1 = percentage;

            return Material(
              color: Colors.transparent,
              child: Container(
                height: 38,
                child: Text(
                  '$percentage %',
                  style: GoogleFonts.monda(fontSize: 20),
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      );
  respondWithNoDoc() {
    firestore
        .collection('requests')
        .doc(widget.category)
        .collection('requests')
        .doc(widget.documentId)
        .set({
      'seen': true,
      'approved': widget.approved,
      'moreInfoFromDean': widget.controller.text
    }, SetOptions(merge: true)).then((value) =>
            Fluttertoast.showToast(msg: 'message uploaded successfuly'));
  }

  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? basename(file!.path) : '';
    return CupertinoAlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(fileName.isNotEmpty ? '' : widget.content),
          Flexible(
            child: fileName.isNotEmpty
                ? _status == FilePickerStatus.done
                    ? Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.monda(color: Colors.green),
                      )
                    : _status == FilePickerStatus.picking
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            fileName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.monda(color: Colors.green),
                          )
                : SizedBox(),
          ),
          task != null
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: LinearProgressIndicator(),
                    ),
                    Text('uploading ...')
                  ],
                )
              : Container()
        ],
      ),
      actions: [
        file != null
            ? TextButton.icon(
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
                label: Text(task != null ? 'cancel' : 'remove file'),
              )
            : TextButton.icon(
                onPressed: () {
                  selectFile();
                },
                icon: Icon(
                  Icons.attach_file,
                  color: Colors.blueGrey,
                ),
                label: Text('attach a file'),
              ),
        file != null
            ? task == null
                ? TextButton.icon(
                    onPressed: () {
                      uploadFile();
                    },
                    icon: Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                    label: Text('proceed'),
                  )
                : Center(
                    child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: buildUploadStatus(task!),
                  ))
            : TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.controller.text.isNotEmpty
                      ? showDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'You have not attached any document, do you wish to proceed with the information provided in the text area?',
                                      style: GoogleFonts.varela(),
                                    ),
                                    Text(
                                      'please confirm you have all your information right, this action is irreversible',
                                      style: GoogleFonts.varela(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('edit'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('continue'),
                                    onPressed: () {
                                      respondWithNoDoc();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AuthService().handleAuth()));
                                    },
                                  )
                                ],
                              ))
                      : Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.send,
                  color: Colors.amber,
                ),
                label: Text('proceed'),
              ),
      ],
    );
  }
}
