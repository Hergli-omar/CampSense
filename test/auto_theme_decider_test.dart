import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campsense/core/constants/strings.dart';
import 'package:campsense/features/user/providers/theme_provider.dart';

void main() {
  group('AutoThemeDecider hysteresis & thresholds tests', () {
    late AutoThemeDecider decider;

    setUp(() {
      // Use window size of 3 for deterministic unit testing
      decider = AutoThemeDecider(
        windowSize: 3,
        initialBrightness: Brightness.light,
      );
    });

    test('initial brightness defaults to light', () {
      expect(decider.currentBrightness, Brightness.light);
    });

    test('switches to dark when smoothed lux falls below darkThreshold (40 lx)', () {
      // Feed values < 40
      decider.processLux(30.0);
      decider.processLux(20.0);
      final result = decider.processLux(10.0);

      expect(result, Brightness.dark);
      expect(decider.currentBrightness, Brightness.dark);
    });

    test('switches to light when smoothed lux rises above lightThreshold (120 lx)', () {
      // First make it dark
      decider.processLux(10.0);
      decider.processLux(10.0);
      decider.processLux(10.0);
      expect(decider.currentBrightness, Brightness.dark);

      // Now feed bright sunlight values > 120
      decider.processLux(200.0);
      decider.processLux(300.0);
      final result = decider.processLux(250.0);

      expect(result, Brightness.light);
      expect(decider.currentBrightness, Brightness.light);
    });

    test('hysteresis retains current brightness between 40 lx and 120 lx', () {
      // 1. Start from Light: a value of 80 lx must REMAIN Light
      decider.reset(Brightness.light);
      decider.processLux(80.0);
      decider.processLux(80.0);
      expect(decider.processLux(80.0), Brightness.light,
          reason: 'Between 40 and 120, previously light should remain light');

      // 2. Transition into Dark (< 40)
      decider.processLux(15.0);
      decider.processLux(15.0);
      decider.processLux(15.0);
      expect(decider.currentBrightness, Brightness.dark);

      // 3. Now in Dark: a value of 80 lx must REMAIN Dark (hysteresis!)
      decider.processLux(80.0);
      decider.processLux(80.0);
      expect(decider.processLux(80.0), Brightness.dark,
          reason: 'Between 40 and 120, previously dark should remain dark');
    });

    test('moving average smooths out temporary spikes', () {
      decider.reset(Brightness.light);
      // Window size 3: [1000, 1000, 1000] -> avg = 1000
      decider.processLux(1000.0);
      decider.processLux(1000.0);
      decider.processLux(1000.0);

      // Single temporary dip to 0 lx (e.g. hand briefly covers sensor)
      // Buffer becomes: [1000, 1000, 0] -> average = 666.6 lx > 120 lx -> remains Light!
      final decision = decider.processLux(0.0);
      expect(decision, Brightness.light);
    });

    test('getLuxCategory classifies ambient brightness in French correctly', () {
      expect(AutoThemeDecider.getLuxCategory(12000), AppStrings.luxFullSun);
      expect(AutoThemeDecider.getLuxCategory(2500), AppStrings.luxBright);
      expect(AutoThemeDecider.getLuxCategory(250), AppStrings.luxShade);
      expect(AutoThemeDecider.getLuxCategory(25), AppStrings.luxLowLight);
      expect(AutoThemeDecider.getLuxCategory(5), AppStrings.luxDarkness);
      expect(AutoThemeDecider.getLuxCategory(0), AppStrings.luxDarkness);
    });
  });
}
