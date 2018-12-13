import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/ConversationBloc.dart';

import 'package:macsen/models/ConversationModel.dart';


class RecordButtonWidget extends  StatefulWidget {
  RecordButtonWidget({Key key,}) : super(key: key);

  @override
  RecordButtonState createState() => new RecordButtonState();
}

const MethodChannel platform = const MethodChannel('cymru.techiaith.flutter.macsen/wavrecorder');

class RecordButtonState extends State<RecordButtonWidget> {

  bool isAllowed = false;
  bool isListening = false;
  bool isWaiting = false;

  String audioRecordingFilePath;

  String beep_hi_file_path;
  String beep_lo_file_path;

  RecordButtonState(){

    _checkMicrophonePermissions();

    beep_hi_file_path = '';
    beep_lo_file_path = '';

    loadAudio('beep_hi.wav').then((localtmpfile){
      beep_hi_file_path = localtmpfile;
    });

    loadAudio('beep_lo.wav').then((localtmpfile){
      beep_lo_file_path = localtmpfile;
    });

    platform.setMethodCallHandler(nativeCallbackHandler);

  }

  Future<String> loadAudio(String asset_filename) async {
    final file = new File('${(await getTemporaryDirectory()).path}/' + asset_filename);
    await file.writeAsBytes((await loadAudioAsset(asset_filename)).buffer.asUint8List());
    return file.path;
  }

  Future<ByteData> loadAudioAsset(String filename) async {
    return await rootBundle.load('assets/audio/' + filename);
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
      if (beep_hi_file_path!='')
        platform.invokeMethod('playRecording', beep_hi_file_path);
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
      if (beep_lo_file_path!='')
        platform.invokeMethod('playRecording', beep_lo_file_path);

      stopRecordingResult = await platform.invokeMethod('stopRecording');
    }
    on PlatformException catch (e) {
      stopRecordingResult = "FAIL";
    }

    //
    setState((){
      final ConversationBloc conversationBloc = BlocProvider.of<ConversationBloc>(this.context);

      isListening=false;
      if (stopRecordingResult!="FAIL") {
        audioRecordingFilePath = stopRecordingResult;
        conversationBloc.processSpeech.add(audioRecordingFilePath);

        //platform.invokeMethod('playRecording', audioRecordingFilePath);

      } else {
        audioRecordingFilePath = null;
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    final ConversationBloc conversationBloc = BlocProvider.of<ConversationBloc>(context);

    return new Padding(
      padding: new EdgeInsets.all(12.0),
      child: StreamBuilder(
          stream: conversationBloc.conversation,
          builder: (context, snapshot) => FloatingActionButton(
            child: new Icon(getIcon(snapshot.data), size: 32.0),
                            backgroundColor: getBackgroundColor(snapshot.data),
                            onPressed: getOnPress(snapshot.data),
          ),
      )
    );

  }


  IconData getIcon(ConversationModel model){
    if (model!=null) {
      if (model.isWaiting==true)
        return Icons.mic_off;
    }

    if (isListening)
      return Icons.mic_none;

    return Icons.mic;

  }

  Color getBackgroundColor(ConversationModel model)
  {
    if (model!=null) {
      if (model.isWaiting)
        return Colors.deepOrangeAccent;
    }

    if (isListening)
      return Colors.redAccent;

    return Colors.teal;

  }

  VoidCallback getOnPress(ConversationModel model){
    if (!isListening)
      return _startRecording;
    else
      return _stopRecording;
  }

}
