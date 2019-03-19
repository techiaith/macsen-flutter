import 'package:flutter/material.dart';
import 'package:macsen/blocs/application_state_provider.dart';


class MacsenTextualRequestWidget extends StatefulWidget {
  MacsenTextualRequestWidget({Key key,}) : super (key: key);

  @override
  _MacsenTextualRequestState createState() => _MacsenTextualRequestState();
}


class _MacsenTextualRequestState extends State<MacsenTextualRequestWidget> {

  final _formKey = GlobalKey<FormState>();
  String _requestText;

  Widget build(BuildContext context){

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    return Card(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                          hintText: "Teipiwch eich cwestiwn neu orchymyn yma a phwyso 'Gofyn'.",
                          labelText: "Cwestiwn neu Gorchymyn"
                      ),
                      style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.black
                      ),
                      maxLines: 5,
                      onSaved: (input) => _requestText = input,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(10.0),
                            child: RaisedButton(
                              onPressed: ()
                              {
                                _formKey.currentState.save();
                                print ("request text " + _requestText);
                                appBloc.request.add(_requestText);
                                appBloc.changeCurrentApplicationPage.add(0);
                              },
                              child: Text("Gofyn",
                                style: TextStyle(
                                    fontSize: 24.0
                                ),
                              ),
                            )
                        )
                      ],
                    )
                  ],
                )
            )
        )
    );
  }
}
