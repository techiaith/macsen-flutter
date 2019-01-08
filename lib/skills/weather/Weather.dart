
import 'package:webfeed/webfeed.dart';
import 'package:macsen/blocs/ConversationBloc.dart';
import 'package:macsen/utils/httpRss.dart';

class WeatherSkill {

  static String weather_rss_url = 'https://weather-broker-cdn.api.bbci.co.uk/cy/observation/rss/8299867';

  /*
  <?xml version="1.0" encoding="UTF-8"?>
  <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" version="2.0">
  <channel>
  <title>BBC Tywydd - Arsylwadau ar gyfer Garndolbenmaen, GB</title>
  <link>https://www.bbc.co.uk/weather/8299867</link>
  <description>Arsylwadau diweddaraf ar gyfer Garndolbenmaen gan BBC Tywydd, yn cynnwys tywydd, tymheredd a gwybodaeth gwynt</description>
  <language>cy</language>
  <copyright>Hawlfraint: (C)  Y Gorfforaeth Ddarlledu Brydeinig (BBC) Ewch i [link] am fwy o fanylion</copyright>
  <pubDate>Mon, 07 Jan 2019 14:00:00 GMT</pubDate>
  <dc:date>2019-01-07T14:00:00Z</dc:date>
  <dc:language>cy</dc:language>
  <dc:rights>Hawlfraint: (C)  Y Gorfforaeth Ddarlledu Brydeinig (BBC) Ewch i [link] am fwy o fanylion</dc:rights>
  <atom:link href="https://weather-service-thunder-broker.api.bbci.co.uk/cy/observation/rss/8299867" type="application/rss+xml" rel="self" />
  <item>
    <title>dydd Llun - 14:00 GMT: Ddim ar gael, 10°C (50°F)</title>
    <link>https://www.bbc.co.uk/weather/8299867</link>
    <description>Tymheredd: 10°C (50°F), Cyfeiriad Gwynt: De-Orllewinol, Cyflymder Gwynt: 11mph, Lleithder: 93%, Gwasgedd: 1029mb, Cyson, Gwelededd: --</description>
    <pubDate>Mon, 07 Jan 2019 14:00:00 GMT</pubDate>
    <guid isPermaLink="false">https://www.bbc.co.uk/weather/8299867-2019-01-07T14:00:00.000Z</guid>
    <dc:date>2019-01-07T14:00:00Z</dc:date>
    <georss:point>52.9737 -4.2402</georss:point>
  </item>
  </channel>
  </rss>
  */

  static void execute(ConversationBloc parent) {

    HttpRss.getRssChannelContent(weather_rss_url).then((bodyString) {
      var channel = new RssFeed.parse(bodyString);
      parent.speak.add(new TextToSpeechUtterance(channel.description, localAdaptStringForTts(channel.description)));
      parent.speak.add(new TextToSpeechUtterance(channel.items[0].title, localAdaptStringForTts(channel.items[0].title)));
      parent.speak.add(new TextToSpeechUtterance(channel.items[0].description, localAdaptStringForTts(channel.items[0].description)));
    });

  }

  static String localAdaptStringForTts(String inString){
    String outString= inString;
    outString = outString.replaceAll("°C", " gradd selsiws");
    outString = outString.replaceAll("°F", " gradd ffarenheit");
    outString = outString.replaceAll("mph", " milltir yr awr");
    outString = outString.replaceAll("%", " y cant");
    outString = outString.replaceAll("mb, Cyson", " milibar, Cyson");

    outString = outString.replaceAll("BBC", "Bii Bii Eec");

    return outString;
  }

}