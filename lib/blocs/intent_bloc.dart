import 'dart:async';
import 'dart:convert' as JSON;

import 'package:rxdart/subjects.dart';

import 'package:macsen/apis/IntentParsing.dart';
import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/application_state_provider.dart';

import 'package:macsen/skills/question_answer/QA.dart';
import 'package:macsen/skills/spotify/Spotify.dart';
import 'package:macsen/skills/alarm/Alarm.dart';


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

class IntentRecording {
  IntentRecording(this.uid, this.sentence, this.recordingFilePath);

  String uid;
  String sentence;
  String recordingFilePath;
}


class IntentParsingBloc implements BlocBase {

  ApplicationBloc _applicationBloc;
  IntentParsing _intentApi;

  double _latitude=0.0;
  double _longitude=0.0;

  String _currentPerformingIntent;

  // Sinks
  final StreamController<String> _determineIntentController = StreamController<String>();
  Sink<String> get determineIntent => _determineIntentController.sink;

  final StreamController<String> _getUnrecordedSentenceController = StreamController<String>();
  Sink<String> get getUnRecordedSentences => _getUnrecordedSentenceController.sink;

  final StreamController<IntentRecording> _intentRecordingController = StreamController<IntentRecording>();
  Sink<IntentRecording> get saveIntentRecording => _intentRecordingController.sink;

  final StreamController<bool> _stopPerformingIntentController = StreamController<bool>();
  Sink<bool> get stopPerformIntent => _stopPerformingIntentController.sink;


  // Streams
  final BehaviorSubject<String> _currentQuestionCommandBehavior = BehaviorSubject<String>();
  Stream<String> get questionOrCommand => _currentQuestionCommandBehavior.asBroadcastStream();


  final BehaviorSubject<Intent> _intentResultBehavior = BehaviorSubject<Intent>();
  Stream<Intent> get intentResult => _intentResultBehavior.asBroadcastStream();


  final BehaviorSubject<String> _unRecordedSentenceResultBehaviour = BehaviorSubject<String>();
  Stream<String> get unRecordedSentenceResult => _unRecordedSentenceResultBehaviour.asBroadcastStream();


  void dispose(){
    _determineIntentController.close();
    _getUnrecordedSentenceController.close();
    _intentRecordingController.close();
    _stopPerformingIntentController.close();
  }


  IntentParsingBloc(ApplicationBloc parentBloc) {

    _applicationBloc = parentBloc;
    _intentApi = new IntentParsing();

    _determineIntentController.stream.listen((text){
      _onDetermineIntent(text);
    });

    _getUnrecordedSentenceController.stream.listen((uid){
      _onGetUnrecordedSentences(uid);
    });

    _intentRecordingController.stream.listen((data){
      _onSaveIntentRecording(data);
    });

    _stopPerformingIntentController.stream.listen((stop){
      _stopPerformingCurrentIntent();
    });

    _applicationBloc.geolocationBloc.latitude.listen((latitude){
      _latitude=latitude;
    });

    _applicationBloc.geolocationBloc.longitude.listen((longitude){
      _longitude=longitude;
    });

  }


  void _onDetermineIntent(String text){
    if (text.length > 0) {
      _applicationBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationWaiting);
      _currentQuestionCommandBehavior.add(text);
      _intentApi.performSkill(text,_latitude,_longitude).then((intentJsonString) {
        if (intentJsonString.length > 0){
          _applicationBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationPerforming);
          _dispatchToSkill(intentJsonString);
        }
        else {
          _applicationBloc.stopPerformingCurrentIntent.add(true);
        }
      });
    }
  }


  void _onGetUnrecordedSentences(String uid){
    _applicationBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationWaiting);
    _intentApi.getUnrecordedSentence(uid).then((json){
      var jsonResult = JSON.jsonDecode(json);
      if (jsonResult["success"]==true){
        String result = jsonResult["result"][0];
        _unRecordedSentenceResultBehaviour.add(result);
      }
      _applicationBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationReady);
    });
  }


  void _onSaveIntentRecording(IntentRecording ir){
    _applicationBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationWaiting);
    _intentApi.uploadRecordedSentence(ir.uid, ir.sentence, ir.recordingFilePath).then((result){
      _applicationBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationReady);
    });

  }


  void _dispatchToSkill(String jsonString){
    var jsonResult = JSON.jsonDecode(jsonString);
    bool success = jsonResult["success"];
    if (success){
      _currentPerformingIntent=jsonResult["intent"];
      if (_currentPerformingIntent=="chwaraea.cerddoriaeth") {
        Spotify.execute(_applicationBloc, jsonString);
      } else if (_currentPerformingIntent=="gosoda.larwm"){
        Alarm.execute(_applicationBloc, jsonString);
      } else {
        QASkill.execute(_applicationBloc, jsonString);
      }
    }
  }


  void _stopPerformingCurrentIntent(){
    if (_currentPerformingIntent=="chwaraea.cerddoriaeth") {
      Spotify.stop(_applicationBloc);
    }
  }


}
