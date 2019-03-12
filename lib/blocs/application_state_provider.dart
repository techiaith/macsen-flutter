import 'dart:async';
import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rxdart/subjects.dart';
import 'package:macsen/blocs/BlocProvider.dart';

import 'package:macsen/blocs/microphone_bloc.dart';
import 'package:macsen/blocs/loudspeaker_bloc.dart';
import 'package:macsen/blocs/speech_to_text.bloc.dart';
import 'package:macsen/blocs/geolocation_bloc.dart';
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

enum RecordingType { RequestRecording, SentenceRecording }
enum ApplicationWaitState { ApplicationWaiting, ApplicationReady, ApplicationPerforming }

class ApplicationBloc extends BlocBase {

  MicrophoneBloc microphoneBloc;
  LoudSpeakerBloc loudspeakerBloc;
  GeolocationBloc geolocationBloc;

  SpeechToTextBloc speechToTextBloc;
  TextToSpeechBloc textToSpeechBloc;
  IntentParsingBloc intentParsingBloc;

  RecordingType _recordingType = RecordingType.RequestRecording;
  ApplicationWaitState _applicationWaitState = ApplicationWaitState.ApplicationReady;

  String _recordedSentence;


  //
  final StreamController<String> _requestController = StreamController<String>();
  Sink<String> get request => _requestController.sink;

  final StreamController<RecordingType> _recordingTypeController = StreamController<RecordingType>();
  Sink<RecordingType> get recordingType => _recordingTypeController.sink;

  final StreamController<ApplicationWaitState> _applicationWaitStateController = StreamController<ApplicationWaitState>();
  Sink<ApplicationWaitState> get changeApplicationWaitState => _applicationWaitStateController.sink;

  final StreamController<bool> _stopPerformingCurrentIntentController = StreamController<bool>();
  Sink<bool> get stopPerformingCurrentIntent => _stopPerformingCurrentIntentController.sink;


  // Streams
  final BehaviorSubject<String> _currentRequestBehavior = BehaviorSubject<String>();
  Stream<String> get currentRequestText => _currentRequestBehavior.asBroadcastStream();

  final BehaviorSubject<String> _currentResponseBehavior = BehaviorSubject<String>();
  Stream<String> get currentResponseText => _currentResponseBehavior.asBroadcastStream();

  final BehaviorSubject<ApplicationWaitState> _applicationWaitStateBehaviour = BehaviorSubject<ApplicationWaitState>();
  Stream<ApplicationWaitState> get onApplicationWaitStateChange => _applicationWaitStateBehaviour.asBroadcastStream();



  void dispose(){
    _requestController.close();
    _recordingTypeController.close();
    _applicationWaitStateController.close();
    _stopPerformingCurrentIntentController.close();
  }


  //
  ApplicationBloc(){

    loudspeakerBloc = LoudSpeakerBloc(this);
    microphoneBloc = MicrophoneBloc(this);
    geolocationBloc = GeolocationBloc(this);

    speechToTextBloc = SpeechToTextBloc(this);
    textToSpeechBloc = TextToSpeechBloc(this);
    intentParsingBloc = IntentParsingBloc(this);

    _recordingTypeController.stream.listen((recordingType){
      _recordingType=recordingType;
      print (_recordingType.toString());
    });

    _applicationWaitStateController.stream.listen((waitState){
      _applicationWaitState=waitState;
      _applicationWaitStateBehaviour.add(_applicationWaitState);
    });


    _stopPerformingCurrentIntentController.stream.listen((stop){
      _currentRequestBehavior.add('');
      _currentResponseBehavior.add('');

      loudspeakerBloc.stop.add(true);

      textToSpeechBloc.reset.add(true);
      loudspeakerBloc.reset.add(true);

      intentParsingBloc.stopPerformIntent.add(true);

      _applicationWaitStateBehaviour.add(ApplicationWaitState.ApplicationReady);

    });


    microphoneBloc.recordingFilePath.listen((filepath){
      if (filepath.length == 0)
        return;

      if (_recordingType==RecordingType.RequestRecording) {
        speechToTextBloc.recogniseFile.add(filepath);
      }
      else {
        _applicationWaitStateBehaviour.add(ApplicationWaitState.ApplicationWaiting);
        getUniqueUID().then((uid){
          IntentRecording intentRecording = IntentRecording(uid,_recordedSentence,filepath);
          intentParsingBloc.saveIntentRecording.add(intentRecording);
          intentParsingBloc.getUnRecordedSentences.add(uid);
        });
      }
    });


    speechToTextBloc.sttResult.listen((recognizedText){
      intentParsingBloc.determineIntent.add(recognizedText);
    });


    // from TextualInputScreen
    _requestController.stream.listen((text){
      intentParsingBloc.determineIntent.add(text);
    });


    textToSpeechBloc.ttsResult.listen((utteranceWavfile){
      loudspeakerBloc.play.add(utteranceWavfile);
    });


    microphoneBloc.microphoneStatus.listen((micStatus){
      if (micStatus==MicrophoneStatus.Recording){
        _currentRequestBehavior.add('');
        _currentResponseBehavior.add('');
        textToSpeechBloc.reset.add(true);
        loudspeakerBloc.reset.add(true);
      }
    });


    loudspeakerBloc.currentSoundText.listen((text){
      _currentResponseBehavior.add(text);
    });


    intentParsingBloc.questionOrCommand.listen((text){
      _currentRequestBehavior.add(text);
    });


    //
    intentParsingBloc.unRecordedSentenceResult.listen((sentence){
      _recordedSentence=sentence;
    });

    getUniqueUID();

  }


  //
  // This method assigns a unique Id to the application installation.
  // The UID does not identify the identity of the device and/or user
  // The UID is used in other parts whether any submissions to cloud
  // based services may need to be differentiated from submissions from
  // other devices.
  //
  Future<String> getUniqueUID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString("UID") ?? new Uuid().v1();
    prefs.setString("UID", uid);
    return uid;
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