import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:office_of_the_dean/widgets/deans_response_alert_dialog.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class Request extends StatefulWidget {
  const Request(
      {Key? key,
      this.name,
      this.time,
      this.approved,
      this.seen,
      this.uid,
      this.fileUrl,
      this.moreInfo,
      this.category,
      this.documentId})
      : super(key: key);
  final name;
  final time;
  final approved;
  final seen;
  final uid;
  final fileUrl;
  final moreInfo;
  final category;
  final documentId;
  @override
  _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request> {
  late String fileName;
  bool downloading = false;

  String progress = '0';

  bool isDownloaded = false;
  bool fileExists = false;
  CancelToken _cancelToken = CancelToken();
  late String uri;
  String path = '';
  double? filSize;
  double? rcvd;
  Dio dio = Dio();
  TextEditingController _controller = TextEditingController();

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

  String getFileName(String url) {
    RegExp regExp = new RegExp(r'.+(\/|%2F)(.+)\?.+');
    //This Regex won't work if you remove ?alt...token
    var matches = regExp.allMatches(url);

    var match = matches.elementAt(0);
    setState(() {
      fileName = Uri.decodeFull(match.group(2)!);
    });
    print(fileName);

    uri = widget.fileUrl;
    print(uri);
    return Uri.decodeFull(match.group(2)!);
  }

  checkFile() async {
    Directory? dir = await getExternalStorageDirectory();

    setState(() {
      path = '${dir!.path}/$fileName';
    });
    print(path);
    await File(path).exists().then((value) {
      setState(() {
        fileExists = value;
      });
      print(fileExists);
    });

    return File(path).exists();
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';

    Directory? dir = await getExternalStorageDirectory();

    path = '${dir!.path}/$uniqueFileName';
    print(path);
    return path;
  }

  Future<void> downloadFile(uri, filename) async {
    setState(() {
      downloading = true;
    });

    String savePath = await getFilePath(filename);

    try {
      await dio.download(
        uri,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (rcv, total) {
          setState(() {
            filSize = total / 1000;
          });
          print(
              'received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');

          setState(() {
            progress = ((rcv / total) * 100).toStringAsFixed(0);
            rcvd = rcv / 1000;
          });

          if (progress == '100') {
            setState(() {
              isDownloaded = true;
            });
          } else if (double.parse(progress) < 100) {}
        },
        deleteOnError: true,
      ).then((_) {
        setState(() {
          if (progress == '100') {
            isDownloaded = true;
            fileExists = true;
          }

          downloading = false;
        });
      });
    } on DioError catch (e) {
      print(e);
    }
  }

  Future<void> openFile() async {
    await OpenFile.open(path).then((value) => print(value.message));
  }

  cancelDownload() async {
    try {
      _cancelToken.cancel();
      setState(() {
        downloading = false;
      });
      dio.interceptors.clear();
      Fluttertoast.showToast(msg: 'download cancelled');
    } on DioError catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getFileName(widget.fileUrl);
    checkFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.blueGrey),
          title: Text(
            widget.name,
            style: TextStyle(color: Colors.blueGrey),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  '${widget.name} attached a document',
                  style: GoogleFonts.varela(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              fileExists
                  ? Flexible(
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                        child: TextButton.icon(
                            onPressed: () {
                              openFile();
                              print(path);
                            },
                            icon: Icon(Icons.folder_open),
                            label: Text(
                              '$fileName',
                              overflow: TextOverflow.ellipsis,
                            )),
                      ),
                    )
                  : isDownloaded
                      ? SizedBox()
                      : TextButton.icon(
                          onPressed: () {
                            downloading
                                ? Fluttertoast.showToast(msg: 'relax 😁')
                                : downloadFile(uri, fileName);
                          },
                          label: Text(fileName),
                          icon: Icon(Icons.download)),
              downloading
                  ? Container(
                      child: Column(
                        //
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .85,
                                child: LinearProgressIndicator(
                                  value: double.parse(progress) / 100,
                                ),
                              ),
                              SizedBox(
                                // height: 20,
                                width: MediaQuery.of(context).size.width * .10,
                                child: IconButton(
                                    splashRadius: 15,
                                    iconSize: 20,
                                    onPressed: () {
                                      cancelDownload();
                                      Navigator.of(context).pop();
                                    },
                                    icon: Icon(Icons.cancel_outlined)),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rcvd != null
                                    ? '${rcvd.toString()}/${filSize!.toString()} KBs received'
                                    : '0/0 KBs received',
                                style: GoogleFonts.varela(),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '$progress%',
                                style: GoogleFonts.varela(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  : SizedBox(),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blueGrey.withOpacity(.2)),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.moreInfo),
                  ),
                ),
              ),
              fileExists
                  ? Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              'you may provide additional information in the text area below',
                              style: GoogleFonts.varela(fontSize: 10),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              maxLength: 500,
                              controller: _controller,
                              maxLines: 6,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10.0),
                                  fillColor: Colors.grey.withOpacity(.2),
                                  filled: true,
                                  isDense: true,
                                  hintText: "Enter your text here"),
                            ),
                          ),
                          ButtonBar(
                            children: [
                              TextButton(
                                  onPressed: () {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return ResponseDialog(
                                            title:
                                                'Deny request made by ${widget.name.toString().split('@').first}?',
                                            content:
                                                'please attach a write up expressing the reason for disapproving this request',
                                            category: widget.category,
                                            documentId: widget.documentId,
                                            controller: _controller,
                                            approved: false,
                                          );
                                        });
                                  },
                                  child: Text(
                                    ' deny request',
                                    style:
                                        GoogleFonts.varela(color: Colors.red),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return ResponseDialog(
                                            title:
                                                'Approve request made by ${widget.name.toString().split('@').first}?',
                                            content:
                                                'please attach a write up for documentation purposes',
                                            category: widget.category,
                                            documentId: widget.documentId,
                                            controller: _controller,
                                            approved: true,
                                          );
                                        });
                                  },
                                  child: Text('Approve request'))
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ));
  }
}
