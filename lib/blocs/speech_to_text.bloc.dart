import 'dart:async';
import 'dart:convert' as JSON;

import 'package:rxdart/subjects.dart';

import 'package:macsen/apis/SpeechToText.dart';
import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/application_state_provider.dart';

//
// SpeechToTextBloc
//  Sinks:
//    - file url of wav needing converting to text
//  Streams:
//    - text result
//
// - receives wav file url
// - uses DeepSpeech cloud API to convert to text
// - deletes the original wav file.
//

class SpeechToTextBloc implements BlocBase {

  ApplicationBloc _applicationBloc;
  SpeechToText _sttApi;


  // Sinks
  final StreamController<String> _recogniseWavFileController = StreamController<String>();
  Sink<String> get recogniseFile => _recogniseWavFileController.sink;

  final StreamController<String> _transcribeWavFileController = StreamController<String>();
  Sink<String> get transcribeFile => _transcribeWavFileController.sink;

  final StreamController<bool> _serverInformationController = StreamController<bool>();
  Sink<bool> get getServerInformation => _serverInformationController.sink;


  // Streams
  final BehaviorSubject<String> _sttResultBehaviour = BehaviorSubject<String>();
  Stream<String> get sttResult => _sttResultBehaviour.asBroadcastStream();

  final BehaviorSubject<String> _transciptionResultBehaviour = BehaviorSubject<String>();
  Stream<String> get transcribeResult => _transciptionResultBehaviour.asBroadcastStream();

  final BehaviorSubject<String> _modelNameBehaviour = BehaviorSubject<String>();
  Stream<String> get modelName => _modelNameBehaviour.asBroadcastStream();

  final BehaviorSubject<String> _modelVersionBehaviour = BehaviorSubject<String>();
  Stream<String> get modelVersion => _modelVersionBehaviour.asBroadcastStream();


  void dispose(){
    _recogniseWavFileController.close();
    _serverInformationController.close();
    _transcribeWavFileController.close();
  }


  SpeechToTextBloc(ApplicationBloc parentBloc){
    _applicationBloc = parentBloc;
    _sttApi = new SpeechToText();

    _recogniseWavFileController.stream.listen((wavFilePath){
      if (wavFilePath.length>0)
        _onRecognizeWavFile(wavFilePath);
    });

    _transcribeWavFileController.stream.listen((wavFilePath){
      if (wavFilePath.length>0)
        _onTranscribeWavFile(wavFilePath);
    });

    _serverInformationController.stream.listen((add){
      _onGetServerInformation();
    });

  }


  void _onRecognizeWavFile(String wavFilePath){
    _applicationBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationWaiting);
    _sttApi.recognize(wavFilePath).then((jsonStringResult) {
      if (jsonStringResult.length == 0){
        _applicationBloc.raiseApplicationException.add("Methwyd adnabod unrhyw gwestiwn neu orchymyn.");
        return;
      }
      var jsonResult = JSON.jsonDecode(jsonStringResult);
      bool success = jsonResult["success"];
      if (success) {
        _applicationBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationReady);
        _sttResultBehaviour.add(jsonResult["text"]);
      }
    });
  }

  void _onTranscribeWavFile(String wavFilePath){
    _applicationBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationWaiting);
    _sttApi.transcribe(wavFilePath).then((jsonStringResult){
      if (jsonStringResult.length ==0){
        _applicationBloc.raiseApplicationException.add("Methwyd trawsgrifio unrhyw destun o'r lleferydd");
        return;
      }
      var jsonResult = JSON.jsonDecode(jsonStringResult);
      bool success = jsonResult["success"];
      if (success)
      {
        _applicationBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationNotReady);
        StringBuffer sb = new StringBuffer();
        for (int t=0; t<jsonResult["transcripts"].length; t++){
          sb.write(jsonResult["transcripts"][t]["text"]);
        }
        _transciptionResultBehaviour.add(sb.toString());
      }
    });
  }

  void _onGetServerInformation(){
    _sttApi.getVersions().then((jsonStringResult) {

      if (jsonStringResult.length > 0) {
        var jsonResult = JSON.jsonDecode(jsonStringResult);
        _modelNameBehaviour.add(jsonResult['model_name']);
        _modelVersionBehaviour.add(jsonResult['model_version']);
      }

    });

  }

}