import 'dart:async';
import 'dart:convert' as JSON;

import 'package:flutter/services.dart';
import 'package:macsen/blocs/application_state_provider.dart';

const MethodChannel _native_spotify_api = const MethodChannel('cymru.techiaith.flutter.macsen/spotify');

class Spotify{



  static Future<bool> execute(ApplicationBloc applicationBloc,
                      dynamic json) async {

    bool playSpotifyResult = true;

    try {
      bool isInstalled = await isSpotifyInstalled();

      if (isInstalled) {
        var jsonResult = JSON.jsonDecode(json);
        String spotifyUrl = jsonResult["result"][0]["url"].trim();

        //@todo - check for empty string

        try {
          await _native_spotify_api.invokeMethod('spotifyPlayArtistOrBand', <String, dynamic>{
            "artist_uri":spotifyUrl
          });
        }
        on PlatformException catch (e) {
          playSpotifyResult = false;
          applicationBloc.raiseApplicationException.add(
              "Roedd problem cysylltu i'r ap Spotify.");
        }
        return playSpotifyResult;
      } else {
        applicationBloc.raiseApplicationException.add(
            "Nid yw Spotify wedi'i osod ar eich dyfais.");
      }
    }

    on PlatformException catch (e) {
      playSpotifyResult = false;
      applicationBloc.raiseApplicationException.add("Roedd problem cysylltu i'r ap Spotify.");
    }

    return playSpotifyResult;

  }


  static Future<bool> isSpotifyInstalled() async {
    Future<bool> inst;
    try {
      inst = _native_spotify_api.invokeMethod("checkIsSpotifyInstalled");
    }
    catch (e) {
      print(e);
    }
    return inst;
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