import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macsen/blocs/application_state_provider.dart';


class MacsenTranscribeWidget extends StatefulWidget {
  MacsenTranscribeWidget({Key key,}) : super (key: key);

  @override
  _MacsenTranscribeState createState() => _MacsenTranscribeState();
}


class _MacsenTranscribeState extends State<MacsenTranscribeWidget> {

  final _formKey = GlobalKey<FormState>();
  static bool _isConfirmedToProceed=false;

  Widget build(BuildContext build){
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    return StreamBuilder<PageChangeEventInformation>(
        stream: appBloc.onCurrentApplicationPageChange,
        initialData: PageChangeEventInformation(1, PageChangeReason.Null),
        builder: (context, snapshot) => _buildPage(context, snapshot.data));
  }

  Widget _buildPage(BuildContext context,
                    PageChangeEventInformation pageChangeInfo) {

    if (pageChangeInfo.pageIndex == 1 &&
        pageChangeInfo.reason == PageChangeReason.Application) {
      _isConfirmedToProceed = true;
    }

    //
    if (_isConfirmedToProceed)
      return _build_TranscriptionInterface(context);
    else
      return _buildIntroduction(context);
  }


  Widget _build_TranscriptionInterface(BuildContext context){

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Container(
            margin: EdgeInsets.only(top: 40.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: StreamBuilder<String>(
              stream: appBloc.currentTranscribedText,
              initialData: '',
              builder: (context, snapshot) =>
                  _buildTranscriptionResult(context, snapshot.data)
            )
          ),

          Container(
            margin: EdgeInsets.only(top: 20, left: 20),
            child: StreamBuilder<String>(
              stream: appBloc.currentTranscribedText,
              initialData: '',
              builder: (context, snapshot) =>
                  _buildCopyButton(context, snapshot.data)
            )
          )

        ],

    );
  }

  Widget _buildTranscriptionResult(BuildContext context, String text){

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    appBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationReady);

    double text_size = 24.0;

    return Text(text,
        maxLines: 10,
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: text_size)
    );
  }


  Widget _buildCopyButton(BuildContext context, String text) {

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    if (text.length > 0) {
      return ElevatedButton(
          onPressed: () {
            _copyToClipboard(text);
          },
          child: Text("Copïo", style: TextStyle(fontSize: 14.0)));
    } else {
      return new Container();
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
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
                child: Text("Trawsgrifio", style: TextStyle(fontSize: text_size+4)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("Trawsgrifio unrhyw beth chi'n dweud yn Gymraeg i destun.",
                    style: TextStyle(fontSize: text_size)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("Pwyswch y botwm recordio i ddechrau ac i orffen recordio. Bydd eich testun wedyn yn ymddangos ar y sgrîn",
                    style: TextStyle(fontSize: text_size)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("Copïwch y testun draw i ap arall er mwyn ei yrru fel neges",
                    style: TextStyle(fontSize: text_size)),
              ),

              Container(
                  margin: EdgeInsets.only(top:20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _onIawnButtonPressed(context);
                    },
                    child: Text("Iawn", style: TextStyle(fontSize: 18.0)),
                  )
              )
            ]
        )
    );

  }


  void _onIawnButtonPressed(BuildContext context){
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    appBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationReady);

    setState((){
      _isConfirmedToProceed=true;
    });
  }


}
