import 'package:flutter/material.dart';

import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/ConversationBloc.dart';

import 'RecordButtonWidget.dart';

class HomePage extends StatelessWidget  {

  @override
  Widget build(BuildContext context) {
    final ConversationBloc conversationBloc = BlocProvider.of<ConversationBloc>(context);
    double mediaWidth = MediaQuery.of(context).size.width;
    double width_80 = mediaWidth * 0.8;

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
              builder: (context, snapshot) => Container(
                  width: width_80,
                  child: Text(
                      snapshot.data,
                      maxLines: 10,
                      style: TextStyle(
                        fontSize: 12
                      )
                  ),
                ),
              ), //Text(snapshot.data)
          ],
        ),
      ),

      floatingActionButton: new RecordButtonWidget(),

    );
  }

}