import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class MacsenDrawer extends StatelessWidget {

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
                    title:
                    Text('Ynghylch',
                        style:
                        TextStyle(
                            fontSize: 24.0,
                        )
                    ),
//                    onTap: () {
//                      Navigator.pop(context);
//                      Navigator.of(context).push(
//                        MaterialPageRoute(
//                          builder: (context) => RecordSentenceScreen(),
//                        )
//                      );
//                    },
                  )
                ],
              )
          )
        ]
      );
  }
}
