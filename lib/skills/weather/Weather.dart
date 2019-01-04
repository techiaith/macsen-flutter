
import 'package:webfeed/webfeed.dart';
import 'package:macsen/blocs/ConversationBloc.dart';
import 'package:macsen/utils/httpRss.dart';

class WeatherSkill {

  static String weather_rss_url = 'https://weather-broker-cdn.api.bbci.co.uk/cy/observation/rss/8299867';

  static void execute(ConversationBloc parent) {

    HttpRss.getRssChannelContent(weather_rss_url).then((bodyString) {
      var channel = new RssFeed.parse(bodyString);
      parent.speak.add(channel.description);
      parent.speak.add(channel.items[0].title);
      parent.speak.add(channel.items[0].description);
    });

  }

}