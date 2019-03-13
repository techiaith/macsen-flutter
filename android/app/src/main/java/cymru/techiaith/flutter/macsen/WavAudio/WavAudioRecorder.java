package cymru.techiaith.flutter.macsen.WavAudio;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.RandomAccessFile;

import androidx.core.content.ContextCompat;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;

import android.util.Log;

import cymru.techiaith.flutter.macsen.MainActivity;

public class WavAudioRecorder {

    private MainActivity _mainactivity;
    private AudioRecord _audiorecorder;

    //
    private boolean isRecording = false;

    private final static int sampleRate = 16000;
    private final static int channelConfig = AudioFormat.CHANNEL_IN_MONO;
    private final static int audioEncoding = AudioFormat.ENCODING_PCM_16BIT;
    private final static int WAV_HEADER_SIZE = 44;

    private int bufferSize = 0;
    private Thread recordingThread = null;

    short[] audioData;
    private File wavFile;


    public WavAudioRecorder(MainActivity activity){
        _mainactivity=activity;
    }

    public File getWavFile(){
        return wavFile;
    }

    //
    public boolean startRecord(final String filename){

        try {
            bufferSize  = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioEncoding);
            _audiorecorder = new AudioRecord(MediaRecorder.AudioSource.MIC,
                    sampleRate,
                    channelConfig,
                    audioEncoding,
                    bufferSize);

            //
            if (_audiorecorder.getState() == AudioRecord.STATE_INITIALIZED) {
                isRecording = true;
                _audiorecorder.startRecording();
                audioData = new short[bufferSize];
                recordingThread = new Thread(new Runnable() {
                    @Override
                    public void run() {
                        writeAudioDataToFile(filename);
                    }
                }, "AudioRecorder Thread");
                recordingThread.start();
            }
            else {
                return false;
            }

        }
        catch(final Exception e) {
            Log.e("WavAudioRecorder", "startRecord: " + e.getLocalizedMessage());
            return false;
        }

        return true;
    }

    //
    public boolean stopRecord(){

        if (null != _audiorecorder) {
            isRecording = false;

            _audiorecorder.stop();
            _audiorecorder.release();

            _audiorecorder = null;
            recordingThread = null;

            updateHeader();
            return true;
        }

        return false;

    }

    //
    private void writeAudioDataToFile(String filename) {

        byte data[] = new byte[bufferSize];
        Path filepathandname = Paths.get(this._mainactivity.getApplicationContext().getFilesDir().getPath(), filename + ".wav");

        this.wavFile = new File(filepathandname.toString());
        if (this.wavFile.exists())
            this.wavFile.delete();

        FileOutputStream fos = null;

        //
        try {
            this.wavFile.createNewFile();
            fos = new FileOutputStream(this.wavFile);
            fos.write(createHeader(0));
        } catch (Exception e) {
            Log.e("WavAudioRecorder","writeAudioDataToFile create: " + e.getLocalizedMessage());
        }

        //
        int read = 0;
        if (fos != null) {
            while (isRecording) {
                read = _audiorecorder.read(data, 0, bufferSize);
                if (AudioRecord.ERROR_INVALID_OPERATION != read) {
                    try {
                        fos.write(data);
                    } catch (IOException e) {
                        Log.e("WavAudioRecorder","writeAudioDataToFile writing data: " + e.getLocalizedMessage());
                    }
                }
            }
            try {
                fos.close();
            } catch (IOException e) {
                Log.e("WavAudioRecorder","writeAudioDataToFile closing: " + e.getLocalizedMessage());
            }
        }

    }

    private void updateHeader() {

        int dataBytesLength = (int)this.wavFile.length();
        byte[] updatedHeader = createHeader(dataBytesLength - WAV_HEADER_SIZE);

        try {
            RandomAccessFile ramFile = new RandomAccessFile(this.wavFile, "rw");
            ramFile.seek(0);
            ramFile.write(updatedHeader);
            ramFile.close();
        } catch (Exception e) {
            Log.e("WavAudioRecorder", "UpdateHeader : " + e.getLocalizedMessage());
        }
    }

    private byte[] createHeader(int bytesLength){
        //
        // http://www.topherlee.com/software/pcm-tut-wavformat.html
        //
        int totalLength = bytesLength + 36;

        byte[] lengthData = intToBytes(totalLength, 4);
        byte[] samplesLength = intToBytes(bytesLength, 4);
        byte[] sampleRateBytes = intToBytes(this.sampleRate, 4);
        byte[] bytesPerSecond = intToBytes(this.sampleRate * 2, 4);

        ByteArrayOutputStream header = new ByteArrayOutputStream(WAV_HEADER_SIZE);
        try {
            header.write(new byte[] {'R', 'I', 'F', 'F'});
            header.write(lengthData);
            header.write(new byte[] {'W', 'A', 'V', 'E'});
            header.write(new byte[] {'f', 'm', 't', ' '});
            header.write(new byte[] {0x10, 0x00, 0x00, 0x00}); // 16 bit chunks
            header.write(new byte[] {0x01, 0x00, 0x01, 0x00}); // mono
            header.write(sampleRateBytes);
            header.write(bytesPerSecond);
            header.write(new byte[] {0x02, 0x00, 0x10, 0x00}); // 2 bytes per sample
            header.write(new byte[] {'d', 'a', 't', 'a'});
            header.write(samplesLength);
        } catch (IOException e) {
            Log.e("WavAudioRecorder", e.getLocalizedMessage());
        }

        return header.toByteArray();

    }

    //
    private static byte[] intToBytes(int in, int length) {
        byte[] bytes = new byte[length];
        for (int i = 0; i < length; i++) {
            bytes[i] = (byte) ((in >>> i * 8) & 0xFF);
        }
        return bytes;
    }

}
