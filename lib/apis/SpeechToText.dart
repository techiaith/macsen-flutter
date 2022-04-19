import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

class SpeechToText {

  final String _apiAuthorityUrl = 'api.techiaith.org';

  final String _recognizeApiPath = "coqui-stt/macsen/";
  final String _transcribeApiPath = "wav2vec2/";

  //
  Future<String> transcribe(String recordedFilePath) async {
    return _speech_to_text(recordedFilePath, _transcribeApiPath);
  }

  //
  Future<String> recognize(String recordedFilePath) async {
    return _speech_to_text(recordedFilePath, _recognizeApiPath);
  }

  Future<String> _speech_to_text(String recordedFilePath, String apiPath) async {
    String result = '';

    File fileToUpload = new File(recordedFilePath);
    int wav_length = fileToUpload.lengthSync();
    Stream uploadStream = fileToUpload.openRead();

    print ("SpeechToTextAPI : transcribe $recordedFilePath");

    try {

      MultipartRequest request = new MultipartRequest("POST",
          new Uri.https(
              _apiAuthorityUrl,
              apiPath + "speech_to_text/"
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

    print (result);

    return result;

  }

  Future<String> getVersions() async {
    return await httpsGet(_recognizeApiPath + 'versions/');
  }


  Future<String> httpsGet(String unencodedPath,
      [Map<String, String> queryParameters]) async {
    try {
      HttpClient httpClient = new HttpClient();
      var request = await httpClient.getUrl(
          new Uri.https(
              _apiAuthorityUrl,
              unencodedPath,
              queryParameters));

      var response = await request.close();

      if (response.statusCode == 200) {
        StringBuffer sb = new StringBuffer();
        await for (String a in response.transform(utf8.decoder)) {
          sb.write(a);
        }
        return sb.toString();
      }
    }on Exception catch (e) {
      print (e);
    }
    return '';
  }


}
