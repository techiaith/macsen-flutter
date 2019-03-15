import 'dart:convert' as JSON;
import 'package:flutter/services.dart';
import 'package:macsen/blocs/application_state_provider.dart';

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
      playSpotifyResult = false;
      applicationBloc.raiseApplicationException.add("Roedd problem cysylltu i'r ap Spotify.");
    }
    return playSpotifyResult;
  }


  static bool stop(ApplicationBloc applicationBloc){
    try {
      _native_spotify_api.invokeMethod('spotifyStopPlayArtistOrBand');
    }
    on PlatformException catch (e) {
      applicationBloc.raiseApplicationException.add("Roedd problem cysylltu i'r ap Spotify.");
      return false;
    }
    return true;
  }


}