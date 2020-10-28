import 'dart:async';
import 'dart:collection';

import 'package:macsen/apis/TextToSpeech.dart';
import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/application_state_provider.dart';
import 'package:macsen/blocs/loudspeaker_bloc.dart';
import 'package:rxdart/subjects.dart';
import 'package:url_launcher/url_launcher.dart';

//
// TextToSpeechBloc
//  Sinks:
//    - texts that need uttering
//  Stream:
//    - file url of wav file with tts result
//
//  - receives texts that need to be uttered
//  - uses MaryTTS cloud API to convert to wav
//  - file url of wav to play.
//

class TextToSpeechText {
  String originalText;
  String locallyAdaptedText;
  String url;
  bool autoOpenURL;

  TextToSpeechText(String originalText, String locallyAdaptedText, String url,
      bool autoOpenURL) {
    this.originalText = originalText;
    if (locallyAdaptedText == '')
      this.locallyAdaptedText = this.originalText;
    else
      this.locallyAdaptedText = locallyAdaptedText;
    this.url = url;
    this.autoOpenURL = autoOpenURL;
  }
}

class TextToSpeechBloc implements BlocBase {
  ApplicationBloc _applicationBloc;
  TextToSpeech _ttsApi;

  bool _isWaitingForTts = false;
  bool _playTtsResult = true;

  Queue<TextToSpeechText> _ttsQueue;

  // Sinks
  final StreamController<TextToSpeechText> _ttsQueueController =
      StreamController<TextToSpeechText>();
  Sink<TextToSpeechText> get queue => _ttsQueueController.sink;

  final StreamController<bool> _speakQueueController = StreamController<bool>();
  Sink<bool> get speakQueue => _speakQueueController.sink;

  final StreamController<bool> _resetQueueController = StreamController<bool>();
  Sink<bool> get reset => _resetQueueController.sink;

  // Streams
  final BehaviorSubject<SoundFile> _ttsResultBehaviour =
      BehaviorSubject<SoundFile>();
  Stream<SoundFile> get ttsResult => _ttsResultBehaviour.asBroadcastStream();

  void dispose() {
    _resetQueueController.close();
    _ttsQueueController.close();
    _speakQueueController.close();
  }

  TextToSpeechBloc(ApplicationBloc parentBloc) {
    _applicationBloc = parentBloc;

    _ttsApi = new TextToSpeech();
    _ttsQueue = new Queue<TextToSpeechText>();

    _ttsQueueController.stream.listen((ttsText) {
      _playTtsResult = true;
      _ttsQueue.add(ttsText);
    });

    _speakQueueController.stream.listen((start) {
      _playTtsResult = true;
      _processNextInTtsQueue();
    });

    _resetQueueController.stream.listen((reset) {
      _ttsQueue.clear();
      _playTtsResult = false;
      _isWaitingForTts = false;
    });
  }

  Future<void> _processNextInTtsQueue() async {
    if (_ttsQueue.length > 0) {
      if (_isWaitingForTts == false) {
        _isWaitingForTts = true;
        TextToSpeechText nextTextToSpeechText = _ttsQueue.removeFirst();
        await _ttsApi
            .speak(nextTextToSpeechText.locallyAdaptedText)
            .then((wavfile) {
          if (_playTtsResult) {
            SoundFile soundFile = new SoundFile(wavfile,
                nextTextToSpeechText.originalText, nextTextToSpeechText.url);
            _ttsResultBehaviour.add(soundFile);
          }
          _isWaitingForTts = false;
          if (nextTextToSpeechText.autoOpenURL) {
            _launchUrl(nextTextToSpeechText.url);
          }
          _processNextInTtsQueue();
        });
      }
    }
  }
}

Future<void> _launchUrl(String url) async {
  if (await canLaunch(url)) {
    await Future.delayed(const Duration(seconds: 5));
    await launch(url);
  } else {
    throw 'Methu agor y dudalen we';
  }
}
