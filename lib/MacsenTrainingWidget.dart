import 'package:flutter/material.dart';
import 'package:macsen/blocs/application_state_provider.dart';

class MacsenTrainingWidget extends StatefulWidget {
  MacsenTrainingWidget({Key key,}) : super (key: key);

  @override
  _MacsenTrainingState createState() => _MacsenTrainingState();
}

class _MacsenTrainingState extends State<MacsenTrainingWidget>{

  Widget build(BuildContext context){
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    appBloc.getUniqueUID().then((uid){
      appBloc.intentParsingBloc.getUnRecordedSentences.add(uid);
    });

    double text_size = 24.0;

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top:20.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Mae Macsen yn medru deall eich cwestiynau ddim ond weithiau.", style: TextStyle(fontSize: text_size)),
          ),
          Container(
            margin: EdgeInsets.only(top:10.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Helpwch ni i'w wella drwy recordio rhai ohonynt.", style: TextStyle(fontSize: text_size)),
          ),
          Container(
            margin: EdgeInsets.only(top:10.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Bydd cwestiynau yn ymddangos isod, pwyswch y botwm meicroffon i ddechrau ac i orffen y recordiad.", style: TextStyle(fontSize: text_size)),
          ),
          Container(
            margin: EdgeInsets.only(top: 40.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: StreamBuilder<String>(
              initialData: '',
              stream: appBloc.intentParsingBloc.unRecordedSentenceResult,
              builder: (context, snapshot) => Text(
                    snapshot.data,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32.0)
                ),
              ),
          ),
        ],
      ),
    );
  }
}
