package cymru.techiaith.flutter.macsen;

import android.Manifest;
import android.os.Bundle;
import android.content.pm.PackageManager;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.Queue;
import java.util.LinkedList;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import cymru.techiaith.flutter.macsen.WavAudio.WavAudioRecorder;
import cymru.techiaith.flutter.macsen.WavAudio.WavAudioPlayer;
import cymru.techiaith.flutter.macsen.WavAudio.WavAudioPlayerEventListener;
import cymru.techiaith.flutter.macsen.Spotify.Spotify;

import android.view.ViewTreeObserver;
import android.view.WindowManager;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler,
                                                             WavAudioPlayerEventListener {

    public class PermissionRequest {
        public String permission_string;
        public int permission_number;
        PermissionRequest(String permission_string, int permission_number){
            this.permission_string=permission_string;
            this.permission_number=permission_number;
        }
    }

    Queue<PermissionRequest> permissionRequestQueue = new LinkedList<PermissionRequest>();
    private boolean awaitingPermissionResponse = false;

    private static final String METHOD_CHANNEL;

    static {
        METHOD_CHANNEL = "cymru.techiaith.flutter.macsen";
    }

    private final static int PERMISSIONS_REQUEST_RECORD_AUDIO = 22;
    private final static int PERMISSIONS_REQUEST_LOCATION = 25;

    private WavAudioRecorder wavAudioRecorder;
    private WavAudioPlayer wavAudioPlayer;

    private MethodChannel wavplayer_channel;
    private MethodChannel wavrecorder_channel;

    private MethodChannel spotify_channel;
    private Spotify spotify;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //make transparent status bar
        //getWindow().setStatusBarColor(0x00000000);
        GeneratedPluginRegistrant.registerWith(this);

        //Remove full screen flag after load
        ViewTreeObserver vto = getFlutterView().getViewTreeObserver();
        vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                getFlutterView().getViewTreeObserver().removeOnGlobalLayoutListener(this);
                getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
            }
        });


        wavrecorder_channel = new MethodChannel(getFlutterView(), METHOD_CHANNEL + "/wavrecorder");
        wavrecorder_channel.setMethodCallHandler(this);

        wavplayer_channel = new MethodChannel(getFlutterView(), METHOD_CHANNEL + "/wavplayer");
        wavplayer_channel.setMethodCallHandler(this);

        spotify_channel = new MethodChannel(getFlutterView(), METHOD_CHANNEL + "/spotify");
        spotify_channel.setMethodCallHandler(this);

        wavAudioRecorder = new WavAudioRecorder(this);

        wavAudioPlayer = new WavAudioPlayer(this);
        wavAudioPlayer.registerWavAudioPlayerEventListener(this);

        spotify = new Spotify(this);

        checkMicrophonePermission();

    }


    protected void onStart(){
        super.onStop();
    }


    protected void onStop(){
        super.onStop();
        spotify.disconnect();
    }


    @Override
    public void onMethodCall(MethodCall methodCall,
                            MethodChannel.Result result) {
        //
        if (methodCall.method.equals("checkMicrophonePermissions")) {
            result.success(checkMicrophonePermission());
        } else if (methodCall.method.equals("startRecording")){
            result.success(wavAudioRecorder.startRecord(methodCall.argument("filename")) ? "OK":"FAIL");
        } else if (methodCall.method.equals("stopRecording")) {
            result.success(wavAudioRecorder.stopRecord() ? wavAudioRecorder.getWavFile().getAbsolutePath() : "FAIL");
        } else if (methodCall.method.equals("playRecording")) {
            result.success(wavAudioPlayer.playAudio(methodCall.argument("filepath")) ? "OK":"FAIL");
        } else if (methodCall.method.equals("stopPlayingRecording")) {
            result.success(wavAudioPlayer.stopPlaying() ? "OK" : "FAIL");
        } else if (methodCall.method.equals("checkIsSpotifyInstalled")) {
            result.success(spotify.isSpotifyInstalled(this));
        } else if (methodCall.method.equals("spotifyPlayArtistOrBand")){
            result.success(spotify.connect((String) methodCall.argument("artist_uri")) ? "OK":"FAIL");
        } else if (methodCall.method.equals(("spotifyStopPlayArtistOrBand"))) {
            result.success(spotify.disconnect());
        } else {
            result.notImplemented();
        }
    }


    private Boolean checkMicrophonePermission(){
        int permissionCheck = ContextCompat.checkSelfPermission(this,  Manifest.permission.RECORD_AUDIO);
        boolean hasPermission = permissionCheck == PackageManager.PERMISSION_GRANTED;
        if (hasPermission) {
            return true;
        }
        else {
            permissionRequestQueue.add(new PermissionRequest(
                    Manifest.permission.RECORD_AUDIO,
                    PERMISSIONS_REQUEST_RECORD_AUDIO
            ));
            askForNextPermission();
            return false;
        }
    }



    private void askForNextPermission(){
        if (permissionRequestQueue.size()>0){
            if (awaitingPermissionResponse==false){
                PermissionRequest nextRequest = permissionRequestQueue.remove();
                awaitingPermissionResponse = true;
                ActivityCompat.requestPermissions(this,
                        new String[]{nextRequest.permission_string},
                        nextRequest.permission_number);
            }
        }
    }


    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[],
                                           int[] grantResults) {
        switch (requestCode) {
            case PERMISSIONS_REQUEST_RECORD_AUDIO: {
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    wavrecorder_channel.invokeMethod("audioRecordingPermissionGranted","OK");
                }
                break;
            }
        }
        awaitingPermissionResponse = false;
        askForNextPermission();
    }


    public void onWavAudioPlayerCompletionEvent(String audioFilePath){
        System.out.println("Native callback audioPlayCompleted");
        wavplayer_channel.invokeMethod("audioPlayCompleted", audioFilePath);
    }


}
