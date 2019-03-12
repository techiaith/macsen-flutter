import 'package:flutter/material.dart';

import 'RecordButtonWidget.dart';
import 'StopButtonWidget.dart';
import 'MacsenDrawer.dart';

import 'package:macsen/blocs/application_state_provider.dart';

class HomePageScreen extends StatefulWidget {
  HomePageScreen({Key key,}) : super (key: key);

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {

  @override
  Widget build(BuildContext context) {

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    double mediaWidth = MediaQuery.of(context).size.width;
    double width_80 = mediaWidth * 0.8;

    return new Scaffold(
        appBar:
          AppBar(title: new Text("Macsen")),

        drawer:
          Drawer(
            child:
              Container(
                color: Colors.white,
                child:
                  MacsenDrawer(),
              )
            ),

        body:
          Center(
            child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder<String>(
                    stream: appBloc.currentRequestText,
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
                  StreamBuilder<String>(
                    stream: appBloc.currentResponseText,
                    initialData: '',
                    builder: (context, snapshot) => Container(
                      width: width_80,
                      child: Text(
                        snapshot.data,
                        maxLines: 10,
                        style: TextStyle(fontSize: 24)
                      ),
                    ),
                  ), //Text(snapshot.data)
                ],
              ),
          ),

        floatingActionButton: StreamBuilder<ApplicationWaitState>(
            stream: appBloc.onApplicationWaitStateChange,
            builder: (context, snapshot) => _buildActionButton(context, snapshot.data)
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );

  }


  Widget _buildActionButton(BuildContext context, ApplicationWaitState appState){
    if (appState==ApplicationWaitState.ApplicationWaiting){
      return new CircularProgressIndicator();
    } else if (appState==ApplicationWaitState.ApplicationPerforming){
      return new StopButtonWidget(
        onPressed: onStopRequestPress,
      );
    }
    return new RecordButtonWidget(
      onPressed: onRequestPress,
    );
  }


  VoidCallback onStopRequestPress(){
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    appBloc.stopPerformingCurrentIntent.add(true);
    return null;
  }


  VoidCallback onRequestPress() {
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    appBloc.recordingType.add(RecordingType.RequestRecording);
    appBloc.microphoneBloc.record.add(true);
    return null;
  }


}