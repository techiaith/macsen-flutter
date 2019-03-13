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

    double mediaWidth = MediaQuery
        .of(context)
        .size
        .width;
    double width_80 = mediaWidth * 0.8;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder<String>(
            stream: appBloc.currentRequestText,
            initialData: '',
            builder: (context, snapshot) =>
                Container(
                  width: width_80,
                  child: Text(
                      snapshot.data,
                      maxLines: 10,
                      style: TextStyle(fontSize: 24)
                  ),
                ),
          ),
          StreamBuilder<String>(
            stream: appBloc.currentResponseText,
            initialData: '',
            builder: (context, snapshot) =>
                Container(
                  width: width_80,
                  child: Text(
                      snapshot.data,
                      maxLines: 10,
                      style: TextStyle(fontSize: 24)
                  ),
                ),
          ),
        ],
      ),
    );
  }

}