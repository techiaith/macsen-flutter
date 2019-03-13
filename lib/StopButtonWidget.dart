
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:macsen/blocs/application_state_provider.dart';


class StopButtonWidget extends  StatefulWidget {
  StopButtonWidget({Key key,
    this.onPressed,}) : super(key: key);

  final VoidCallback onPressed;


  @override
  StopButtonState createState() => new StopButtonState();
}

const MethodChannel platform = const MethodChannel('cymru.techiaith.flutter.macsen/wavrecorder');

class StopButtonState extends State<StopButtonWidget> {

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
                  backgroundColor: Colors.red,
                  child: Icon(Icons.stop, size: 32.0),
                )
            ),
    );
  }

}
