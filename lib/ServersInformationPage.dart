import 'dart:async';

import 'package:flutter/material.dart';

import 'package:macsen/blocs/application_state_provider.dart';

class ServersInformationPage extends StatefulWidget {
  ServersInformationPage({Key key, this.title}) : super (key: key);

  final String title;

  @override
  ServersInformationPageState createState() => ServersInformationPageState();

}

class ServersInformationPageState extends State<ServersInformationPage>{

  @override
  Widget build(BuildContext context){

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    appBloc.getUniqueUID().then((uid){
      appBloc.speechToTextBloc.getServerInformation.add(true);
    });

    return Scaffold(
      appBar: AppBar(
        title: new Text(widget.title),
      ),
      body:
          Container(
            margin: EdgeInsets.only(top:30.0),
            child:
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildServerInfoRow("Enw Model: ", appBloc.speechToTextBloc.modelName),
                  _buildServerInfoRow("Fersiwn: ", appBloc.speechToTextBloc.modelVersion)
                ]
              ),
          )
    );

  }

  Widget _buildServerInfoRow(String label, Stream<String> datastream){
    return Container(
        margin: EdgeInsets.only(top:10.0, left:20.0),
        child:
          Row (
            children: <Widget> [
              Text (label, style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
              Container (
                padding: EdgeInsets.only(left: 5.0),
                child:
                  StreamBuilder<String>(
                    initialData: '',
                    stream: datastream,
                    builder: (context, snapshot) => Text(
                      snapshot.data,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24.0)
                  )
              )
          )
        ]
      )
    );
  }

}