import 'dart:convert' as JSON;

import 'package:macsen/blocs/application_state_provider.dart';
import 'package:macsen/blocs/text_to_speech.dart';

class QASkill {

  static void execute(ApplicationBloc applicationBloc,
                      dynamic json){

    var jsonResult = JSON.jsonDecode(json);

    for (int i = 0; i < jsonResult["result"].length;i++){
      String ttsString = jsonResult["result"][i]["title"]
        + ". "
        + jsonResult["result"][i]["description"];

      applicationBloc.textToSpeechBloc.speak.add(
        new TextToSpeechText(ttsString,
          localAdaptStringForTts(ttsString))
      );
    }
  }

  static String localAdaptStringForTts(String inString) {
    return inString;
  }

}