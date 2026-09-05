import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/quick_add_chip.dart';
import 'package:flow/core/design/components/stepper_button.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/time/clock.dart';
import 'package:flow/core/time/clock_provider.dart';
import 'package:flow/features/hydration/data/providers/hydration_data_providers.dart';
import 'package:flow/features/hydration/domain/models/daily_hydration.dart';
import 'package:flow/features/hydration/domain/models/hydration_entry.dart';
import 'package:flow/features/hydration/domain/models/logged_water.dart';
import 'package:flow/features/hydration/domain/repositories/hydration_repository.dart';
import 'package:flow/features/hydration/presentation/add_water/add_water_page.dart';

import '../../../../support/pump_flow_widget.dart';

/// Stands in for `HydrationRepositoryImpl`. Nothing in this file calls
/// `submit()`, so `logWater` is never expected to be invoked — it is
/// implemented only so `addWaterProvider`'s dependency graph
/// (`logWaterProvider` -> `hydrationRepositoryProvider`) has something
/// to resolve to if a test ever exercises that path.
class _FakeHydrationRepository implements HydrationRepository {
  @override
  Stream<DailyHydration?> watchDailyHydration(String localDate) =>
      const Stream.empty();

  @override
  Stream<List<HydrationEntry>> watchEntries(String localDate) =>
      const Stream.empty();

  @override
  Future<int> readActiveTargetMl() async => 2000;

  @override
  Future<Result<LoggedWater>> logWater({
    required String id,
    required int amountMl,
    required DateTime occurredAt,
    required String localDate,
    required HydrationSource source,
  }) async {
    return Result.ok(
      LoggedWater(
        amountMl: amountMl,
        newTotalMl: amountMl,
        goalJustCompleted: false,
      ),
    );
  }
}

void main() {
  Future<void> pumpAddWaterPage(WidgetTester tester) async {
    await pumpFlowWidget(
      tester,
      const AddWaterPage(),
      overrides: [
        hydrationRepositoryProvider.overrideWithValue(
          _FakeHydrationRepository(),
        ),
        clockProvider.overrideWithValue(FixedClock(DateTime(2026, 1, 1, 12))),
      ],
    );
  }

  Finder incrementStepperFinder() => find.byWidgetPredicate(
    (widget) =>
        widget is StepperButton && widget.direction == StepDirection.increment,
  );

  Finder quickAddChipFinder(int amountMl) => find.byWidgetPredicate(
    (widget) => widget is QuickAddChip && widget.amountMl == amountMl,
  );

  group('the amount field\'s numeric-only configuration (Decisions #42)', () {
    testWidgets('wires TextInputType.number and a digits-only formatter to the '
        'underlying TextField, not just to FlowTextField\'s constructor', (
      tester,
    ) async {
      await pumpAddWaterPage(tester);

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.keyboardType, TextInputType.number);
      expect(
        textField.inputFormatters,
        contains(FilteringTextInputFormatter.digitsOnly),
      );
    });

    testWidgets(
      'typing a non-digit character does not clamp the amount to 0 and '
      'wipe the field (the bug fixed in Decisions #42)',
      (tester) async {
        await pumpAddWaterPage(tester);

        // Get the field to a known non-zero value first, the same way a
        // real user would before typing a stray character mid-entry.
        await tester.tap(incrementStepperFinder());
        await tester.pump();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          '50',
        );

        // Simulate the IME reporting the field's full new content after
        // the user typed a letter in the middle of "50" -- exactly the
        // input that previously reached `int.tryParse`, failed, and
        // collapsed the amount (and therefore the displayed text) to
        // nothing.
        await tester.enterText(find.byType(TextField), '5a0');
        await tester.pump();

        final text = tester
            .widget<TextField>(find.byType(TextField))
            .controller!
            .text;
        expect(text, isNot(isEmpty));
        expect(text, '50');
      },
    );

    testWidgets('a purely numeric entry still updates the field normally', (
      tester,
    ) async {
      await pumpAddWaterPage(tester);

      await tester.enterText(find.byType(TextField), '750');
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '750',
      );
    });
  });

  group('the field mirrors the notifier\'s amount (controller sync)', () {
    testWidgets(
      'tapping the increment stepper updates the field\'s displayed text',
      (tester) async {
        await pumpAddWaterPage(tester);

        await tester.tap(incrementStepperFinder());
        await tester.pump();

        expect(find.text('50'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a value-setting quick-amount chip updates the field\'s '
      'displayed text to the chosen amount',
      (tester) async {
        await pumpAddWaterPage(tester);

        await tester.tap(quickAddChipFinder(250));
        await tester.pump();

        expect(find.text('250'), findsOneWidget);
      },
    );
  });
}
