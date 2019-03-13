import 'package:flutter/material.dart';
import 'package:macsen/blocs/application_state_provider.dart';

class TrainingWidget extends StatefulWidget {
  TrainingWidget({Key key,}) : super (key: key);

  @override
  _TrainingState createState() => _TrainingState();
}

class _TrainingState extends State<TrainingWidget>{

  Widget build(BuildContext context){
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    double mediaWidth = MediaQuery
        .of(context)
        .size
        .width;
    double width_80 = mediaWidth * 0.8;

    appBloc.getUniqueUID().then((uid){
      appBloc.intentParsingBloc.getUnRecordedSentences.add(uid);
    });

    return Center(
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
    );
  }

}
