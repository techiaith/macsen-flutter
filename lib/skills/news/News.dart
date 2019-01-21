import 'package:webfeed/webfeed.dart';

import 'package:macsen/utils/httpRss.dart';

import 'package:macsen/blocs/application_state_provider.dart';
import 'package:macsen/blocs/text_to_speech.dart';


class NewsSkill {

  static String _rssUrl = 'https://golwg360.cymru/ffrwd';

  static void execute(ApplicationBloc applicationBloc, dynamic json) {

    HttpRss.getRssChannelContent(_rssUrl).then((bodyString) {
      var channel = new RssFeed.parse(bodyString);
      applicationBloc.textToSpeechBloc.speak.add(
          new TextToSpeechText(
              "Dyma benawdau newyddion gwefan Golwg 360",
              "Dyma benawdau newyddion gwefan Golwg 3 6 diim"
          )
      );

      //
      for (int i = 0; i < 5; i++) {
        String newsItemText = channel.items[i].title
            + ". "
            + channel.items[i].description;

        applicationBloc.textToSpeechBloc.speak.add(
            new TextToSpeechText(newsItemText,
                                localAdaptStringForTts(newsItemText))
        );
      }
    });
  }

  static String localAdaptStringForTts(String inString) {
    return inString;
  }

}