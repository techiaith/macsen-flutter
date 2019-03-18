import 'package:flutter/material.dart';
import 'package:macsen/blocs/application_state_provider.dart';

import 'package:macsen/blocs/intent_bloc.dart';

class MacsenHelpWidget extends StatefulWidget {
  MacsenHelpWidget({Key key,}) : super (key: key);

  @override
  _MacsenHelpState createState() => _MacsenHelpState();
}

class _MacsenHelpState extends State<MacsenHelpWidget>{

  final double font_size = 18.0;

  Widget build(BuildContext context){
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    appBloc.intentParsingBloc.getAllSentences.add(true);

    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top:20.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Help",
                style: TextStyle(fontSize: font_size+4)),
          ),
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0, top:20.0, bottom: 20.0),
            child: Text("Dyma'r cwestiynau mae Macsen medru adnabod a gweithredu ar..",
                        style: TextStyle(fontSize: font_size),
                        textAlign: TextAlign.left)
          ),
          Expanded(
              child: StreamBuilder<List<Skill>>(
                  stream: appBloc.intentParsingBloc.allSentencesResult,
                  initialData: List<Skill>(),
                  builder: (context, snapshot) => ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return new SkillTile(snapshot.data[index]);
                      }
                  )
              )
          )
        ]
      );
  }

}

class SkillTile extends StatelessWidget {

  final Skill skill;
  final double font_size=18.0;
  SkillTile(this.skill);

  @override build(BuildContext context){
    return  Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: ExpansionTile(
          title: Text(this.skill.name, style: TextStyle(fontSize: font_size)),
          children: this.skill.sentences.map(_buildSentenceTile).toList()
        )
    );
  }

  Widget _buildSentenceTile(String sentence){
    return new ListTile(
      title: Text(sentence, style: TextStyle(fontSize: font_size)),
    );
  }

}