import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

import 'package:macsen/blocs/ConversationBloc.dart';

class NewsSkill {

  static String rss_url = 'https://golwg360.cymru/ffrwd';

  ConversationBloc _parent;

  static void execute(ConversationBloc parent){
    var client = new http.Client();

    // RSS feed
    client.get(rss_url).then((response) {
      return response.body;
    }).then((bodyString) {
      var rss_channel = new RssFeed.parse(bodyString);
      parent.speak.add("Dyma benawdau newyddion gwefan Golwg 3 6 diim");
      for (int i=0; i<5;i++){

        String newsItemText = rss_channel.items[i].title + ". " +
            rss_channel.items[i].description;

        parent.speak.add(newsItemText);

      }
    });
  }

}