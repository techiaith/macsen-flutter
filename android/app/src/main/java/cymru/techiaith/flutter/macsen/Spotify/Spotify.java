package cymru.techiaith.flutter.macsen.Spotify;

import android.util.Log;

import com.spotify.android.appremote.api.ConnectionParams;
import com.spotify.android.appremote.api.Connector;
import com.spotify.android.appremote.api.SpotifyAppRemote;
import com.spotify.protocol.types.Track;

import com.spotify.android.appremote.api.SpotifyAppRemote;

import cymru.techiaith.flutter.macsen.MainActivity;

public class Spotify {

    public static final String CLIENT_ID = "300debafe4ee42a1b1631015796b1681";
    public static final String REDIRECT_URI = "cymru.techiaith.flutter.macsen://callback";

    private MainActivity _mainactivity;
    private SpotifyAppRemote mSpotifyAppRemote = null;

    public Spotify(MainActivity activity){
        _mainactivity=activity;
    }


    public boolean connect(final String spotifyUri){

        //@todo - gwirio os yw Spotify wedi'i osod.
        // h.y. SpotifyAppRemote.isSpotifyInstalled(...)
        //

        //
        if (mSpotifyAppRemote!=null && mSpotifyAppRemote.isConnected()){
            play_artist(spotifyUri);
        } else {
            ConnectionParams connectionParams =
                    new ConnectionParams.Builder(CLIENT_ID)
                            .setRedirectUri(REDIRECT_URI)
                            .showAuthView(true)
                            .build();

            SpotifyAppRemote.connect(_mainactivity, connectionParams,
                    new Connector.ConnectionListener() {
                        @Override
                        public void onConnected(SpotifyAppRemote spotifyAppRemote) {
                            mSpotifyAppRemote=spotifyAppRemote;
                            play_artist(spotifyUri);
                        }

                        @Override
                        public void onFailure(Throwable throwable) {
                            Log.e("MainActivity", throwable.getMessage(), throwable);
                        }
                    });
        }
        return true;
    }


    public boolean disconnect(){
        try{
            mSpotifyAppRemote.getPlayerApi().pause();
            SpotifyAppRemote.disconnect(mSpotifyAppRemote);
            mSpotifyAppRemote=null;
        } catch (Exception exc){
            return false;
        }
        return true;
    }


    private boolean play_artist(String spotifyUri){

        mSpotifyAppRemote.getPlayerApi().play(spotifyUri);

        // Subscribe to PlayerState
        mSpotifyAppRemote.getPlayerApi()
                .subscribeToPlayerState()
                .setEventCallback(playerState -> {
                    final Track track = playerState.track;
                    if (track != null) {
                        Log.d("MainActivity", track.name + " by " + track.artist.name);
                    }
                });

        return true;
    }

}
