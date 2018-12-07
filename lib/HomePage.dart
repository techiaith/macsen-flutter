import 'package:flutter/material.dart';

import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/ConversationBloc.dart';

import 'RecordButtonWidget.dart';

class HomePage extends StatelessWidget  {

  @override
  Widget build(BuildContext context) {
    final ConversationBloc conversationBloc = BlocProvider.of<ConversationBloc>(context);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Macsen"),
      ),
      body: new Center(

        child: new Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<String>(
              stream: conversationBloc.transcription,
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