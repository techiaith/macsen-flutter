import 'dart:async';

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


  // Sinks
  final StreamController<TextToSpeechText> _speakTextController = StreamController<TextToSpeechText>();
  Sink<TextToSpeechText> get speak => _speakTextController.sink;


  // Streams
  final BehaviorSubject<SoundFile> _ttsResultBehaviour = BehaviorSubject<SoundFile>();
  Stream<SoundFile> get ttsResult => _ttsResultBehaviour.asBroadcastStream();


  void dispose(){
    _speakTextController.close();
  }


  TextToSpeechBloc(ApplicationBloc parentBloc){
    _applicationBloc = parentBloc;
    _ttsApi = new TextToSpeech();

    _speakTextController.stream.listen((ttsText){
      _onCreateTTSUtterance(ttsText);
    });
  }


  void _onCreateTTSUtterance(TextToSpeechText ttsText){
    _ttsApi.speak(ttsText.locallyAdaptedText).then((wavfile){

      SoundFile soundFile=new SoundFile(wavfile, ttsText.originalText);
      _ttsResultBehaviour.add(soundFile);

    });
  }


}