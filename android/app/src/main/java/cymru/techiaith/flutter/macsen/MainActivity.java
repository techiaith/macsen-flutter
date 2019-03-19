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

import cymru.techiaith.flutter.macsen.Geolocation.Geolocation;
import cymru.techiaith.flutter.macsen.WavAudio.WavAudioRecorder;
import cymru.techiaith.flutter.macsen.WavAudio.WavAudioPlayer;
import cymru.techiaith.flutter.macsen.WavAudio.WavAudioPlayerEventListener;
import cymru.techiaith.flutter.macsen.Spotify.Spotify;


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

    private MethodChannel location_channel;
    private Geolocation geolocation;

    private MethodChannel spotify_channel;
    private Spotify spotify;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
       super.onCreate(savedInstanceState);

        GeneratedPluginRegistrant.registerWith(this);

        wavrecorder_channel = new MethodChannel(getFlutterView(), METHOD_CHANNEL + "/wavrecorder");
        wavrecorder_channel.setMethodCallHandler(this);

        wavplayer_channel = new MethodChannel(getFlutterView(), METHOD_CHANNEL + "/wavplayer");
        wavplayer_channel.setMethodCallHandler(this);

        location_channel = new MethodChannel(getFlutterView(), METHOD_CHANNEL + "/geolocation");
        location_channel.setMethodCallHandler(this);

        spotify_channel = new MethodChannel(getFlutterView(), METHOD_CHANNEL + "/spotify");
        spotify_channel.setMethodCallHandler(this);

        wavAudioRecorder = new WavAudioRecorder(this);

        wavAudioPlayer = new WavAudioPlayer(this);
        wavAudioPlayer.registerWavAudioPlayerEventListener(this);

        geolocation = new Geolocation(this);
        spotify = new Spotify(this);

        checkMicrophonePermission();
        checkLocationPermission();

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
        } else if (methodCall.method.equals("requestLastLocation")){
            result.success(checkLocationPermission());
        } else if (methodCall.method.equals("startRecording")){
            result.success(wavAudioRecorder.startRecord((String) methodCall.arguments) ? "OK":"FAIL");
        } else if (methodCall.method.equals("stopRecording")) {
            result.success(wavAudioRecorder.stopRecord() ? wavAudioRecorder.getWavFile().getAbsolutePath() : "FAIL");
        } else if (methodCall.method.equals("playRecording")) {
            result.success(wavAudioPlayer.playAudio((String) methodCall.arguments) ? "OK":"FAIL");
        } else if (methodCall.method.equals("stopPlayingRecording")) {
            result.success(wavAudioPlayer.stopPlaying() ? "OK" : "FAIL");
        } else if (methodCall.method.equals("spotifyPlayArtistOrBand")){
            result.success(spotify.connect((String) methodCall.arguments) ? "OK":"FAIL");
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


    private Boolean checkLocationPermission(){
        int permissionCheck = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION );
        boolean permissionGranted = permissionCheck == PackageManager.PERMISSION_GRANTED;
        if (permissionGranted) {
            geolocation.returnLastLocationreturnLastLocation(location_channel);
            return true;
        } else {
            permissionRequestQueue.add(new PermissionRequest(
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                    PERMISSIONS_REQUEST_LOCATION
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
            case PERMISSIONS_REQUEST_LOCATION: {
                if (grantResults.length > 0 && grantResults[0]  == PackageManager.PERMISSION_GRANTED){
                    geolocation.returnLastLocationreturnLastLocation(location_channel);
                } else {
                    location_channel.invokeMethod("locationCoordinates", "NOT_GRANTED");
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
