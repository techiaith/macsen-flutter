import 'dart:io';
import 'dart:async';
import 'dart:convert';


class IntentParsing {

  Future<String> determineIntent(String text) async {
    try {
      HttpClient httpClient = new HttpClient();
      var request = await httpClient.getUrl(new Uri.https(
          'api.techiaith.org', '/adapt/determine_intent',
          {
            "text": text,
          }));

      var response = await request.close();

      if (response.statusCode == 200) {
        StringBuffer sb = new StringBuffer();
        await for (String a in response.transform(utf8.decoder)) {
          sb.write(a);
        }
        return sb.toString();
      }
    } on Exception catch (e) {
      print(e);
    }

    return '';

  }

}