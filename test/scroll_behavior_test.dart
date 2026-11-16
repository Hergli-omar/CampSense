import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campsense/core/theme/camp_sense_scroll_behavior.dart';

void main() {
  group('CampSenseScrollBehavior Tests', () {
    const scrollBehavior = CampSenseScrollBehavior();

    test('getScrollPhysics returns ClampingScrollPhysics', () {
      final physics = scrollBehavior.getScrollPhysics(
        // Dummy context not strictly needed by ClampingScrollPhysics
        _MockBuildContext(),
      );
      expect(physics, isA<ClampingScrollPhysics>());
    });

    testWidgets('buildOverscrollIndicator does not wrap child in StretchingOverscrollIndicator',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scrollBehavior: const CampSenseScrollBehavior(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                height: 2000,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure no StretchingOverscrollIndicator is in the widget tree
      expect(find.byType(StretchingOverscrollIndicator), findsNothing);

      // Perform a drag down past the top edge (overscroll gesture)
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
      await tester.pump();

      // Still no StretchingOverscrollIndicator present
      expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    });
  });
}

class _MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
