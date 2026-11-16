import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:light/light.dart';

/// Ambient light sensor service wrapping the `light` package.
/// Exposes a stream of lux readings (`Stream<double>`) with error and unavailability handling.
class LightSensorService {
  final Light _light;
  StreamSubscription<int>? _subscription;
  final StreamController<double> _luxController =
      StreamController<double>.broadcast();

  bool _isAvailable = true;
  bool _hasStarted = false;

  LightSensorService([Light? light]) : _light = light ?? Light();

  /// Whether the ambient light sensor is available on this device.
  bool get isAvailable => _isAvailable;

  /// Continuous broadcast stream of ambient light readings in lux.
  Stream<double> get luxStream {
    if (!_hasStarted) {
      _startListening();
    }
    return _luxController.stream;
  }

  void _startListening() {
    _hasStarted = true;
    try {
      _subscription = _light.lightSensorStream.listen(
        (luxValue) {
          _isAvailable = true;
          _luxController.add(luxValue.toDouble());
        },
        onError: (error) {
          if (kDebugMode) {
            debugPrint('Light sensor stream error: $error');
          }
          _isAvailable = false;
          _luxController.addError(error);
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Light sensor unavailable: $e');
      }
      _isAvailable = false;
      _luxController.addError(e);
    }
  }

  /// Cancels subscriptions and closes streams.
  void dispose() {
    _subscription?.cancel();
    _luxController.close();
  }
}
