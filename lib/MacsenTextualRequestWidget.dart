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

  static bool _isConfirmedToProceed=false;


  Widget build(BuildContext build){

    if (_isConfirmedToProceed)
      return _build_TextForm(context);
    else
      return _buildIntroduction(context);
  }


  Widget _build_TextForm(BuildContext context){

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
                              appBloc.request.add(_requestText);
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


  Widget _buildIntroduction(BuildContext context){
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    appBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationNotReady);

    double text_size = 18.0;
    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("Teipio", style: TextStyle(fontSize: text_size+4)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("Teipiwch eich cwestiwn neu orchymyn yma a phwyso 'Gofyn'",
                    style: TextStyle(fontSize: text_size)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("Mae'n bosib gofyn cwestiwn tu hwnt i allu presennol Siarad Macsen, fel holi am dywydd dref neu ddinas benodol",
                    style: TextStyle(fontSize: text_size)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("e.e. \"Beth yw'r tywydd yng Nghaernarfon?\"",
                    style: TextStyle(fontSize: text_size)),
              ),
              Container(
                  margin: EdgeInsets.only(top:20.0),
                  child: RaisedButton(
                    onPressed: _onIawnButtonPressed,
                    child: Text("Iawn", style: TextStyle(fontSize: 18.0)),
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


}
