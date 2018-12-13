import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

import 'package:macsen/blocs/ConversationBloc.dart';

class WeatherSkill {

  static String weather_rss_url = 'https://weather-broker-cdn.api.bbci.co.uk/cy/observation/rss/8299867';

  static void execute(ConversationBloc parent){
    var client = new http.Client();

    // RSS feed
    client.get(weather_rss_url).then((response) {
      return response.body;
    }).then((bodyString) {
      var channel = new RssFeed.parse(bodyString);
      parent.speak.add(channel.description);
      parent.speak.add(channel.items[0].title);
      parent.speak.add(channel.items[0].description);
    });
  }
}