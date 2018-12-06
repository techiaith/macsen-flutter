
import 'package:flutter/material.dart';

import 'RecordButtonWidget.dart';
import 'package:macsen/bloc/BlocProvider.dart';
import 'package:macsen/bloc/SpeechToTextBloc.dart';

class HomePage extends StatelessWidget  {

  @override
  Widget build(BuildContext context) {
    final  SpeechToTextBloc sttBloc = BlocProvider.of<SpeechToTextBloc>(context);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Macsen"),
      ),
      body: new Center(

        child: new Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<String>(
              stream: sttBloc.transcription,
              initialData: '',
              builder: (context, snapshot) => Text(snapshot.data)
            )
          ],
        ),
      ),

      floatingActionButton: new RecordButtonWidget(),

    );
  }

}