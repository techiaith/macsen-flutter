
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:macsen/blocs/microphone_bloc.dart';
import 'package:macsen/blocs/application_state_provider.dart';


class RecordButtonWidget extends  StatefulWidget {
  RecordButtonWidget({Key key,
    this.onPressed,}) : super(key: key);

  final VoidCallback onPressed;

  @override
  RecordButtonState createState() => new RecordButtonState();
}

const MethodChannel platform = const MethodChannel('cymru.techiaith.flutter.macsen/wavrecorder');

class RecordButtonState extends State<RecordButtonWidget> {

  @override
  Widget build(BuildContext context) {

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    return Padding(
      padding:
        EdgeInsets.all(12.0),
        child:
            StreamBuilder(
              stream: appBloc.microphoneBloc.microphoneStatus,
              builder: (context, snapshot) =>
                FloatingActionButton(
                  onPressed: widget.onPressed,
                  backgroundColor: getBackgroundColor(snapshot.data),
                  child: Icon(getMicrophoneIcon(snapshot.data), size: 32.0),
                )
            ),
    );
  }


  IconData getMicrophoneIcon(MicrophoneStatus micStatus){
    print ("getMicrophoneIcon " + micStatus.toString());
    if (micStatus == MicrophoneStatus.NotAllowed)
      return Icons.mic_off;

    if (micStatus == MicrophoneStatus.Recording)
      return Icons.mic_none;

    return Icons.mic;
  }


  Color getBackgroundColor(MicrophoneStatus micStatus){
    print ("getBackgroundColor " + micStatus.toString());
    if (micStatus == MicrophoneStatus.Recording){
      return Colors.redAccent;
    }
    if (micStatus == MicrophoneStatus.NotAllowed){
      return Colors.red;
    }
    return Colors.teal;
  }


  //VoidCallback getOnPress() {
  //  final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
  //  appBloc.microphoneBloc.record.add(true);
  //  return null;
  //}


}
