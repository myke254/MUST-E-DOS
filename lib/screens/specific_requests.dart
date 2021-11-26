import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      this.moreInfo})
      : super(key: key);
  final name;
  final time;
  final approved;
  final seen;
  final uid;
  final fileUrl;
  final moreInfo;
  @override
  _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request> {
  late String fileName;
  bool downloading = false;

  String progress = '0';

  bool isDownloaded = false;
  bool? fileExists;
  CancelToken _cancelToken = CancelToken();
  late String uri;
  String path = '';

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

    Dio dio = Dio();

    dio.download(
      uri,
      savePath,
      cancelToken: _cancelToken,
      onReceiveProgress: (rcv, total) {
        print(
            'received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');

        setState(() {
          progress = ((rcv / total) * 100).toStringAsFixed(0);
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
        }

        downloading = false;
      });
    });
  }

  Future<void> openFile() async {
    await OpenFile.open(path).then((value) => print(value.message));
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
      body: fileExists != null
          ? Padding(
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
                  fileExists!
                      ? Flexible(
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            elevation: 12,
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
                                downloadFile(uri, fileName);
                              },
                              label: Text(fileName),
                              icon: Icon(Icons.download)),
                  downloading
                      ? LinearProgressIndicator(
                          // color: Colors.grey,
                          value: double.parse(progress) / 100,
                        )
                      : isDownloaded
                          ? TextButton.icon(
                              onPressed: () {
                                openFile();
                                print(path);
                              },
                              icon: Icon(Icons.folder_open),
                              label: Text(
                                '$fileName',
                                overflow: TextOverflow.ellipsis,
                              ))
                          : SizedBox(),
                ],
              ),
            )
          : Container(),
    );
  }
}
