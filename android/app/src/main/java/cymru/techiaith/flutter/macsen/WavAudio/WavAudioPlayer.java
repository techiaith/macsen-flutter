package cymru.techiaith.flutter.macsen.WavAudio;

import java.io.File;

import cymru.techiaith.flutter.macsen.MainActivity;
import android.media.MediaPlayer;

import android.net.Uri;
import android.content.Context;
import android.util.Log;


public class WavAudioPlayer {

    private MediaPlayer _player;
    private Context _context;
    private WavAudioPlayerEventListener _wavAudioEventListener;
    private Thread playingThread = null;

    public WavAudioPlayer(MainActivity activity){
        _context = activity.getApplicationContext();
        _player = null;
    }

    public void registerWavAudioPlayerEventListener(WavAudioPlayerEventListener listener){
        _wavAudioEventListener=listener;
    }


    public boolean stopPlaying(){
        try{
            if (_player!=null) {
                if (_player.isPlaying()) {

                    _player.stop();
                    _player.reset();
                    _player.release();

                    _player = null;
                    playingThread = null;

                }
            }
        }
        catch (Exception e){
            Log.e("WavAudioPlayer", "playAudio stop previous " + e.getMessage() + "\n" + e.getStackTrace());
            return false;
        }

        return true;

    }


    public boolean playAudio(final String audioFilePath){
        if (stopPlaying()){
            final File audiofile = new File(audioFilePath);
            if (audiofile.exists()){
                playingThread = new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            Uri uri = Uri.fromFile(audiofile);
                            _player = MediaPlayer.create(_context, uri);
                            _player.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                                @Override
                                public void onCompletion(MediaPlayer mp) {
                                    _player.stop();
                                    _player.reset();
                                    _player.release();
                                    _player = null;

                                    _wavAudioEventListener.onWavAudioPlayerCompletionEvent(audioFilePath);
                                }
                            });
                            _player.start();
                        } catch (Exception e){
                            Log.e("WavAudioPlayer", "playAudio " + e.getMessage() + "\n" + e.getStackTrace());
                        }
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
