import 'package:flutter/material.dart';

import 'package:macsen/blocs/application_state_provider.dart';


class TextualInputScreen extends StatefulWidget {

  TextualInputScreen({Key key, this.title}): super(key: key);
  final String title;

  @override
  _TextualInputFormState createState() => new _TextualInputFormState();

}


class _TextualInputFormState extends State<TextualInputScreen>{

  final _formKey = GlobalKey<FormState>();
  String _requestText;

  @override
  Widget build(BuildContext context) {

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Mewnbwn Testun"),
      ),
      body:
        Card(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
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
                                Navigator.pop(context, _requestText);
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
        ),
    );
  }

}