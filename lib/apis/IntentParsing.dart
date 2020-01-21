import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

class IntentParsing {

  final String _apiAuthorityUrl = 'api.techiaith.org';
  final String _apiPath = '/assistant/dev/';


  Future<String> performSkill(String text,
                              double latitude,
                              double longitude) async {

    print ("performSkill $text, $latitude, $longitude");

    return await httpsGet(
          '/assistant/perform_skill',
          {
            "text": text,
            "latitude" : latitude.toString(),
            "longitude": longitude.toString()
          }
      );
  }


  Future<String> getUnrecordedSentence(String uid) async {
    return await httpsGet(
        _apiPath + 'get_unrecorded_sentence',
        {
          "uid" : uid
        }
    );
  }


  Future<String> getAllSentences() async {
    return await httpsGet(_apiPath + 'get_all_skills_intents_sentences');
  }


  Future<bool> uploadRecordedSentence(String uid,
                                      String sentence,
                                      String recordedFilePath) async {

    File fileToUpload = new File(recordedFilePath);
    int wav_length = fileToUpload.lengthSync();
    Stream uploadStream = fileToUpload.openRead();

    try {

      MultipartRequest request = new MultipartRequest("POST",
        new Uri.https(
          _apiAuthorityUrl,
          _apiPath + 'upload_recorded_sentence/'
        ));

      request.fields["uid"] = uid;
      request.fields["sentence"] = sentence;
      request.files.add(
          new MultipartFile(
              'soundfile',
              uploadStream,
              wav_length,
              filename: basename(recordedFilePath),
              contentType: new MediaType('audio','wav')
              )
      );

      await request.send().then((response){
        if (response.statusCode!=200){
          print(response.statusCode);
          return false;
        }
        else {
          return true;
        }
      });

    } on Exception catch (e) {
      print(e);
      return false;
    }
    return true;
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