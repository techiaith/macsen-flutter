import 'dart:async';
import 'dart:convert' as JSON;

import 'package:flutter/services.dart';
import 'package:macsen/blocs/application_state_provider.dart';

import 'package:http/http.dart';
import 'package:hue_dart/hue_dart.dart';
import 'package:hue_dart/src/core/bridge.dart';
import 'package:hue_dart/src/core/bridge_discovery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hue_dart/src/light/light_state.dart';

const MethodChannel _native_spotify_api = const MethodChannel('cymru.techiaith.flutter.macsen/spotify');

class Golau {
  static Future<bool> execute(ApplicationBloc applicationBloc, dynamic json) async {
    bool lightStateChange = true;
    try {
      var jsonResult = JSON.jsonDecode(json);
      final client = Client();
      final discovery = BridgeDiscovery(client);
      final discoverResults = await discovery.automatic();
      final discoveryResult = discoverResults.first;
      final bridge = Bridge(client, discoveryResult.ipAddress);
      bridge.username = await getUserName();
      final lights = await bridge.lights();;
      for (var i = 0; i < lights.length; i++) {
        var light = lights[i];
        var l = LightState();
        var room = roomNameCleaner(jsonResult["result"][0]["room"].trim());
        if (light.name.toLowerCase() == room) {
          var state = LightState((b) => b..on = jsonResult["result"][0]["description"].trim().contains("ymlaen"));
          await bridge.updateLightState(light.rebuild(
                (l) => l..state = state.toBuilder(),
          ));
        }
      }
      return lightStateChange;
    }
    catch (e) {
      lightStateChange = false;
      applicationBloc.raiseApplicationException.add("Roedd problem cysylltu i'r golau.");
    }
    return lightStateChange;
  }
}

Future<String> getUserName() async {
final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("hue_bridge_user");
}

String roomNameCleaner(String input) {
  switch (input) {
    case "gegin":
      return "cegin";
  }
  return input;
}