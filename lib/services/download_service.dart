import 'dart:io';

import 'package:flutter/foundation.dart';

class DownloadFile {
  Future<String> downloadFile(String url, String fileName, String dir) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    // String myUrl = '';

    try {
      //myUrl = url + '/' + fileName;
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == 200) {
        print(response.statusCode);
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        print(filePath);
        file = File(filePath);
        await file.writeAsBytes(bytes);
        print('done');
      } else
        filePath = 'Error code: ' + response.statusCode.toString();
    } catch (ex) {
      filePath = 'Can not fetch url';
      print(ex);
    }

    return filePath;
  }
}
