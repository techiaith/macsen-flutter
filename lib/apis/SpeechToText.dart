import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

class SpeechToText {

  final String _apiAuthorityUrl = 'api.techiaith.org';

  //
  Future<String> transcribe(String recordedFilePath) async {

    String result = '';

    // send to server ! :)
    //var url = "http://macsen-stt.techiaith.cymru/dsserver/handleaudio/";


    //
    File fileToUpload = new File(recordedFilePath);
    int wav_length = fileToUpload.lengthSync();
    Stream uploadStream = fileToUpload.openRead();

    try {

      MultipartRequest request = new MultipartRequest("POST",
          new Uri.https(
              _apiAuthorityUrl,
              "/deepspeech/dev/speech_to_text/"
          ));

      request.files.add(
          new MultipartFile(
              'soundfile',
              uploadStream,
              wav_length,
              filename: basename(recordedFilePath),
              contentType: new MediaType('audio','wav')
          )
      );

      StreamedResponse response = await request.send();

      if (response.statusCode==200)
      {
          StringBuffer sb = new StringBuffer();
          await for (String a in response.stream.transform(utf8.decoder)){
              sb.write(a);
          }
          result = sb.toString();
      }

    } on Exception catch (e) {
      print(e);
      return null;
    }

    return result;

  }

}
