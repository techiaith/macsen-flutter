import 'package:flutter/material.dart';
import 'package:macsen/blocs/application_state_provider.dart';

import 'package:macsen/blocs/intent_bloc.dart';

class MacsenHelpWidget extends StatefulWidget {
  MacsenHelpWidget({Key key,}) : super (key: key);

  @override
  _MacsenHelpState createState() => _MacsenHelpState();
}

class _MacsenHelpState extends State<MacsenHelpWidget>{

  Widget build(BuildContext context){
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    appBloc.intentParsingBloc.getAllSentences.add(true);

    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0, top:40.0, bottom: 20.0),
            child: Text("Dyma'r cwestiynau mae Macsen medru adnabod a gweithredu ar..",
                        style: TextStyle(fontSize: 22.0),
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
  SkillTile(this.skill);

  @override build(BuildContext context){
    return ExpansionTile(
      title: Text(this.skill.name, style: TextStyle(fontSize: 22.0)),
      children: this.skill.sentences.map(_buildSentenceTile).toList()
    );
  }

  Widget _buildSentenceTile(String sentence){
    return new ListTile(
      title: Text(sentence, style: TextStyle(fontSize: 18.0)),
    );
  }

}