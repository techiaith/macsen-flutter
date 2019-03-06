package cymru.techiaith.flutter.macsen.Spotify;

import com.spotify.android.appremote.api.ConnectionParams;
import com.spotify.android.appremote.api.Connector;
import com.spotify.android.appremote.api.SpotifyAppRemote;

import com.spotify.protocol.client.Subscription;
import com.spotify.protocol.types.PlayerState;
import com.spotify.protocol.types.Track;

public class SpotifyRemote {

    public static final String CLIENT_ID = "..........";
    public static final String REDIRECT_URI = "cymru.techiaith.flutter.macsen://callback";
    private SpotifyAppRemote mSpotifyAppRemote;
    
}
