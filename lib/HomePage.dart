import 'package:flutter/material.dart';

import 'RecordButtonWidget.dart';
import 'MacsenDrawer.dart';

import 'package:macsen/blocs/application_state_provider.dart';

class HomePage extends StatelessWidget  {

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

        floatingActionButton: new RecordButtonWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );

  }

}