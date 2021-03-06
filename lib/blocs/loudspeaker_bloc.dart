import 'dart:io';
import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:rxdart/subjects.dart';
import 'package:macsen/blocs/BlocProvider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:macsen/blocs/application_state_provider.dart';

//
// LoudspeakerBloc
//  Sinks:
//    - file url of stored wav file to play
//    - cancel playing
//    - reset queue of wavs
//
//  Streams:
//    - loudspeaker is quiet
//    - loudspeaker is active
//
//  - in, wav files to play.
//  - implements queue to coordinate playing one at a time
//  - deletes wav on device after playing
//  - (N.B. no means (yet) for use in streaming)
//

const MethodChannel _native_play_channel = const MethodChannel('cymru.techiaith.flutter.macsen/wavplayer');

enum BeepEnum { HiBeep, LoBeep}


class SoundFile {
  String wavFilePath;
  String text;
  String url;

  SoundFile(this.wavFilePath, this.text, this.url);
}


class LoudSpeakerBloc implements BlocBase {

  ApplicationBloc applicationBloc;

  String _audioHiBeepFilePath;
  String _audioLowBeepFilePath;

  bool _isLoudspeakerPlaying=false;
  Queue<SoundFile> _soundsQueue;

  // Sinks:
  final StreamController<BeepEnum> _playBeepController = StreamController<BeepEnum>();
  Sink<BeepEnum> get beep => _playBeepController.sink;

  final StreamController<SoundFile> _playSoundFileController = StreamController<SoundFile>();
  Sink<SoundFile> get play => _playSoundFileController.sink;

  final StreamController<bool> _stopPlayingController = StreamController<bool>();
  Sink<bool> get stop => _stopPlayingController.sink;

  final StreamController<bool> _resetQueueController = StreamController<bool>();
  Sink<bool> get reset => _resetQueueController.sink;


  // Streams
  final BehaviorSubject<SoundFile> _currentSoundBehavior = BehaviorSubject<SoundFile>();
  Stream<SoundFile> get currentSound => _currentSoundBehavior.asBroadcastStream();

  final BehaviorSubject<bool> _loudSpeakerPlayingBehaviour = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoudSpeakerPlaying => _loudSpeakerPlayingBehaviour.asBroadcastStream();

  final BehaviorSubject<BeepEnum> _beepCompletedBehaviour = BehaviorSubject<BeepEnum>();
  Stream<BeepEnum> get beepCompleted => _beepCompletedBehaviour.asBroadcastStream();

  final BehaviorSubject<bool> _soundsQueueCompletedBehaviour = BehaviorSubject<bool>();
  Stream<bool> get onCompletedPlayingAllSounds => _soundsQueueCompletedBehaviour.asBroadcastStream();


  void dispose(){
    _playBeepController.close();
    _playSoundFileController.close();
    _stopPlayingController.close();
    _resetQueueController.close();
    _soundsQueueCompletedBehaviour.close();
  }


  LoudSpeakerBloc(ApplicationBloc parentBloc){

    applicationBloc = parentBloc;
    _soundsQueue = new Queue<SoundFile>();

    //
    _loadAudio('beep_hi.wav').then((localtmpfile){
      _audioHiBeepFilePath = localtmpfile;
    });
    _loadAudio('beep_lo.wav').then((localtmpfile){
      _audioLowBeepFilePath = localtmpfile;
    });

    _playBeepController.stream.listen((beepenum){
      _onPlayBeep(beepenum);
    });

    _playSoundFileController.stream.listen((soundFile){
      _onPlayWavFile(soundFile);
    });

    _stopPlayingController.stream.listen((stopPlay){
      _onStopPlayWavFile();
    });

    _resetQueueController.stream.listen((reset){
      _onResetQueue();
    });

    //
    _native_play_channel.setMethodCallHandler(_nativeCallbackHandler);

  }


  Future<dynamic> _nativeCallbackHandler(MethodCall methodCall) async {
    if (methodCall.method == "audioPlayCompleted") {
      _onCompletedPlaying(methodCall.arguments);
    }
  }


  void _onCompletedPlaying(String wavfilePath){

    if ((wavfilePath==_audioHiBeepFilePath) || (wavfilePath==_audioLowBeepFilePath)) {
      _onBeepCompleted(wavfilePath);
    }
    else {
      File audioFile = new File(wavfilePath);
      audioFile.delete();

      _setLoudspeakerPlaying(false);
      _playNextInQueue();
    }
  }


  Future<void> _onPlayBeep(BeepEnum beep) async{
    if ((beep==BeepEnum.HiBeep) || (beep==BeepEnum.LoBeep)) {
      _loudSpeakerPlayingBehaviour.add(true);
      String beepFilePath;

      if (beep == BeepEnum.HiBeep)
        beepFilePath=_audioHiBeepFilePath;
      else if (beep == BeepEnum.LoBeep)
        beepFilePath=_audioLowBeepFilePath;

      if (beepFilePath?.isNotEmpty ?? true){
        await _native_play_channel.invokeMethod('playRecording', <String, dynamic>{
          "filepath":beepFilePath
        });
      }

    }
  }


  Future<void> _onBeepCompleted(String beepWavFile) async {
    if (beepWavFile==_audioHiBeepFilePath)
      _beepCompletedBehaviour.add(BeepEnum.HiBeep);
    else if (beepWavFile==_audioLowBeepFilePath)
      _beepCompletedBehaviour.add(BeepEnum.LoBeep);
    _loudSpeakerPlayingBehaviour.add(false);
  }


  void _onPlayWavFile(SoundFile soundFile){
    if (soundFile.wavFilePath.length > 0) {
      _soundsQueue.add(soundFile);
      _playNextInQueue();
    }
  }


  Future<void> _playNextInQueue() async {
    if (_soundsQueue.length > 0){
      if (_isLoudspeakerPlaying==false){
        _setLoudspeakerPlaying(true);
        SoundFile nextSoundfile=_soundsQueue.removeFirst();
        await _native_play_channel.invokeMethod(
            'playRecording',
            <String, dynamic>{
                "filepath":nextSoundfile.wavFilePath
            });
        _currentSoundBehavior.add(nextSoundfile);
      }
    } else {
      print ("Completed playing all sounds");
      _soundsQueueCompletedBehaviour.add(true);
    }
  }

  void _setLoudspeakerPlaying(bool isPlaying){
    _isLoudspeakerPlaying=isPlaying;
    _loudSpeakerPlayingBehaviour.add(isPlaying);
  }


  void _onResetQueue(){
    _soundsQueue.clear();
    _isLoudspeakerPlaying=false;
  }


  void _onStopPlayWavFile(){
    _native_play_channel.invokeMethod('stopPlayingRecording');
  }


  Future<String> _loadAudio(String assetFilename) async {
    final file = new File('${(await getTemporaryDirectory()).path}/' + assetFilename);
    await file.writeAsBytes((await _loadAudioAsset(assetFilename)).buffer.asUint8List());
    return file.path;
  }


  Future<ByteData> _loadAudioAsset(String filename) async {
    return await rootBundle.load('assets/audio/' + filename);
  }


}
