import 'dart:convert' as JSON;

import 'package:macsen/blocs/application_state_provider.dart';
import 'package:macsen/blocs/text_to_speech.dart';

class QASkill {

  static void execute(ApplicationBloc applicationBloc,
                      dynamic json){

    var jsonResult = JSON.jsonDecode(json);
    String ttsString;
    String url;

    for (int i=0; i < jsonResult["result"].length; i++){

      ttsString = jsonResult["result"][i]["title"].trim()
          + '\n\n'
          + jsonResult["result"][i]["description"].trim();

      ttsString = ttsString.trim();

      url = jsonResult["result"][i]["url"].trim();

      applicationBloc.textToSpeechBloc.queue.add(
          new TextToSpeechText(
              ttsString,
              localAdaptStringForTts(ttsString),
              url
          )
      );
    }

    applicationBloc.textToSpeechBloc.speakQueue.add(true);

  }


  static String localAdaptStringForTts(String inString) {
    String outString = inString;
    outString = outString.replaceAll("Celsius", "selsiws");
    outString = outString.replaceAll("Golwg 360", "Golwg tri chwech dimm");
    outString = outString.replaceAll("OpenWeather", "OopenWeddar");
    outString = outString.replaceAll("k", "c");
    return outString;
  }


}