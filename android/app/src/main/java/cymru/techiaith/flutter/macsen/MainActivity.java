package cymru.techiaith.flutter.macsen;

import android.Manifest;
import android.os.Bundle;
import android.content.pm.PackageManager;

import android.support.v4.app.ActivityCompat;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import cymru.techiaith.flutter.macsen.WavAudio.WavAudioRecorder;
import cymru.techiaith.flutter.macsen.WavAudio.WavAudioPlayer;
import cymru.techiaith.flutter.macsen.WavAudio.WavAudioPlayerEventListener;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler, WavAudioPlayerEventListener {

    private static final String METHOD_CHANNEL = "cymru.techiaith.flutter.macsen";

    private final static int PERMISSIONS_REQUEST_RECORD_AUDIO = 22;

    private WavAudioRecorder wavAudioRecorder;
    private WavAudioPlayer wavAudioPlayer;

    private MethodChannel wavplayer_channel;
    private MethodChannel wavrecorder_channel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        GeneratedPluginRegistrant.registerWith(this);

        wavrecorder_channel = new MethodChannel(getFlutterView(), METHOD_CHANNEL + "/wavrecorder");
        wavrecorder_channel.setMethodCallHandler(this);

        wavplayer_channel = new MethodChannel(getFlutterView(), METHOD_CHANNEL + "/wavplayer");
        wavplayer_channel.setMethodCallHandler(this);

        wavAudioRecorder = new WavAudioRecorder(this);
        wavAudioPlayer = new WavAudioPlayer(this);
        wavAudioPlayer.registerWavAudioPlayerEventListener(this);

    }

   @Override
   public void onMethodCall(MethodCall methodCall,
                            MethodChannel.Result result) {
        //
        if (methodCall.method.equals("checkMicrophonePermissions")){
            handleCheckMicrophonePermission(result);
        } else if (methodCall.method.equals("startRecording")){
            result.success(wavAudioRecorder.startRecord((String) methodCall.arguments) ? "OK" : "FAIL");
        } else if (methodCall.method.equals(("stopRecording"))) {
            result.success(wavAudioRecorder.stopRecord() ? wavAudioRecorder.getWavFile().getAbsolutePath() : "FAIL");
        } else if (methodCall.method.equals(("playRecording"))) {
            result.success(wavAudioPlayer.playAudio((String) methodCall.arguments) ? "OK" : "FAIL");
        } else if (methodCall.method.equals(("stopPlayingRecording"))) {
            result.success(wavAudioPlayer.stopPlaying() ? "OK" : "FAIL");
        } else {
            result.notImplemented();
        }
    }


    private void handleCheckMicrophonePermission(MethodChannel.Result result){
        boolean hasPermission = wavAudioRecorder.checkMicrophonePermissions();
        if (hasPermission) {
            result.success(true);
        }
        else {
            result.success(false);

            // request the permission
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.RECORD_AUDIO},
                    PERMISSIONS_REQUEST_RECORD_AUDIO);
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
            }
        }
    }

    public void onWavAudioPlayerCompletionEvent(String audioFilePath){
        wavplayer_channel.invokeMethod("audioPlayCompleted", audioFilePath);
    }

}
