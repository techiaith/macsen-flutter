import 'package:flutter/material.dart';
import 'package:macsen/blocs/application_state_provider.dart';

class MacsenTrainingWidget extends StatefulWidget {
  MacsenTrainingWidget({Key key,}) : super (key: key);

  @override
  _MacsenTrainingState createState() => _MacsenTrainingState();
}

class _MacsenTrainingState extends State<MacsenTrainingWidget>{

  static bool _isConfirmedToProceed=false;

  Widget build(BuildContext context){

    if (_isConfirmedToProceed)
      return _buildRecordingSentences(context);
    else
      return _buildIntroAndConfirm(context);

  }


  Widget _buildIntroAndConfirm(BuildContext context){

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    appBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationNotReady);

    double text_size = 18.0;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top:20.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Hyfforddi", style: TextStyle(fontSize: text_size+4)),
          ),
          Container(
            margin: EdgeInsets.only(top:20.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Ar hyn o bryd, dyw Macsen ddim yn adnabod eich cwestiynau bob amser.",
                style: TextStyle(fontSize: text_size)),
          ),
          Container(
            margin: EdgeInsets.only(top:10.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Helpwch ni i’w wella drwy recordio rhai ohonyn nhw i greu dwy set fechan ar gyfer gwaith datblygu.",
                style: TextStyle(fontSize: text_size)),
          ),
          Container(
            margin: EdgeInsets.only(top:10.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Drwy gyfrannu eich llais, rydych yn rhoi hawl i ni storio’r llais ar weinydd y project, a’i gyhoeddi ar drwydded agored ganiataol fel rhan o set ddatblygu neu set brofi. Golyga hynny y bydd modd i unrhyw un arall ddefnyddio’r lleisiau hefyd heb gyfyngiad. Ni fydd enw nac unrhyw fanylion personol eraill ynghlwm wrth y lleisiau hyn.", style: TextStyle(fontSize: text_size)),
          ),
          Container(
            margin: EdgeInsets.only(top:10.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Ar ôl glicio ar 'Iawn', bydd cwestiynau yn ymddangos. Pwyswch y botwm microffon i ddechrau a gorffen recordio.", style: TextStyle(fontSize: text_size)),
          ),
          Container(
            margin: EdgeInsets.only(top:20.0),
            child: ElevatedButton (
              child: Text("Iawn", style: TextStyle(fontSize: 18.0)),
              onPressed: (){
                appBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationReady);
                _onIawnButtonPressed();
              },
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


  Widget _buildRecordingSentences(BuildContext context){

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    appBloc.getUniqueUID().then((uid){
      appBloc.intentParsingBloc.getUnRecordedSentences.add(uid);
    });

    return Center(
      child: Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        child: StreamBuilder<String>(
          initialData: '',
          stream: appBloc.intentParsingBloc.unRecordedSentenceResult,
          builder: (context, snapshot) => Text(
            snapshot.data,
            maxLines: 4,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32.0)
          ),
        )
      ),
    );
  }


}
