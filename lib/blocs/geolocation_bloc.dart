import 'dart:async';

import 'package:flutter/services.dart';

import 'package:rxdart/subjects.dart';

import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/application_state_provider.dart';


const MethodChannel _native_geolocation_channel = const MethodChannel('cymru.techiaith.flutter.macsen/geolocation');

class GeolocationBloc implements BlocBase {

  ApplicationBloc applicationBloc;


  // Stream
  final BehaviorSubject<double> _longitudeBehaviour = BehaviorSubject<double>();
  Stream<double> get longitude => _longitudeBehaviour.asBroadcastStream();

  final BehaviorSubject<double> _latitudeBehaviour = BehaviorSubject<double>();
  Stream<double> get latitude => _latitudeBehaviour.asBroadcastStream();


  void dispose(){
    _longitudeBehaviour.close();
    _latitudeBehaviour.close();
  }


  GeolocationBloc(ApplicationBloc parentBloc){
    applicationBloc = parentBloc;
    _native_geolocation_channel.setMethodCallHandler(_nativeCallbackHandler);
    _requestLastKnownLocation();
  }


  Future<bool> _requestLastKnownLocation() async {
    bool requestLastLocationAcknowledgeResult=true;
    try {
      requestLastLocationAcknowledgeResult = await _native_geolocation_channel.invokeMethod("requestLastLocation");
    }
    on PlatformException catch (e) {
      print(e.message);
      requestLastLocationAcknowledgeResult=false;
    }
    return requestLastLocationAcknowledgeResult;
  }


  Future<dynamic> _nativeCallbackHandler(MethodCall methodCall) async {
    if (methodCall.method == "locationCoordinates") {
      _onLocationCoordinates(methodCall.arguments);
    }
  }

  
  Future<void> _onLocationCoordinates(String coordinates) async {
    if (coordinates!=null){
      if (coordinates!="NOT_GRANTED" && coordinates!="NO_COORDINATES"){
        var longlat = coordinates.split("|");
        if (longlat.length == 2){
          _longitudeBehaviour.add(double.parse(longlat[0]));
          _latitudeBehaviour.add(double.parse(longlat[1]));
        }
      }
    }
  }


}