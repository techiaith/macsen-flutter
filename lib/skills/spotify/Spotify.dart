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

        try {
          _native_spotify_api.invokeMethod('spotifyPlayArtistOrBand', spotifyUrl);
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
    return _native_spotify_api.invokeMethod("checkIsSpotifyInstalled");
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