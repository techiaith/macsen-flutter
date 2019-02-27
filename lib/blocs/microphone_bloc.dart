import 'dart:async';

import 'package:flutter/services.dart';
import 'package:rxdart/subjects.dart';
import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/application_state_provider.dart';

import 'package:macsen/blocs/loudspeaker_bloc.dart';

// MicrophoneBloc
//
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

const MethodChannel _native_mic_record_channel = const MethodChannel('cymru.techiaith.flutter.macsen/wavrecorder');

enum MicrophoneStatus{ NotAllowed, Available, Recording}

class MicrophoneBloc implements BlocBase {

  ApplicationBloc applicationBloc;

  MicrophoneStatus _micStatus = MicrophoneStatus.NotAllowed;
  String nativeRecordingResult;


  // Sinks
  final StreamController<bool> _recordController = StreamController<bool>();
  Sink<bool> get record => _recordController.sink;


  // Streams
  final BehaviorSubject<MicrophoneStatus> _microphoneStatusBehaviour = BehaviorSubject<MicrophoneStatus>(seedValue: MicrophoneStatus.NotAllowed);
  Stream<MicrophoneStatus> get microphoneStatus => _microphoneStatusBehaviour.asBroadcastStream();


  final BehaviorSubject<String> _recordingBehaviour = BehaviorSubject<String>(seedValue: '');
  Stream<String> get recordingFilePath => _recordingBehaviour.asBroadcastStream();


  //
  void dispose(){
    _recordController.close();
  }


  MicrophoneBloc(ApplicationBloc parentBloc) {

    applicationBloc = parentBloc;

    //
    _recordController.stream.listen((toggle){
      _onRecordStateChange(toggle);
    });

    applicationBloc.loudspeakerBloc.beepCompleted.listen((completedBeep){
      _onBeepCompleted(completedBeep);
    });

    _native_mic_record_channel.setMethodCallHandler(_nativeCallbackHandler);

    _checkMicrophonePermissions();
  }


  Future<dynamic> _nativeCallbackHandler(MethodCall methodCall) async {
    if (methodCall.method == "audioRecordingPermissionGranted") {
      if (methodCall.arguments=="OK"){
        _onMicrophonePermissionsChange(true);
      }
    }
  }


  Future<void> _checkMicrophonePermissions() async {
    bool checkMicrophonePermissionsResult;
    try {
      checkMicrophonePermissionsResult = await _native_mic_record_channel.invokeMethod('checkMicrophonePermissions');
    }
    on PlatformException catch (e) {
      print(e.message);
      checkMicrophonePermissionsResult=false;
    }
    _onMicrophonePermissionsChange(checkMicrophonePermissionsResult);
  }


  Future<void> _onMicrophonePermissionsChange(bool permissionGranted) async {
    if (permissionGranted){
      _micStatus=MicrophoneStatus.Available;
      _microphoneStatusBehaviour.add(MicrophoneStatus.Available);
    }
  }


  void _onBeepCompleted(BeepEnum beep){
    // we only wait for a hi beep
    if (beep==BeepEnum.HiBeep)
      _startRecording();
    else if (beep==BeepEnum.LoBeep)
      _recordingBehaviour.add(nativeRecordingResult);
  }


  Future<void> _onRecordStateChange(bool playBeeps) async {
    if (_micStatus==MicrophoneStatus.Available) {
      if (playBeeps == true) {
        applicationBloc.loudspeakerBloc.beep.add(BeepEnum.HiBeep);
      } else {
          _startRecording();
      }
    } else if (_micStatus==MicrophoneStatus.Recording) {
      _stopRecording();
      if (playBeeps == true)
        applicationBloc.loudspeakerBloc.beep.add(BeepEnum.LoBeep);
      else
        _recordingBehaviour.add(nativeRecordingResult);
    }
  }


  Future<void> _startRecording() async {
    String nativeInvokeResult;
    try {
      print ("Start Recording...");
      nativeInvokeResult = await _native_mic_record_channel.invokeMethod('startRecording', 'tmpwavfile');
      if (nativeInvokeResult == "OK"){
        _micStatus=MicrophoneStatus.Recording;
        _microphoneStatusBehaviour.add(MicrophoneStatus.Recording);
      }
    } on PlatformException catch (e) {
      print(e.message);
      _microphoneStatusBehaviour.add(MicrophoneStatus.Available);
      _recordingBehaviour.add('');
    }
  }


  Future<void> _stopRecording() async {
    if (_micStatus==MicrophoneStatus.Recording){
      try{
        print ("Stop Recording...");
        nativeRecordingResult = await _native_mic_record_channel.invokeMethod('stopRecording');
      } on PlatformException catch (e) {
        print (e.message);
        _recordingBehaviour.add('');
      }
      _micStatus=MicrophoneStatus.Available;
      _microphoneStatusBehaviour.add(MicrophoneStatus.Available);
    }
  }


}