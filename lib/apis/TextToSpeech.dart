import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

class TextToSpeech {

  static const platform = const MethodChannel('cymru.techiaith.flutter.macsen');

  static String ttsApiKey = '62bb5885-294d-4fcf-9b2a-23195723ea07';

  Future<void> speak(String text) async {

    HttpClient httpClient = new HttpClient();

    var request = await httpClient.getUrl(new Uri.https(
        'api.techiaith.org', '/marytts/v1',
        {
          "api_key": ttsApiKey,
          "format": 'wav',
          "text": text
        }));

    var response = await request.close();

    if (response.statusCode==200) {
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await getTemporaryDirectory()).path;

      String filename = "tmpttsfile.wav";
      File file = new File('$dir/$filename');
      await file.writeAsBytes(bytes);

      platform.invokeMethod('playRecording', file.path);
    }

  }

}
