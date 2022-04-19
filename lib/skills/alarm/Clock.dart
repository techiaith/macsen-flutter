import 'dart:io';
import 'dart:async';
import 'dart:convert' as JSON;

import 'package:flutter/services.dart';
import 'package:macsen/blocs/loudspeaker_bloc.dart';

import 'package:path_provider/path_provider.dart';

import 'ScheduledTimer.dart';

import 'package:macsen/blocs/application_state_provider.dart';
import 'package:macsen/blocs/text_to_speech.dart';

//
// removing flutter_local_notifications plugin because of...
// https://github.com/GiddyNaya/clockee
//
class Clock {

  ApplicationBloc _applicationBloc;
  ScheduledTimer _timer;
  SoundFile _timerSoundFile;

  Clock(this._applicationBloc){
    _timer=null;
  }


  Future<bool> init(String timerId, String sound_asset_filename) async
  {
    //
    final file = new File('${(await getTemporaryDirectory()).path}/' + sound_asset_filename);
    await file.writeAsBytes((await rootBundle.load('assets/audio/' + sound_asset_filename)).buffer.asUint8List());
    _timerSoundFile = new SoundFile(file.path, '', '');

    //
    if (_timer == null){
      _timer = _createScheduledTimer(timerId,'');
    }

    return true;

  }


  ScheduledTimer _createScheduledTimer(String timerId, String description){

    return new ScheduledTimer(
        id: timerId,
        description: description,
        onExecute: _onExecute,
        onMissedSchedule: _onMissedSchedule,
    );

  }

  void _onExecute()
  {
    print("$_timer.id ar ben");

    String message = _buildEventMessage();

    _applicationBloc.loudspeakerBloc.play.add(_timerSoundFile);
    _applicationBloc.raiseApplicationException.add(message);

    _timer.clearSchedule();
  }

  void _onMissedSchedule() {
    print ("$_timer.id wedi ei fethu");
    _onExecute();
  }

  String _buildEventMessage()
  {
    String message = _timer.description;
    if (message.startsWith("Am amseru")){
      message = "Amserydd " + message.replaceAll("Am amseru", "");
    } else if (message.startsWith("Am gosod larwm")){
      message = "Larwm " + message.replaceAll("Am gosod larwm", "");
    }
    return message;
  }

  Future<void> setTimer(dynamic json) async {

    // {"result": [{"title": "Amserydd",
    // "description": "Am amseru pum munud munud",
    // "url": "",
    // "duration_length": "300"}],
    // "success": true}
    //
    var jsonResult = JSON.jsonDecode(json);

    try
    {
      if (jsonResult["success"] == true) {

        String description = jsonResult["result"][0]["description"];
        int seconds = int.parse(jsonResult["result"][0]["duration_length"]);

        var timerEventDateTime = DateTime.now().add(Duration(seconds:seconds));
        print (timerEventDateTime);

        _timer = _createScheduledTimer("timer", description);

        //
        await _timer.clearSchedule();
        await _timer.schedule(timerEventDateTime);
        await _timer.start();

        //
        _applicationBloc.textToSpeechBloc.queue.add(TextToSpeechText(description, '', '', false));
        _applicationBloc.textToSpeechBloc.speakQueue.add(true);

      }
    } catch (e) {
      _applicationBloc.raiseApplicationException.add("Roedd problem gosod yr amserydd.");
    }

  }


  Future<void> setAlarm(dynamic json) async {

    // {"result": [{"title": "Amserydd",
    // "description": "Am amseru pum munud munud",
    // "url": "",
    // "duration_length": "300"}],
    // "success": true}
    //
    var jsonResult = JSON.jsonDecode(json);

    try
    {
      if (jsonResult["success"] == true) {

        String description = jsonResult["result"][0]["description"];
        var hour = jsonResult["result"][0]["alarmtime"]["hour"];
        int minute = 0;

        var nowDateTime = DateTime.now();
        var timerEventDateTime = new DateTime(
          nowDateTime.year,
          nowDateTime.month,
          nowDateTime.day,
          hour, minute);

        print (timerEventDateTime);

        _timer = _createScheduledTimer("alarm", description);

        //
        await _timer.clearSchedule();
        await _timer.schedule(timerEventDateTime);
        await _timer.start();

        //
        _applicationBloc.textToSpeechBloc.queue.add(TextToSpeechText(description, '', '', false));
        _applicationBloc.textToSpeechBloc.speakQueue.add(true);

      }
    } catch (e) {
      _applicationBloc.raiseApplicationException.add("Roedd problem gosod yr amserydd.");
    }

  }


}
