import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:hue_dart/src/core/bridge.dart';
import 'package:hue_dart/src/core/bridge_discovery.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GolauPage extends StatefulWidget {
  GolauPage({Key key,}) : super (key: key);

  @override
  GolauState createState() => GolauState();

}

class GolauState extends State<GolauPage> {

  String username = "";

  @override
  Widget build(BuildContext context){

    double text_size = 22.0;

    return Scaffold(
        appBar: AppBar(
          title: new Text("Gosod Golau Phillips hue"),
        ),
        body: Container(
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top:20.0),
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text("Ar ôl gosod eich golau gyda'r ap HUE gan Phillips mae angen cofrestru Macsen gyda'ch HUE Bridge",
                        style: TextStyle(fontSize: text_size)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top:20.0),
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text("Mae angen enwi eich golau gydag un o'r enwau yma er mwyn i Macsen ei adnabod: Cyntedd, Cegin, Lolfa, Ystafell fyw, Ystafell wely, Ystafell ymolchi.",
                        style: TextStyle(fontSize: text_size)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top:20.0),
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text("Gyda’ch ffôn ar gael, ewch i'r bocs 'HUE Bridge' a phwyswch y botwm yn y canol. Wedyn pwyswch y botwm cofrestru a disgwyl am y testun i ddangos oddi tdan.",
                        style: TextStyle(fontSize: text_size)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top:20.0),
                    child: ElevatedButton (
                      onPressed: _registerUser,
                      child: Text("Cofrestru",
                          style: TextStyle(fontSize: 24.0)),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top:20.0),
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text(username,
                        style: TextStyle(fontSize: text_size)),
                  )
                ]
            )
        )
    );

  }


  _registerUser() async {
    String tun = "";
    tun = await getUserName();
    if (tun == "") {
      final client = Client();
      final discovery = BridgeDiscovery(client);
      final discoverResults = await discovery.automatic();
      final discoveryResult = discoverResults.first;
      final bridge = Bridge(client, discoveryResult.ipAddress);
      try{
        final whiteListItem = await bridge.createUser('dart_hue#macsen');
        bridge.username = whiteListItem.username;
        setUserName(whiteListItem.username);
        tun = whiteListItem.username;
      }
      catch (e) {
        tun = "Pwyswch y botwm ar y HUE Bridge cyn y botwm cofrestru.";
      }
    }
    setState(() {
      username = tun;
    });
  }
}

Future<bool> setUserName(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString("hue_bridge_user",value);
}

Future<String> getUserName() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("hue_bridge_user")) {
    return prefs.getString("hue_bridge_user");
  }
  return "";
}