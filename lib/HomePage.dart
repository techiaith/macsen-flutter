import 'package:flutter/material.dart';

import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/ConversationBloc.dart';

import 'RecordButtonWidget.dart';
import 'MacsenDrawer.dart';

class HomePage extends StatelessWidget  {

  @override
  Widget build(BuildContext context) {

    final ConversationBloc conversationBloc = BlocProvider.of<ConversationBloc>(context);
    double mediaWidth = MediaQuery.of(context).size.width;
    double width_80 = mediaWidth * 0.8;

    // https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/menu_demo.dart

    return new Scaffold(
        appBar:
          AppBar(title: new Text("Macsen")),

        drawer:
          Drawer(
            child:
              Container(
                color: Colors.white,
                child:
                  MacsenDrawer(),
              )
            ),

        body:
          Center(
            child:
              Column(
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
                        style: TextStyle(fontSize: 24)
                      ),
                    ),
                  ), //Text(snapshot.data)
                ],
              ),
          ),

        floatingActionButton: new RecordButtonWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );

  }

}