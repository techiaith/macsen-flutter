import 'package:flutter/services.dart';
import 'dart:convert' as JSON;
import 'package:macsen/blocs/application_state_provider.dart';


const MethodChannel _native_alarm_api = const MethodChannel('cymru.techiaith.flutter.macsen/alarm');


class Alarm {

  static bool execute(ApplicationBloc applicationBloc,
                      dynamic json) {
    var jsonResult = JSON.jsonDecode(json);

    // {"result": [{"title": "Gosod larwm", "description": "Am gosod larwm am chwech yn y bore", "alarmtime": {"minutes": 0, "hour": 6, "string": "2019-03-08 06:00"}}], "success": true, "intent": "gosoda.larwm", "version": 1}

    bool setAlarmResult = true;
    int hour = jsonResult["result"][0]["alarmtime"]["hour"];
    int minutes = jsonResult["result"][0]["alarmtime"]["minutes"];

    try {
      _native_alarm_api.invokeMethod('setAlarm', {'hour':hour, 'minutes':minutes});
    }
    on PlatformException catch (e) {
      print(e.message);
      setAlarmResult = false;
    }
    return setAlarmResult;
  }

}