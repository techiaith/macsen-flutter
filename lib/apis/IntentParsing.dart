import 'dart:io';
import 'dart:async';
import 'dart:convert';


class IntentParsing {

  final String _apiAuthorityUrl = 'api.techiaith.org';

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


  Future<String> performSkill(String text,
                              double latitude,
                              double longitude) async {
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
        '/assistant/get_unrecorded_sentence',
        {
          "uid" : uid
        }
    );
  }

}