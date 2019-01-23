import 'dart:async';
import 'dart:collection';

import 'package:rxdart/subjects.dart';

import 'package:macsen/apis/TextToSpeech.dart';
import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/application_state_provider.dart';
import 'package:macsen/blocs/loudspeaker_bloc.dart';

//
// TextToSpeechBloc
//  Sinks:
//    - texts that need uttering
//  Stream:
//    - file url of wav file with tts result
//
//  - receives texts that need to be uttered
//  - uses MaryTTS cloud API to convert to wav
//  - file url of wav to play.
//
//


class TextToSpeechText {

  String originalText;
  String locallyAdaptedText;

  TextToSpeechText(String originalText,
                   String locallyAdaptedText) {
    this.originalText=originalText;
    if (locallyAdaptedText=='')
      this.locallyAdaptedText=this.originalText;
    else
      this.locallyAdaptedText=locallyAdaptedText;
  }
}



class TextToSpeechBloc implements BlocBase {

  ApplicationBloc _applicationBloc;
  TextToSpeech _ttsApi;

  bool _isWaitingForTts = false;
  Queue<TextToSpeechText> _ttsQueue;

  // Sinks
  final StreamController<TextToSpeechText> _speakTextController = StreamController<TextToSpeechText>();
  Sink<TextToSpeechText> get speak => _speakTextController.sink;

  final StreamController<bool> _resetQueueController = StreamController<bool>();
  Sink<bool> get reset => _resetQueueController.sink;


  // Streams
  final BehaviorSubject<SoundFile> _ttsResultBehaviour = BehaviorSubject<SoundFile>();
  Stream<SoundFile> get ttsResult => _ttsResultBehaviour.asBroadcastStream();


  void dispose(){
    _speakTextController.close();
    _resetQueueController.close();
  }


  TextToSpeechBloc(ApplicationBloc parentBloc){
    _applicationBloc = parentBloc;

    _ttsApi = new TextToSpeech();
    _ttsQueue = new Queue<TextToSpeechText>();


    _speakTextController.stream.listen((ttsText){
      _onCreateTTSUtterance(ttsText);
    });

    _resetQueueController.stream.listen((reset){
      _onResetQueue();
    });
  }


  void _onCreateTTSUtterance(TextToSpeechText ttsText){
    _ttsQueue.add(ttsText);
    _processNextInTtsQueue();
  }

  Future<void> _processNextInTtsQueue() async {
    if (_ttsQueue.length > 0){
      if (_isWaitingForTts==false){
        _isWaitingForTts=true;
        TextToSpeechText nextTextToSpeechText = _ttsQueue.removeFirst();
        await _ttsApi.speak(nextTextToSpeechText.locallyAdaptedText).then((wavfile){
          _isWaitingForTts=false;
          SoundFile soundFile = new SoundFile(wavfile, nextTextToSpeechText.originalText);
          _ttsResultBehaviour.add(soundFile);
          _processNextInTtsQueue();
        });
      }
    }
  }

  void _onResetQueue(){
    _ttsQueue.clear();
    _isWaitingForTts=false;
  }

}