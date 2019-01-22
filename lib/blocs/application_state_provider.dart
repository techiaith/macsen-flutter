import 'package:flutter/material.dart';

import 'package:macsen/blocs/BlocProvider.dart';

import 'package:macsen/blocs/microphone_bloc.dart';
import 'package:macsen/blocs/loudspeaker_bloc.dart';
import 'package:macsen/blocs/speech_to_text.bloc.dart';
import 'package:macsen/blocs/text_to_speech.dart';
import 'package:macsen/blocs/intent_bloc.dart';


class ApplicationStateProvider extends InheritedWidget {

  final ApplicationBloc bloc = ApplicationBloc();

  ApplicationStateProvider({Key key, @required Widget child,})
    : super(key: key, child: child,);

  static ApplicationBloc of(BuildContext context) => (context.inheritFromWidgetOfExactType(ApplicationStateProvider) as ApplicationStateProvider).bloc;

  @override
  bool updateShouldNotify(ApplicationStateProvider old){
    return bloc != old.bloc;
  }

}


class ApplicationBloc extends BlocBase {

  MicrophoneBloc microphoneBloc;
  LoudSpeakerBloc loudspeakerBloc;

  SpeechToTextBloc speechToTextBloc;
  TextToSpeechBloc textToSpeechBloc;
  IntentParsingBloc intentParsingBloc;


  ApplicationBloc(){

    loudspeakerBloc = LoudSpeakerBloc(this);
    microphoneBloc = MicrophoneBloc(this);

    speechToTextBloc = SpeechToTextBloc(this);
    textToSpeechBloc = TextToSpeechBloc(this);
    intentParsingBloc = IntentParsingBloc(this);

    microphoneBloc.recordingFilePath.listen((filepath){
      speechToTextBloc.recogniseFile.add(filepath);
    });

    speechToTextBloc.sttResult.listen((recognizedText){
      intentParsingBloc.determineIntent.add(recognizedText);
    });

    textToSpeechBloc.ttsResult.listen((utteranceWavfile){
      loudspeakerBloc.play.add(utteranceWavfile);
    });

  }


  void dispose(){
  }



  // Macsen Model/Application state
  //

  //
  // Services / Repositories
  //


  // BLoCs
  //-------

  // MicrophoneBloc
  // Sinks:
  //    - start recording
  //    - stop recording
  //
  // Streams:
  //    - microphone accessible
  //    - mirophone recording
  //
  // - check microphone permissions (allow of not)
  // - contains microphone state
  // - start recording (play hi beep)
  // - stop recording (play low beep)
  // - emits file url of captured wav
  //


  //
  // LoudspeakerBloc
  //  Sinks:
  //    - file url of stored wav file to play
  //    - cancel playing
  //    - reset queue of wavs
  //
  //  Streams:
  //    - loudspeaker is quiet
  //    - loudspeaker is active
  //
  //  - in, wav files to play.
  //  - implements queue to coordinate playing one at a time
  //  - deletes wav on device after playing
  //  - (N.B. no means (yet) for use in streaming)
  //


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


  //
  // SkillsDispatcherBloc
  //  Sinks:
  //    - json description of recognized intent
  //  Stream:
  //    - name of internally recognized intent  (i.e. named pages)
  //
  // - listens to recognized intents and dispatches to desired skill
  // - dispatches to the intent description to the relevent skill.
  //
    // NewsBloc
    // WeatherBloc
    // ClockBloc
    // TimerBloc
    // AlarmBloc


}