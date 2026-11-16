import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/strings.dart';
import '../services/light_sensor_service.dart';

/// Available user preferences for theme selection.
enum ThemePreference {
  auto,
  light,
  dark,
}

/// Pure, testable hysteresis and moving-average logic for ambient light theme decisions.
///
/// Hysteresis rule:
/// - Dark if smoothed lux < 40
/// - Light if smoothed lux > 120
/// - Preserves current brightness when between 40 and 120
class AutoThemeDecider {
  static const double darkThreshold = 40.0;
  static const double lightThreshold = 120.0;

  final int windowSize;
  final List<double> _history = [];
  Brightness _currentBrightness;

  AutoThemeDecider({
    this.windowSize = 5,
    Brightness initialBrightness = Brightness.light,
  }) : _currentBrightness = initialBrightness;

  Brightness get currentBrightness => _currentBrightness;

  /// Returns the current moving average of recorded lux readings.
  double get smoothedLux {
    if (_history.isEmpty) return 150.0;
    final sum = _history.reduce((a, b) => a + b);
    return sum / _history.length;
  }

  /// Feeds a new lux value, computes moving average, applies hysteresis,
  /// and returns the decided [Brightness].
  Brightness processLux(double lux) {
    _history.add(lux);
    if (_history.length > windowSize) {
      _history.removeAt(0);
    }

    final avg = smoothedLux;
    if (avg < darkThreshold) {
      _currentBrightness = Brightness.dark;
    } else if (avg > lightThreshold) {
      _currentBrightness = Brightness.light;
    }
    // Between darkThreshold (40) and lightThreshold (120): retain _currentBrightness (hysteresis)

    return _currentBrightness;
  }

  /// Categorizes lux reading into standard French environmental light levels.
  static String getLuxCategory(double lux) {
    if (lux > 10000) {
      return AppStrings.luxFullSun;
    } else if (lux > 1000) {
      return AppStrings.luxBright;
    } else if (lux > 120) {
      return AppStrings.luxShade;
    } else if (lux > 10) {
      return AppStrings.luxLowLight;
    } else {
      return AppStrings.luxDarkness;
    }
  }

  /// Clears moving average history and resets brightness.
  void reset([Brightness initialBrightness = Brightness.light]) {
    _history.clear();
    _currentBrightness = initialBrightness;
  }
}

/// Provider managing application theme, ambient light sensor subscription,
/// debounce, moving-average hysteresis, and debug simulation.
class ThemeProvider with ChangeNotifier {
  static const String _keyThemePref = 'cs_theme_mode_preference';

  final LightSensorService _sensorService;
  final AutoThemeDecider _decider = AutoThemeDecider();

  ThemePreference _preference = ThemePreference.auto;
  Brightness _activeBrightness = Brightness.light;
  double _currentLux = 200.0;
  bool _isSensorAvailable = true;

  // Debug simulation mode
  bool _isSimulationEnabled = false;
  double _simulatedLux = 200.0;

  StreamSubscription<double>? _sensorSubscription;
  Timer? _debounceTimer;

  ThemeProvider({LightSensorService? sensorService})
      : _sensorService = sensorService ?? LightSensorService() {
    _init();
  }

  ThemePreference get preference => _preference;
  Brightness get activeBrightness => _activeBrightness;
  ThemeMode get themeMode {
    switch (_preference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.auto:
        return _activeBrightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light;
    }
  }

  double get currentLux => _isSimulationEnabled ? _simulatedLux : _currentLux;
  String get luxCategory => AutoThemeDecider.getLuxCategory(currentLux);
  bool get isSensorAvailable => _isSensorAvailable;
  bool get isSimulationEnabled => _isSimulationEnabled;
  double get simulatedLux => _simulatedLux;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPref = prefs.getString(_keyThemePref);
    if (savedPref != null) {
      _preference = ThemePreference.values.firstWhere(
        (e) => e.name == savedPref,
        orElse: () => ThemePreference.auto,
      );
    }

    _subscribeToSensor();
  }

  void _subscribeToSensor() {
    _sensorSubscription?.cancel();
    _sensorSubscription = _sensorService.luxStream.listen(
      (lux) {
        if (_isSimulationEnabled) return;
        _isSensorAvailable = true;
        _currentLux = lux;
        _onLuxUpdated(lux);
      },
      onError: (err) {
        _isSensorAvailable = false;
        if (_preference == ThemePreference.auto) {
          // Fallback to manual mode without crashing
          _preference = ThemePreference.light;
        }
        notifyListeners();
      },
    );
  }

  /// Debounces lux readings (~1 second) to prevent flickering when transitioning.
  void _onLuxUpdated(double lux) {
    if (_preference != ThemePreference.auto) {
      notifyListeners();
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 900), () {
      final newBrightness = _decider.processLux(lux);
      if (newBrightness != _activeBrightness) {
        _activeBrightness = newBrightness;
        notifyListeners();
      } else {
        notifyListeners(); // Update lux display
      }
    });
  }

  /// Changes the user's theme preference and persists to SharedPreferences.
  Future<void> setPreference(ThemePreference pref) async {
    _preference = pref;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemePref, pref.name);

    if (pref == ThemePreference.auto) {
      _decider.reset(_activeBrightness);
      _onLuxUpdated(currentLux);
    } else {
      _activeBrightness =
          pref == ThemePreference.dark ? Brightness.dark : Brightness.light;
    }
    notifyListeners();
  }

  /// Toggles debug simulation mode (available in debug builds).
  void toggleSimulation(bool enabled) {
    _isSimulationEnabled = enabled;
    if (enabled) {
      _onLuxUpdated(_simulatedLux);
    } else {
      _onLuxUpdated(_currentLux);
    }
    notifyListeners();
  }

  /// Sets simulated lux value from debug slider.
  void setSimulatedLux(double lux) {
    _simulatedLux = lux;
    if (_isSimulationEnabled) {
      _onLuxUpdated(lux);
    }
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _debounceTimer?.cancel();
    _sensorService.dispose();
    super.dispose();
  }
}
