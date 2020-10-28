import 'dart:async';

import 'package:flutter/material.dart';
import 'package:macsen/blocs/application_state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MacsenAssistantWidget extends StatefulWidget {
  MacsenAssistantWidget({
    Key key,
  }) : super(key: key);

  @override
  _MacsenWidgetState createState() => _MacsenWidgetState();
}

class _MacsenWidgetState extends State<MacsenAssistantWidget> {
  static bool _isConfirmedToProceed = false;

  Widget build(BuildContext context) {
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    return StreamBuilder<PageChangeEventInformation>(
        stream: appBloc.onCurrentApplicationPageChange,
        initialData: PageChangeEventInformation(0, PageChangeReason.Null),
        builder: (context, snapshot) => _buildPage(context, snapshot.data));
  }

  Widget _buildPage(
      BuildContext context, PageChangeEventInformation pageChangeInfo) {
    if (pageChangeInfo.pageIndex == 0 &&
        pageChangeInfo.reason == PageChangeReason.Application) {
      _isConfirmedToProceed = true;
    }

    if (_isConfirmedToProceed)
      return _buildRequestAndResponse(context);
    else
      return _buildIntroduction(context);
  }

  Widget _buildRequestAndResponse(BuildContext context) {
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    double text_size = 24.0;

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 40.0),
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          child: StreamBuilder<String>(
            stream: appBloc.currentRequestText,
            initialData: '',
            builder: (context, snapshot) => Text(snapshot.data,
                maxLines: 3,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: text_size)),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 40.0),
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          child: StreamBuilder<String>(
            stream: appBloc.currentResponseText,
            initialData: '',
            builder: (context, snapshot) => Text(snapshot.data,
                maxLines: 10,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: text_size)),
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 20, left: 20),
            child: StreamBuilder<String>(
                stream: appBloc.currentResponseUrl,
                initialData: '',
                builder: (context, snapshot) =>
                    _buildUrlButton(context, snapshot.data)))
      ],
    );
  }

  Widget _buildUrlButton(BuildContext context, String url) {
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    if (url == null || url.contains("https://www.s4c.cymru/clic/programme/"))
      return new Container();

    if (url.length > 0) {
      return RaisedButton(
          onPressed: () {
            appBloc.stopPerformingCurrentIntent.add(true);
            _launchUrl(url);
          },
          child: Text("Darllen rhagor....", style: TextStyle(fontSize: 14.0)));
    } else {
      return new Container();
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Methu agor y dudalen we';
    }
  }

  Widget _buildIntroduction(BuildContext context) {
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    appBloc.changeApplicationWaitState
        .add(ApplicationWaitState.ApplicationNotReady);

    double text_size = 18.0;

    return SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 20.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Siarad", style: TextStyle(fontSize: text_size + 4)),
          ),
          Container(
            margin: EdgeInsets.only(top: 20.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text(
                "I siarad â'r ap, pwyswch yr eicon microffon gwyrdd. Dylai droi'n goch.",
                style: TextStyle(fontSize: text_size)),
          ),
          Container(
            margin: EdgeInsets.only(top: 20.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Gofynnwch eich cwestiwn neu lefarwch eich gorchymyn.",
                style: TextStyle(fontSize: text_size)),
          ),
          Container(
            margin: EdgeInsets.only(top: 20.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("e.e. \"Beth yw'r newyddion?\", \"Beth yw'r tywydd?\"",
                style: TextStyle(fontSize: text_size)),
          ),
          Container(
            margin: EdgeInsets.only(top: 20.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text(
                "Pwyswch eicon y microffon eto pan fyddwch wedi gorffen siarad. Dylai droi nôl yn wyrdd.",
                style: TextStyle(fontSize: text_size)),
          ),
          Container(
            margin: EdgeInsets.only(top: 20.0),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text(
                "Ewch i 'Help' i weld y fath o gwestiynau mae Macsen adnabod.",
                style: TextStyle(fontSize: text_size)),
          ),
          Container(
              margin: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                onPressed: () {
                  appBloc.changeApplicationWaitState
                      .add(ApplicationWaitState.ApplicationReady);
                  _onIawnButtonPressed();
                },
                child: Text("Iawn", style: TextStyle(fontSize: 18.0)),
              ))
        ]));
  }

  void _onIawnButtonPressed() {
    setState(() {
      _isConfirmedToProceed = true;
    });
  }
}
