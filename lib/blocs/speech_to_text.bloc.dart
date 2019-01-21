import 'dart:async';

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


  // Streams
  final BehaviorSubject<String> _sttResultBehaviour = BehaviorSubject<String>();
  Stream<String> get sttResult => _sttResultBehaviour.asBroadcastStream();


  void dispose(){
    _recogniseWavFileController.close();
  }


  SpeechToTextBloc(ApplicationBloc parentBloc){
    _applicationBloc = parentBloc;
    _sttApi = new SpeechToText();

    _recogniseWavFileController.stream.listen((wavFilePath){
      if (wavFilePath.length>0)
        _onRecognizeWavFile(wavFilePath);
    });

  }


  void _onRecognizeWavFile(String wavFilePath){
    _sttApi.transcribe(wavFilePath).then((transcription){
      _sttResultBehaviour.add(transcription);
    });
  }


}