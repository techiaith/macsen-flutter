import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;


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
    //String stt;

    try{
      stopRecordingResult = await platform.invokeMethod('stopRecording');
      String stt = await performMacsenSTT(stopRecordingResult);
      print (stt);

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

  Future<String> performMacsenSTT(String recordedFilePath) async {
    //
    platform.invokeMethod('playRecording', audioRecordingFilePath);

    // send to server ! :)
    var url = "http://macsen-stt.techiaith.cymru/dsserver/handleaudio/";

    File uploadFile = new File(recordedFilePath);
    int length = uploadFile.lengthSync();
    Stream uploadStream = uploadFile.openRead();

    try{
      HttpClient client = new HttpClient();
      HttpClientRequest request = await client.postUrl(Uri.parse(url));

      request.headers.contentLength=length;
      request.headers.contentType=ContentType.binary;

      await request.addStream(uploadStream);

      HttpClientResponse response = await request.close();

      if (response.statusCode==200) {
        StringBuffer sb = new StringBuffer();
        await for (String a in response.transform(utf8.decoder)){
          sb.write(a);
        }
        return sb.toString();
      }
    } on Exception catch (e) {
      print (e);
    }

    return null;
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
