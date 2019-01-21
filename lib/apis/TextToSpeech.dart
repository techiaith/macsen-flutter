import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:macsen/utils/md5.dart';

class TextToSpeech {

  static String ttsApiKey = '62bb5885-294d-4fcf-9b2a-23195723ea07';

  Future<String> speak(String text) async {

    try {
      HttpClient httpClient = new HttpClient();
      var request = await httpClient.getUrl(new Uri.https(
          'api.techiaith.org', '/marytts/v1',
          {
            "api_key": ttsApiKey,
            "format": 'wav',
            "text": text
          }));

      var response = await request.close();

      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        String dir = (await getTemporaryDirectory()).path;

        String filename = "tts_" + Md5Hash.create(text) + ".wav";
        String filepath = '$dir/$filename';
        File file = new File(filepath);
        await file.writeAsBytes(bytes);
        return filepath;
      }
    }  on Exception catch (e) {
      print (e);
    }

    return '';
  }

}
