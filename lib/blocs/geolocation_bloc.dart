import 'dart:async';

import 'package:rxdart/subjects.dart';

import 'package:macsen/blocs/BlocProvider.dart';
import 'package:macsen/blocs/application_state_provider.dart';

import 'package:geolocator/geolocator.dart';


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
    _requestLastKnownLocation();
  }


  Future<void> _requestLastKnownLocation() async {
    Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    if (position!=null) {
      print(position);
      _longitudeBehaviour.add(position.longitude);
      _latitudeBehaviour.add(position.latitude);
    }
  }

}