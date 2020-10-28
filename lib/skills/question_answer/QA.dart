import 'dart:convert' as JSON;

import 'package:macsen/blocs/application_state_provider.dart';
import 'package:macsen/blocs/text_to_speech.dart';

var autoIntents = ["dangosa.raglen"];

class QASkill {
  static void execute(ApplicationBloc applicationBloc, dynamic json) {
    var jsonResult = JSON.jsonDecode(json);
    String ttsString;
    String url;

    for (int i = 0; i < jsonResult["result"].length; i++) {
      ttsString = jsonResult["result"][i]["title"].trim();
      bool autoLink = false;
      String spokenText = ttsString;
      if (_isAutoLink(jsonResult["intent"])) {
        autoLink = true;
        spokenText = "Am ddangos rhaglen " + spokenText + " ar wefan Clic S4C";
      } else {
        spokenText += '\n\n' + jsonResult["result"][i]["description"].trim();
        ttsString += '\n\n' + jsonResult["result"][i]["description"].trim();
      }

      url = jsonResult["result"][i]["url"].trim();

      applicationBloc.textToSpeechBloc.queue.add(new TextToSpeechText(
          ttsString, localAdaptStringForTts(spokenText), url, autoLink));
    }

    applicationBloc.textToSpeechBloc.speakQueue.add(true);
  }

  static String localAdaptStringForTts(String inString) {
    String outString = inString;
    outString = outString.replaceAll("Celsius", "selsiws");
    outString = outString.replaceAll("rhaglen", "rhagglen");
    outString = outString.replaceAll("Clic", "Clicc");
    outString = outString.replaceAll("S4C", "es pedwar ecc");
    outString = outString.replaceAll("Golwg 360", "Golwg tri chwech dimm");
    outString = outString.replaceAll("OpenWeather", "OopenWeddar");
    outString = outString.replaceAll("k", "c");
    outString = outString.replaceAll("", "");
    return outString;
  }
}

bool _isAutoLink(String intent) {
  for (int i = 0; i < autoIntents.length; i++) {
    if (intent == autoIntents[i]) {
      return true;
    }
  }
  return false;
}
