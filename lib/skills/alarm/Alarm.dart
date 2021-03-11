import 'dart:async';
import 'dart:convert' as JSON;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:macsen/blocs/application_state_provider.dart';
import 'package:macsen/blocs/text_to_speech.dart';

class Alarm {
  ApplicationBloc _applicationBloc;

  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  Alarm(this._applicationBloc);

  Future<void> execute(dynamic json) async {
    var jsonResult = JSON.jsonDecode(json);

    // {"result": [{"title": "Gosod larwm",
    // "description": "Am gosod larwm am chwech yn y bore",
    // "alarmtime": {"minutes": 0, "hour": 6, "string": "2019-03-08 06:00"}}],
    // "success": true, "intent": "gosoda.larwm", "version": 1}

    bool setAlarmResult = true;

    _applicationBloc.textToSpeechBloc.queue.add(TextToSpeechText(
        jsonResult["result"][0]["description"], '', '', false));
    _applicationBloc.textToSpeechBloc.speakQueue.add(true);

    //
    var vibrationPattern = new Int64List(4);

    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    try {
      if (jsonResult["result"][0]["success"] == true) {
        int hour = jsonResult["result"][0]["alarmtime"]["hour"];
        int minute = 0; //jsonResult["result"][0]["alarmtime"]["minute"];

        var nowDateTime = new DateTime.now();

        var scheduledNotificationDateTime = new DateTime(
            nowDateTime.year, nowDateTime.month, nowDateTime.day, hour, minute);

        //
        // sound from http://soundbible.com/339-Alarm-Alert-Effect.html
        // (public domain)
        //
        var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
            'macsen_alarm_channel_id',
            'your other channel name',
            'your other channel description',
            icon: 'secondary_icon',
            sound: RawResourceAndroidNotificationSound('alarm_alert_effect_soundbibledotcom_462520910'),
            largeIcon: DrawableResourceAndroidBitmap('sample_large_icon'),
            vibrationPattern: vibrationPattern,
            color: const Color.fromARGB(255, 255, 0, 0)
        );

        var iOSPlatformChannelSpecifics = new IOSNotificationDetails(
            sound: "slow_spring_board.aiff"
        );

        var platformChannelSpecifics = new NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: iOSPlatformChannelSpecifics
        );

        await flutterLocalNotificationsPlugin.schedule(
            0,
            'Larwm Macsen',
            "Dyma eich larwm am " + hour.toString() + "o'r gloch.",
            scheduledNotificationDateTime,
            platformChannelSpecifics);
      }
    } on PlatformException catch (e) {
      _applicationBloc.raiseApplicationException
          .add("Roedd problem gosod larwm.");
      setAlarmResult = false;
    }
  }
}
