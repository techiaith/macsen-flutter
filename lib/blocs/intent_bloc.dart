import 'dart:async';
import 'dart:convert' as JSON;

import 'package:rxdart/subjects.dart';

import 'package:macsen/apis/IntentParsing.dart';
import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/application_state_provider.dart';

import 'package:macsen/skills/news/News.dart';
import 'package:macsen/skills/weather/Weather.dart';


//
// IntentBloc
//  Sinks:
//    - question or command as text
//  Stream:
//    - json description of intent
//
//  - request (as text)
//  - contacts API to get json intent parsing result
//  - emits IntentName and data
//

class Intent {
  String screenName;
  String description;
}


class IntentParsingBloc implements BlocBase {

  ApplicationBloc applicationBloc;
  IntentParsing intentApi;

  double _latitude=0.0;
  double _longitude=0.0;

  // Skills
  NewsSkill newsSkill;
  WeatherSkill weatherSkill;


  // Sinks
  final StreamController<String> _determineIntentController = StreamController<String>();
  Sink<String> get determineIntent => _determineIntentController.sink;

  // Streams
  final BehaviorSubject<String> _currentQuestionCommandBehavior = BehaviorSubject<String>();
  Stream<String> get questionOrCommand => _currentQuestionCommandBehavior.asBroadcastStream();


  final BehaviorSubject<Intent> _intentResultBehavior = BehaviorSubject<Intent>();
  Stream<Intent> get intentResult => _intentResultBehavior.asBroadcastStream();


  void dispose(){
    _determineIntentController.close();
  }


  IntentParsingBloc(ApplicationBloc parentBloc) {
    applicationBloc = parentBloc;
    intentApi = new IntentParsing();

    _determineIntentController.stream.listen((text){
      _onDetermineIntent(text);
    });

    applicationBloc.geolocationBloc.latitude.listen((latitude){
      _latitude=latitude;
    });

    applicationBloc.geolocationBloc.longitude.listen((longitude){
      _longitude=longitude;
    });
  }


  void _onDetermineIntent(String text){
    if (text.length > 0) {
      _currentQuestionCommandBehavior.add(text);
      intentApi.performSkill(text,
                             _latitude,
                             _longitude)
          .then((intentJsonString) {
            _dispatchToSkill(intentJsonString);
          });
    }
  }

  void _dispatchToSkill(String jsonString){

    // {"Location": "Bangor", "intent_type": "WeatherIntent", "target": null, "Keyword": "tywydd", "confidence": 1.0}

    var intentJson = JSON.jsonDecode(jsonString);
    print(intentJson["intent_type"]);

    if (intentJson["intent_type"]=="NewsIntent"){
      NewsSkill.execute(applicationBloc, jsonString);
    } else if (intentJson["intent_type"]=="WeatherIntent") {
      WeatherSkill.execute(applicationBloc, jsonString);
    }

  }

}
