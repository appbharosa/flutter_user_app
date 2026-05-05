import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

/// EVENTS
abstract class GpsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartTracking extends GpsEvent {}

class StopTracking extends GpsEvent {}

class _LocationUpdate extends GpsEvent {
  final Position position;
  _LocationUpdate(this.position);

  @override
  List<Object?> get props => [position];
}

/// STATES
abstract class GpsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GpsInitial extends GpsState {}

class GpsTracking extends GpsState {
  final double distanceMeters;
  final double lat;
  final double lon;

  GpsTracking({
    required this.distanceMeters,
    required this.lat,
    required this.lon,
  });

  @override
  List<Object?> get props => [distanceMeters, lat, lon];
}

class GpsError extends GpsState {
  final String message;
  GpsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// BLOC
class GpsBloc extends Bloc<GpsEvent, GpsState> {
  StreamSubscription<Position>? _positionSub;

  Position? _lastPosition;
  double _totalDistance = 0;

  GpsBloc() : super(GpsInitial()) {
    on<StartTracking>(_onStart);
    on<StopTracking>(_onStop);
    on<_LocationUpdate>(_onUpdate);
  }

  Future<void> _onStart(
      StartTracking event,
      Emitter<GpsState> emit,
      ) async {
    try {
      /// Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        emit(GpsError("Location permission denied"));
        return;
      }

      /// Reset
      _totalDistance = 0;
      _lastPosition = null;

      /// Start stream
      _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 3, // 🔥 reduces noise
        ),
      ).listen((position) {
        add(_LocationUpdate(position));
      });

    } catch (e) {
      emit(GpsError(e.toString()));
    }
  }

  void _onUpdate(
      _LocationUpdate event,
      Emitter<GpsState> emit,
      ) {
    final current = event.position;

    /// Debug
    print("📍 LAT: ${current.latitude}, LON: ${current.longitude}");
    print("🎯 Accuracy: ${current.accuracy}");

    /// ❌ Ignore bad accuracy (>20 meters)
    if (current.accuracy > 20) {
      print("⚠️ Ignored due to low accuracy");
      return;
    }

    if (_lastPosition != null) {
      double distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        current.latitude,
        current.longitude,
      );

      /// ❌ Ignore small noise (< 3 meters)
      if (distance < 3) {
        print("⚠️ Ignored noise: $distance m");
        return;
      }

      _totalDistance += distance;
    }

    _lastPosition = current;

    emit(GpsTracking(
      distanceMeters: _totalDistance,
      lat: current.latitude,
      lon: current.longitude,
    ));
  }
  Future<void> _onStop(
      StopTracking event,
      Emitter<GpsState> emit,
      ) async {
    await _positionSub?.cancel();
    emit(GpsInitial());
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    return super.close();
  }
}