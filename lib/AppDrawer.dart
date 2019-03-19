import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:macsen/InformationPage.dart';
import 'package:macsen/MozillaCommonVoicePage.dart';


class AppDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context){

    return ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 100.0,
            child:
              DrawerHeader(
                  decoration: BoxDecoration(color: Colors.teal),
                  child:
                    Text('Dewisiadau',
                      style:
                        TextStyle(
                          fontSize: 24.0,
                          color: Colors.white
                        )
                    ),
              )
          ),
          Container(
            color: Colors.white,
            child:
              Column (
                children: <Widget>[
                  ListTile(
                    title: Text('Ynghylch Macsen', style: TextStyle(fontSize: 22.0)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InformationPage(
                              title: 'Ynghylch Macsen',
                              markdownFile: 'assets/markdown/ynghylch.md',
                            )
                        )
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Preifatrwydd', style: TextStyle(fontSize: 22.0)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InformationPage(
                                title: 'Ynghylch Macsen',
                                markdownFile: 'assets/markdown/preifatrwydd.md',
                              )
                          )
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Mozilla CommonVoice', style: TextStyle(fontSize: 22.0)),
                    //subtitle: Text('(gwefan allanol)', style: TextStyle(fontSize: 12.0)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MozillaCommonVoicePage()
                        )
                      );
                    },
                  )
                ],
              )
          )
        ]
      );
  }
}