import 'package:flutter/material.dart';
import 'package:macsen/blocs/application_state_provider.dart';

class MacsenAssistantWidget extends StatefulWidget {
  MacsenAssistantWidget({Key key,}) : super (key: key);

  @override
  _MacsenWidgetState createState() => _MacsenWidgetState();
}

class _MacsenWidgetState extends State<MacsenAssistantWidget> {

  bool _isConfirmedToProceed=false;

  Widget build(BuildContext context) {

    if (_isConfirmedToProceed)
      return _buildRequestAndResponse(context);
    else
      return _buildIntroduction(context);

  }


  Widget _buildRequestAndResponse(BuildContext context){

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    appBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationReady);

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


  Widget _buildIntroduction(BuildContext context){
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    appBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationNotReady);

    double text_size = 18.0;

    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("Siarad", style: TextStyle(fontSize: text_size+4)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("I siarad â'r ap, pwyswch yr eicon microffon gwyrdd. Dylai droi'n goch.",
                    style: TextStyle(fontSize: text_size)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("Gofynnwch eich cwestiwn neu lefarwch eich gorchymyn.",
                      style: TextStyle(fontSize: text_size)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("e.e. \"Beth yw'r newyddion?\", \"Beth yw'r tywydd?\"",
                style: TextStyle(fontSize: text_size)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("Pwyswch eicon y microffon eto pan fyddwch wedi gorffen siarad. Dylai droi nôl yn wyrdd.",
                      style: TextStyle(fontSize: text_size)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("Bydd Macsen wedyn yn rhoi ateb i'ch cwestiwn neu'n gweithredu yn ôl eich gorchymyn.",
                    style: TextStyle(fontSize: text_size)),
              ),
              Container(
                  margin: EdgeInsets.only(top:20.0),
                  child: RaisedButton(
                    onPressed: _onIawnButtonPressed,
                    child: Text("Iawn", style: TextStyle(fontSize: 18.0)),
                  )
              )
            ]
        )
    );

  }

  void _onIawnButtonPressed(){
    setState((){
      _isConfirmedToProceed=true;
    });
  }


}