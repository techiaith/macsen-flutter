package cymru.techiaith.flutter.macsen.WavAudio;

import java.io.File;

import cymru.techiaith.flutter.macsen.MainActivity;
import android.media.MediaPlayer;

import android.net.Uri;
import android.content.Context;
import android.util.Log;

public class WavAudioPlayer {

    private MainActivity _mainactivity;
    private MediaPlayer _player;

    private Context _context;

    private Thread playingThread = null;


    public WavAudioPlayer(MainActivity activity){
        _mainactivity=activity;
        _context = _mainactivity.getApplicationContext();
        _player = null;
    }

    public boolean stopPlaying(){
        try{
            if (_player!=null && _player.isPlaying()){
                _player.stop();
                _player.release();

                _player = null;
                playingThread = null;
            }
        }
        catch (Exception e){
            Log.e("WavAudioPlayer", "playAudio stop previous " + e.getLocalizedMessage());
            return false;
        }
        return true;
    }


    public boolean playAudio(String audioFilePath){
        if (stopPlaying()){
            final File audiofile = new File(audioFilePath);
            if (audiofile.exists()){
                playingThread = new Thread(new Runnable() {
                    @Override
                    public void run() {
                        Uri uri = Uri.fromFile(audiofile);
                        _player = MediaPlayer.create(_context, uri);
//                        _player.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
//                            @Override
//                            public void onCompletion(MediaPlayer mp) {
//                                //_mainactivity.
//                            }
//                        });
                        _player.start();
                    }
                });
                playingThread.start();
            }
            else
                return false;
        } else {
            return false;
        }
        return true;
    }

}
