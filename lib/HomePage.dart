import 'dart:async';
import 'package:flutter/material.dart';

import 'RecordButtonWidget.dart';
import 'StopButtonWidget.dart';
import 'AppDrawer.dart';

import 'MacsenAssistantWidget.dart';
import 'MacsenTranscribeWidget.dart';
import 'MacsenTrainingWidget.dart';
import 'MacsenHelpWidget.dart';

import 'package:macsen/blocs/application_state_provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key,}) : super (key: key);

  @override
  HomePageState createState() => HomePageState();
}


class HomePageState extends State<HomePage> {

  final List<Widget> _children = [
    MacsenAssistantWidget(),
    MacsenTranscribeWidget(),
    MacsenTrainingWidget(),
    MacsenHelpWidget()
  ];


  String _currentDialogMessage;


  @override
  Widget build(BuildContext context) {

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    return new Scaffold
      (
        appBar:
          AppBar(title: new Text("Macsen")),

        drawer:
          Drawer(
            child:
              Container(
                color: Colors.white,
                child:
                  AppDrawer(),
              )
            ),

        body:
            StreamBuilder<String>(
              initialData: '',
              stream: appBloc.onApplicationException,
              builder: (context, snapShotApplicationException) =>
                StreamBuilder<PageChangeEventInformation>(
                  initialData: PageChangeEventInformation(0, PageChangeReason.Null),
                  stream: appBloc.onCurrentApplicationPageChange,
                  builder: (context, snapshotPageIndex) => _buildPageAction(
                      context,
                      snapshotPageIndex.data,
                      snapShotApplicationException.data),
                  ),
            ),

        floatingActionButton: StreamBuilder<PageChangeEventInformation>(
            stream: appBloc.onCurrentApplicationPageChange,
            initialData: PageChangeEventInformation(0, PageChangeReason.Null),
            builder: (context, snapshotPageChange) =>
              StreamBuilder<ApplicationWaitState>(
                stream: appBloc.onApplicationWaitStateChange,
                builder: (context, snapshotApplicationWaitState) =>
                  _buildActionButton(context,
                                     snapshotPageChange.data,
                                     snapshotApplicationWaitState.data)
                )
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        bottomNavigationBar:
          StreamBuilder<PageChangeEventInformation>(
            initialData: PageChangeEventInformation(0, PageChangeReason.Null),
            stream: appBloc.onCurrentApplicationPageChange,
            builder: (context, snapshot) =>
              BottomNavigationBar(
                selectedItemColor: Colors.black87,
                unselectedItemColor: Colors.grey,
                currentIndex: snapshot.data.pageIndex,
                onTap: onTabPressed,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.mic),
                    label: "Siarad",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.messenger_outline),
                    label: "Trawsgrifio",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.assignment),
                    label: "Hyfforddi",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.help),
                    label: "Help",
                  )
                ]
              ),
          )
      );
  }


  void onTabPressed(int index) {
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    appBloc.changeApplicationWaitState.add(ApplicationWaitState.ApplicationReady);
    PageChangeEventInformation pageChangeInfo = new PageChangeEventInformation(index, PageChangeReason.User);
    appBloc.changeCurrentApplicationPage.add(pageChangeInfo);
  }


  Widget _buildPageAction(BuildContext context,
                          PageChangeEventInformation pageChangeEventInfo,
                          String exceptionMessage){

    if (exceptionMessage.length > 0){
      if (_currentDialogMessage != exceptionMessage){
        _currentDialogMessage = exceptionMessage;
        WidgetsBinding.instance.addPostFrameCallback((_) => _showDialog(context, exceptionMessage));
      }
    }
    return _children[pageChangeEventInfo.pageIndex];
  }


  Future<Widget> _showDialog(BuildContext context, String message) async {

    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Gwybodaeth",style: TextStyle(fontSize: 24.0)),
        content: Text(message, style: TextStyle(fontSize: 24.0)),
        actions: <Widget>[
          ElevatedButton(
            child: Text('Iawn', style: TextStyle(fontSize: 24.0)),
            onPressed: (){
              _currentDialogMessage='';
              appBloc.raiseApplicationException.add('');
              Navigator.of(context).pop();
            },
          )
        ],
      )
    );
  }


  Widget _buildActionButton(BuildContext context,
                            PageChangeEventInformation pageChange,
                            ApplicationWaitState appState){
    int currentPageIndex=pageChange.pageIndex;
    if ((currentPageIndex==0) || (currentPageIndex==1) || (currentPageIndex==2)){

      if (appState==ApplicationWaitState.ApplicationWaiting){
        return new CircularProgressIndicator();
      }
      else if (appState==ApplicationWaitState.ApplicationPerforming){
        return new StopButtonWidget(
          onPressed: onStopRequestPress,
        );
      }
      else if (appState==ApplicationWaitState.ApplicationNotReady){
        return Container();
      }

      //
      if (currentPageIndex==0) {
        return new RecordButtonWidget(
          onPressed: onRequestPress,
        );
      }
      else if (currentPageIndex==1){
        return new RecordButtonWidget(
          onPressed: onTranscribePress
        );
      }
      else if (currentPageIndex==2) {
        return new RecordButtonWidget(
            onPressed: onRecordPress
        );
      }

    }

    return Container();

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


  VoidCallback onRecordPress() {
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    appBloc.recordingType.add(RecordingType.SentenceRecording);
    appBloc.microphoneBloc.record.add(true);
    return null;
  }

  VoidCallback onTranscribePress() {
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    appBloc.recordingType.add(RecordingType.TranscribeRecording);
    appBloc.microphoneBloc.record.add(true);
    return null;
  }
}