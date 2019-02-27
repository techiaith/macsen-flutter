import 'package:flutter/material.dart';
import 'package:macsen/blocs/application_state_provider.dart';

import 'HomePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ApplicationStateProvider(
      child: MaterialApp(
        title: 'Macsen',
        theme:
          ThemeData(
            primarySwatch: Colors.teal
          ),
        home:
          HomePageScreen(),
      )
    );
  }


//    return MaterialApp(
//        title: 'Macsen',
//        theme:
//          ThemeData(
//            primarySwatch: Colors.teal
//          ),
//        home:
//          BlocProvider<ConversationBloc>(
//            bloc: ConversationBloc(),
//            child: HomePage(),
//          ),
////        routes:
////          <String, WidgetBuilder>{
////              "/TextualInputScreen": (BuildContext context) => new TextualInputScreen(),
////          }
//    );

}