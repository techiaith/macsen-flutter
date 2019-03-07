import 'dart:convert' as JSON;

import 'package:macsen/blocs/application_state_provider.dart';

import 'package:flutter/services.dart';

const MethodChannel _native_spotify_api = const MethodChannel('cymru.techiaith.flutter.macsen/spotify');

class Spotify{

  static bool execute(ApplicationBloc applicationBloc,
                      dynamic json) {
    var jsonResult = JSON.jsonDecode(json);

    bool playSpotifyResult = true;
    String spotifyUrl=jsonResult["result"][0]["url"].trim();

    try {
      _native_spotify_api.invokeMethod('spotifyPlayArtistOrBand', spotifyUrl);
    }
    on PlatformException catch (e) {
      print(e.message);
      playSpotifyResult = false;
    }
    return playSpotifyResult;
  }

}