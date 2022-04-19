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

    double text_size = 22.0;

    return Scaffold(
      appBar: AppBar(
        title: new Text("Gwefan Mozilla Common Voice"),
      ),
      body: Container(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("Common Voice yw cynllun Mozilla i helpu dysgu peiriannau sut mae pobl go-iawn yn siarad.",
                    style: TextStyle(fontSize: text_size)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("I greu systemau lleferydd, mae datblygwyr angen swm sylweddol iawn o recordiadau o leisiau bobl.",
                    style: TextStyle(fontSize: text_size)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text("Gallwch gyfrannu eich llais i adeiladu cronfa ddata lleisiau fydd pawb yn gallu ei defnyddio i greu rhagor o apiau arloesol ar gyfer dyfeisiau, yr we a'r Gymraeg",
                    style: TextStyle(fontSize: text_size)),
              ),
              Container(
                margin: EdgeInsets.only(top:20.0),
                child: ElevatedButton (
                  onPressed: _launchCommonVoiceUrl,
                  child: Text("Agor CommonVoice",
                      style: TextStyle(fontSize: 24.0)),
                ),
              )
            ]
        )
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