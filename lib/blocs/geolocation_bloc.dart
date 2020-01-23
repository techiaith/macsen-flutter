import 'dart:async';
import 'package:flutter/services.dart';

import 'dart:io' show Platform;

import 'package:rxdart/subjects.dart';

import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/application_state_provider.dart';

import 'package:geolocator/geolocator.dart';

const MethodChannel _native_geolocation_channel = const MethodChannel('cymru.techiaith.flutter.macsen/geolocation');

class GeolocationBloc implements BlocBase {

  ApplicationBloc applicationBloc;

  GeolocationStatus _geolocationStatus;

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

    _initialisePermissions();
  }


  Future<void> _initialisePermissions() async {
    _geolocationStatus = GeolocationStatus.denied;

    if (Platform.isIOS) {
      _geolocationStatus = await Geolocator().checkGeolocationPermissionStatus();
    }
    else if (Platform.isAndroid){
      try {
        _native_geolocation_channel.invokeMethod("checkLocationPermission");
      } on PlatformException catch (e) {
        print(e.message);
      }

    }

    if (_geolocationStatus==GeolocationStatus.granted)
      _requestLastKnownLocation();

  }


  Future<void> _requestLastKnownLocation() async {

    Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.low);
    if (position!=null) {
      print(position);
      _longitudeBehaviour.add(position.longitude);
      _latitudeBehaviour.add(position.latitude);
    }
  }


  Future<dynamic> _nativeCallbackHandler(MethodCall methodCall) async {
    if (methodCall.method == "geolocationPermission") {
      _onLocationCoordinates(methodCall.arguments);
    }
  }


  Future<void> _onLocationCoordinates(String result) async {

    if (result=="GRANTED")
      _geolocationStatus=GeolocationStatus.granted;

    if (_geolocationStatus==GeolocationStatus.granted)
      _requestLastKnownLocation();

  }


}