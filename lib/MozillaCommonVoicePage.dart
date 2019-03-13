import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MozillaCommonVoicePage extends StatefulWidget {
  MozillaCommonVoicePage({Key key,}) : super (key: key);

  @override
  MozillaCommonVoiceState createState() => MozillaCommonVoiceState();

}

class MozillaCommonVoiceState extends State<MozillaCommonVoicePage> {

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: new Text("Gwefan Mozilla Common Voice"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: _launchCommonVoiceUrl,
          child: Text("Agor CommonVoice", style: TextStyle(fontSize: 24.0)),
        ),
      )
    );
  }


  _launchCommonVoiceUrl() async {
    const url = "https://voice.mozilla.org/cy";
    if (await canLaunch(url)){
      await launch(url);
      Navigator.pop(context);
    } else {
      throw 'Methu agor CommonVoice';
    }
  }


}