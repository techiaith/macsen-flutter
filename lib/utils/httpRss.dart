import 'dart:io';
import 'dart:convert';
import 'dart:async';

class HttpRss {

  static Future<String> getRssChannelContent(String url) async {
    String result = '';
    try {
      HttpClient client = new HttpClient();
      HttpClientRequest request = await client.getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      if (response.statusCode==200) {
        StringBuffer sb = new StringBuffer();
        await for (String a in response.transform(utf8.decoder)){
          sb.write(a);
        }
        result = sb.toString();
      }
    } on Exception catch (e) {
      result = '';
      print (e);
    }
    return result;
  }
}
