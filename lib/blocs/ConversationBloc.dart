
import 'dart:async';
import 'dart:collection';

import 'package:rxdart/subjects.dart';

import 'package:flutter/services.dart';

import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/apis/TextToSpeech.dart';
import 'package:macsen/apis/SpeechToText.dart';
import 'package:macsen/models/ConversationModel.dart';

// skills
import 'package:macsen/skills/weather/Weather.dart';
import 'package:macsen/skills/news/News.dart';


const MethodChannel _channel = const MethodChannel('cymru.techiaith.flutter.macsen/wavplayer');

class ConversationBloc implements BlocBase {

  SpeechToText sttApi;
  TextToSpeech ttsApi;
  Queue<String> speakQueue;

  // in
  final StreamController<bool> _listeningController= StreamController<bool>();
  Sink<bool> get listen => _listeningController.sink;

  final StreamController<String> _newSpeechController = StreamController<String>();
  Sink<String> get processSpeech => _newSpeechController.sink;

  final StreamController<String> _speakController = StreamController<String>();
  Sink<String> get speak => _speakController.sink;


  // out
  final BehaviorSubject<String> _transcription = BehaviorSubject<String>(seedValue: '');
  Stream<String> get transcription => _transcription.stream;

  final BehaviorSubject<ConversationModel> _conversationModel = BehaviorSubject<ConversationModel>(seedValue: new ConversationModel());
  Stream<ConversationModel> get conversation => _conversationModel.stream;


  void dispose() {
    _listeningController.close();
    _newSpeechController.close();
    _speakController.close();

    _transcription.close();
    _conversationModel.close();
  }


  ConversationBloc() {

    sttApi = new SpeechToText();
    ttsApi = new TextToSpeech();

    speakQueue = new Queue<String>();

    _listeningController.stream.listen((isListening) {
      onConversationStateChange(isListening);
    });

    _newSpeechController.stream.listen((newSpeechFilepath){
      onNewSpeechFile(newSpeechFilepath);
    });

    _speakController.stream.listen((text){
      onSpeakText(text);
    });

    _conversationModel.value.isActive = true;

    _channel.setMethodCallHandler(_nativeCallbackHandler);

  }


  Future<dynamic> _nativeCallbackHandler(MethodCall methodCall) async {
    if (methodCall.method == "audioPlayCompleted") {
      onCompletedSpeaking(methodCall.arguments);
    }
  }


  void onConversationStateChange(bool isListening) {

    //
    if (_conversationModel.value.isActive == false)
      return;

    //
    if (_conversationModel.value.isListening == isListening)
      return;

    //
    if (_conversationModel.value.isWaiting == true)
      return;

    //
    if (_conversationModel.value.isSpeaking == true)
      return;

    ConversationModel cvm = _conversationModel.value.clone();

    cvm.isListening = isListening;
    if (isListening == true) {
      cvm.isWaiting = false;
      cvm.isSpeaking = false;
      _transcription.add('');
    }

    _conversationModel.add(cvm);

  }


  void onSpeakText(String text) {
    speakQueue.add(text);
    if (_conversationModel.value.isSpeaking==false)
      _speakNextInQueue();
  }


  void onCompletedSpeaking(String audioFilePath){
    _conversationModel.value.isSpeaking=false;
    ttsApi.onCompletedSpeaking(audioFilePath);
    _speakNextInQueue();
  }


  void _speakNextInQueue(){
    if (speakQueue.length > 0){
      String text = speakQueue.removeFirst();
      _transcription.add(text);
      _conversationModel.value.isSpeaking=true;
      ttsApi.speak(text);
    }
  }


  void onNewSpeechFile(String newSpeechFilePath)
  {
     ConversationModel cvm = _conversationModel.value.clone();
     cvm.isWaiting=true;
     cvm.isListening=false;
     _conversationModel.add(cvm);

     sttApi.transcribe(newSpeechFilePath).then((transcription){

       ConversationModel cvm = _conversationModel.value.clone();
       cvm.isWaiting=false;
       cvm.isListening=true;
       _conversationModel.add(cvm);

       _transcription.add(transcription);

       if (transcription.contains("tywydd")){
         WeatherSkill.execute(this);
       } else if (transcription.contains("newyddion")){
         NewsSkill.execute(this);
       }

     });

  }

}
