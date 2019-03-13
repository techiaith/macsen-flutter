import 'package:flutter/material.dart';

import 'RecordButtonWidget.dart';
import 'StopButtonWidget.dart';
import 'MacsenDrawer.dart';
import 'MacsenAssistantWidget.dart';
import 'TextualRequestWidget.dart';

import 'package:macsen/blocs/application_state_provider.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key,}) : super (key: key);

  @override
  HomePageState createState() => HomePageState();
}


class HomePageState extends State<HomePage> {

  final List<Widget> _children = [
    MacsenAssistantWidget(),
    TextualRequestWidget(),
    Container(),
    Container()
  ];


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
                  MacsenDrawer(),
              )
            ),

        body:
          StreamBuilder<int>(
            initialData: 0,
            stream: appBloc.onCurrentApplicationPageChange,
            builder: (context, snapshot) => _children[snapshot.data],
          ),

        floatingActionButton: StreamBuilder(
            initialData: 0,
            stream: appBloc.onCurrentApplicationPageChange,
            builder: (context, snaphotPageChange) =>
              StreamBuilder<ApplicationWaitState>(
                stream: appBloc.onApplicationWaitStateChange,
                builder: (context, snapshotApplicationWaitState) =>
                  _buildActionButton(context,
                                     snaphotPageChange.data,
                                     snapshotApplicationWaitState.data)
                )
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        bottomNavigationBar:
          StreamBuilder<int>(
            initialData: 0,
            stream: appBloc.onCurrentApplicationPageChange,
            builder: (context, snapshot) =>
              BottomNavigationBar(
                currentIndex: snapshot.data,
                onTap: onTabPressed,
                type: BottomNavigationBarType.fixed,
                fixedColor: Colors.black87,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.mic),
                    title: new Text("Siarad"),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat),
                    title: new Text("Testun"),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.assignment),
                    title: new Text("Hyfforddi"),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    title: new Text("Gosodiadau"),
                  )
                ]
              ),
          )
      );
  }


  void onTabPressed(int index) {
    final ApplicationBloc appBloc = ApplicationStateProvider.of(context);
    appBloc.changeCurrentApplicationPage.add(index);
  }



  Widget _buildActionButton(BuildContext context, int currentPageIndex, ApplicationWaitState appState){
    if (currentPageIndex==0){
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


}