import 'dart:async';

import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/models/ConversationModel.dart';
import 'package:macsen/apis/SpeechToText.dart';

import 'package:rxdart/subjects.dart';

class ConversationBloc implements BlocBase {

  SpeechToText sttApi;

  // in
  final StreamController<bool> _listeningController= StreamController<bool>();
  Sink<bool> get listen => _listeningController.sink;

  final StreamController<String> _newSpeechController = StreamController<String>();
  Sink<String> get processSpeech => _newSpeechController.sink;


  // out
  final BehaviorSubject<String> _transcription = BehaviorSubject<String>(seedValue: '');
  Stream<String> get transcription => _transcription.stream;

  final BehaviorSubject<ConversationModel> _conversationModel = BehaviorSubject<ConversationModel>(seedValue: new ConversationModel());
  Stream<ConversationModel> get conversation => _conversationModel.stream;


  void dispose() {
    _listeningController.close();
    _newSpeechController.close();
    _conversationModel.close();
    _transcription.close();
  }

  //
  ConversationBloc() {

    stt = new SpeechToText();

    _listeningController.stream.listen((isListening) {
      onConversationStateChange(isListening);
    });

    _newSpeechController.stream.listen((newSpeechFilepath){
      onNewSpeechFile(newSpeechFilepath);
    });

    _conversationModel.value.isActive = true;

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
    }

    _conversationModel.add(cvm);

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

       print("onNewSpeechFile then iswaiting set to " +  _conversationModel.value.isWaiting.toString());

       _transcription.add(transcription);

       if (transcription.contains("tywydd")){
         // .....
       }

     });
   }
}

