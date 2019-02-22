import 'package:flutter/material.dart';

import 'RecordButtonWidget.dart';
import 'MacsenDrawer.dart';

import 'package:macsen/blocs/application_state_provider.dart';

class RecordSentenceScreen extends StatefulWidget {
  RecordSentenceScreen({Key key, this.title}): super(key: key);
  final String title;

  @override
  _RecordSentenceScreenState createState() => _RecordSentenceScreenState();

}

class _RecordSentenceScreenState extends State<RecordSentenceScreen>  {

  String _sentenceToRecord;

  @override
  Widget build(BuildContext context) {

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    double mediaWidth = MediaQuery.of(context).size.width;
    double width_80 = mediaWidth * 0.8;

    appBloc.getUniqueUID().then((uid){
      appBloc.intentParsingBloc.getUnRecordedSentences.add(uid);
    });

    return new Scaffold(
        appBar: AppBar(
            title: Text("Hyfforddi")
        ),

        body:
          Center(
            child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder<String>(
                    stream: appBloc.intentParsingBloc.unRecordedSentenceResult,
                    initialData: '',
                    builder: (context, snapshot) => Container(
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
          ),

        floatingActionButton: new RecordButtonWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );

  }

}