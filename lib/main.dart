import 'package:flutter/material.dart';

import 'HomePage.dart';

import 'package:macsen/bloc/BlocProvider.dart';
import 'package:macsen/bloc/SpeechToTextBloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Macsen',
      theme: ThemeData(
        primarySwatch: Colors.teal
      ),
      home: BlocProvider<SpeechToTextBloc>(
        bloc: SpeechToTextBloc(),
        child: HomePage(),
      ),
    );
  }
}
