import 'package:flutter/material.dart';
import 'package:macsen/blocs/application_state_provider.dart';

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
            padding: EdgeInsets.only(left: 20.0, right: 20.0, top:40.0, bottom: 40.0),
            child: Text("Dyma'r cwestiynau mae Macsen\n medru adnabod a gweithredu ar i chi..",
                        style: TextStyle(fontSize: 24.0),
                        textAlign: TextAlign.center)
          ),
          Expanded(
              child: StreamBuilder<List<String>>(
                  stream: appBloc.intentParsingBloc.allSentencesResult,
                  initialData: List<String>(),
                  builder: (context, snapshot) => ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return new ListTile(
                          title: new Text(
                            snapshot.data[index],
                            style: TextStyle(fontSize: 24.0)
                          )
                        );
                      }
                  )
              )
          )
        ]
      );
  }

}