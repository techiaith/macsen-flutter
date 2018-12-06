import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:rxdart/subjects.dart';
import 'package:macsen/bloc/BlocProvider.dart';

class SpeechToTextBloc implements BlocBase {

  // in
  final StreamController<String> _newSpeechRecordingController = StreamController<String>();
  Sink<String> get onNewSpeechRecording => _newSpeechRecordingController.sink;

  // out
  final BehaviorSubject<String> _transcription = BehaviorSubject<String>(seedValue: '');
  Stream<String> get transcription => _transcription.stream;

  //
  SpeechToTextBloc() {
    _newSpeechRecordingController.stream.listen((filename) {
      performSTT(filename);
    });
  }


  //
  void dispose() {
    _newSpeechRecordingController.close();
    _transcription.close();
  }


  //
  Future<void> performSTT(String recordedFilePath) async {

    // send to server ! :)
    var url = "http://macsen-stt.techiaith.cymru/dsserver/handleaudio/";

    File uploadFile = new File(recordedFilePath);
    int length = uploadFile.lengthSync();
    Stream uploadStream = uploadFile.openRead();

    try {
      HttpClient client = new HttpClient();
      HttpClientRequest request = await client.postUrl(Uri.parse(url));

      request.headers.contentLength=length;
      request.headers.contentType=ContentType.binary;
      await request.addStream(uploadStream);

      HttpClientResponse response = await request.close();

      if (response.statusCode==200) {
        StringBuffer sb = new StringBuffer();
        await for (String a in response.transform(utf8.decoder)){
          sb.write(a);
        }
        _transcription.value = sb.toString();
      }
    } on Exception catch (e) {
      _transcription.value = '';
      print (e);
    }

  }

}
