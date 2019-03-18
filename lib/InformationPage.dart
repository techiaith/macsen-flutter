import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';


class InformationPage extends StatefulWidget {
  InformationPage({Key key, this.title, this.markdownFile}) : super (key: key);

  final String title;
  final String markdownFile;

  @override
  InformationPageState createState() => InformationPageState();

}

class InformationPageState extends State<InformationPage>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: new Text(widget.title),
      ),
      body:
          FutureBuilder<String>(
            future: loadHtml(widget.markdownFile),
            initialData: '',
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Markdown(
                    data: snapshot.data
                );
              }
            }
          ),
    );
  }


  Future<String> loadHtml(String markdownFile) async {
    return await rootBundle.loadString(markdownFile);
  }


}