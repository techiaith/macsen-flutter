import 'package:flutter/material.dart';
import 'package:macsen/blocs/application_state_provider.dart';

class MacsenAssistantWidget extends StatefulWidget {
  MacsenAssistantWidget({Key key,}) : super (key: key);

  @override
  _MacsenWidgetState createState() => _MacsenWidgetState();
}

class _MacsenWidgetState extends State<MacsenAssistantWidget> {

  Widget build(BuildContext context) {
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    double text_size = 24.0;

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top:40.0),
          padding: EdgeInsets.only(left:20.0, right: 20.0),
          child: StreamBuilder<String>(
            stream: appBloc.currentRequestText,
            initialData: '',
            builder: (context, snapshot) => Text(
                      snapshot.data,
                      maxLines: 10,
                      style: TextStyle(fontSize: text_size)
                  ),
                ),
        ),
        Container(
          margin: EdgeInsets.only(top:40.0),
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          child: StreamBuilder<String>(
            stream: appBloc.currentResponseText,
            initialData: '',
            builder: (context, snapshot) => Text(
                      snapshot.data,
                      maxLines: 10,
                      style: TextStyle(fontSize: text_size)
                  ),
                ),
        ),
      ],
    );
  }

}