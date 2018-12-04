import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RecordButtonWidget extends StatefulWidget{
    RecordButtonWidget({Key key,}) : super(key: key);

    @override
    _RecordButtonState createState() => new _RecordButtonState();
}


class _RecordButtonState extends State<RecordButtonWidget> {

  static const platform = const MethodChannel('cymru.techiaith.flutter.macsen');

  bool isAllowed = false;
  bool isListening = false;
  String audioRecordingFilePath;


  _RecordButtonState(){
    _checkMicrophonePermissions();
    platform.setMethodCallHandler(nativeCallbackHandler);
  }


  Future<dynamic> nativeCallbackHandler(MethodCall methodCall) async {

    if (methodCall.method == "audioRecordingPermissionGranted") {
      setState(() {
        isAllowed = true;
      });
    }

  }


  Future<void> _checkMicrophonePermissions() async {
    bool checkMicrophonePermissionsResult;
    try {
      checkMicrophonePermissionsResult = await platform.invokeMethod('checkMicrophonePermissions');
    }
    on PlatformException catch (e) {
      checkMicrophonePermissionsResult=false;
    }

    setState(() {
      isAllowed = checkMicrophonePermissionsResult;
    });
  }


  Future<void> _startRecording() async{
    String startRecordingResult;
    try{
        startRecordingResult = await platform.invokeMethod('startRecording', 'tmpwavfile');
    }
    on PlatformException catch (e) {
        startRecordingResult = "FAIL";
    }

    setState((){
      startRecordingResult=="OK" ? isListening=true : isListening=false;
    });

  }


  Future<void> _stopRecording() async{
    String stopRecordingResult;
    try{
      stopRecordingResult = await platform.invokeMethod('stopRecording');
    }
    on PlatformException catch (e) {
      stopRecordingResult = "FAIL";
    }

    setState((){
      isListening=false;
      if (stopRecordingResult!="FAIL") {
        audioRecordingFilePath = stopRecordingResult;
      } else {
        audioRecordingFilePath = null;
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    if (isAllowed == true) {
      return !isListening ?
      _buildIconButton(
          Icons.mic,
          _startRecording,
          Colors.teal
      )
          :
      _buildIconButton(
          Icons.mic_none,
          _stopRecording,
          Colors.redAccent
      );
    } else {
      return _buildIconButton(Icons.mic_off, null, Colors.red);
    }
  }


  Widget _buildIconButton(IconData icon,
                          VoidCallback onPress,
                          Color color)
  {
    return new Padding(
        padding: new EdgeInsets.all(12.0),
        child: new FloatingActionButton(
            child: new Icon(icon, size: 32.0),
            backgroundColor: color,
            onPressed: onPress),
    );
  }


}
