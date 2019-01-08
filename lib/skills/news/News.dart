import 'package:webfeed/webfeed.dart';
import 'package:macsen/blocs/ConversationBloc.dart';

import 'package:macsen/utils/httpRss.dart';

class NewsSkill {

  static String rss_url = 'https://golwg360.cymru/ffrwd';

  static void execute(ConversationBloc parent) {
    HttpRss.getRssChannelContent(rss_url).then((bodyString) {
      var channel = new RssFeed.parse(bodyString);



      parent.speak.add(
        new TextToSpeechUtterance(
            "Dyma benawdau newyddion gwefan Golwg 360",
            "Dyma benawdau newyddion gwefan Golwg 3 6 diim"
        ));          
          
      //
      for (int i = 0; i < 5; i++) {
        String newsItemText = channel.items[i].title
            + ". "
            + channel.items[i].description;
        
        parent.speak.add(new TextToSpeechUtterance(newsItemText, localAdaptStringForTts(newsItemText)));
      }
    });
  }

  static String localAdaptStringForTts(String inString) {
    return inString;
  }
}