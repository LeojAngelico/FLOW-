import 'package:flutter/material.dart';
import 'package:flow/core/signature_pad/signature_pad.dart';
import 'package:flow/core/ui_kit/ui_kit.dart';
import 'package:flow/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _Harness {
  bool returned = false;
  SignatureResult? result;
}

/// A one-screen app whose button opens the pad exactly the way a
/// feature would, so the tests drive the real public entry point.
Widget _buildApp(
  _Harness harness, {
  SignaturePadConfig config = const SignaturePadConfig(),
}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final signature = await AppSignaturePad.show(
                    context,
                    config: config,
                  );

                  harness
                    ..returned = true
                    ..result = signature;
                },
                child: const Text('open pad'),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppSignaturePad.routePath,
        builder: (context, state) => SignaturePadPage(
          config: state.extra as SignaturePadConfig? ?? config,
        ),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

Future<void> _open(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await tester.tap(find.text('open pad'));
  await tester.pumpAndSettle();
}

/// Draws across the signing area, which is what a real signature does
/// and a stray tap does not.
Future<void> _sign(WidgetTester tester) async {
  await tester.drag(find.byType(SignatureCanvas), const Offset(120, 40));
  await tester.pumpAndSettle();
}

AppButton _button(WidgetTester tester, String label) {
  return tester.widget<AppButton>(
    find.ancestor(of: find.text(label), matching: find.byType(AppButton)),
  );
}

void main() {
  group('empty pad', () {
    testWidgets('shows the instruction, hint and both actions', (tester) async {
      await _open(tester, _buildApp(_Harness()));

      expect(find.text('Sign your signature below'), findsOneWidget);
      expect(find.text('Sign here'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);
    });

    testWidgets('disables both actions until there is ink', (tester) async {
      await _open(tester, _buildApp(_Harness()));

      expect(_button(tester, 'Complete').onPressed, isNull);
      expect(_button(tester, 'Clear').onPressed, isNull);
    });

    testWidgets('a stray tap does not enable Complete', (tester) async {
      await _open(tester, _buildApp(_Harness()));

      await tester.tap(find.byType(SignatureCanvas));
      await tester.pumpAndSettle();

      // There is a mark, so clearing is worth offering — but this is
      // not a signature.
      expect(_button(tester, 'Complete').onPressed, isNull);
      expect(_button(tester, 'Clear').onPressed, isNotNull);
    });
  });

  group('drawing', () {
    testWidgets('enables Complete and hides the hint', (tester) async {
      await _open(tester, _buildApp(_Harness()));

      await _sign(tester);

      expect(_button(tester, 'Complete').onPressed, isNotNull);
      expect(_button(tester, 'Clear').onPressed, isNotNull);
      expect(find.text('Sign here'), findsNothing);
    });

    testWidgets('Clear returns the pad to its initial state', (tester) async {
      await _open(tester, _buildApp(_Harness()));

      await _sign(tester);

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(_button(tester, 'Complete').onPressed, isNull);
      expect(_button(tester, 'Clear').onPressed, isNull);
      // The empty-state hint comes back.
      expect(find.text('Sign here'), findsOneWidget);
    });

    testWidgets('clearing asks for no confirmation', (tester) async {
      await _open(tester, _buildApp(_Harness()));

      await _sign(tester);
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Repeatable and reversible, so a dialog would only be in the way.
      expect(find.text('Discard signature?'), findsNothing);
    });
  });

  group('complete', () {
    testWidgets('returns a transparent PNG and closes', (tester) async {
      final harness = _Harness();

      await _open(tester, _buildApp(harness));
      await _sign(tester);

      // Real async: exporting rasterises a picture.
      await tester.runAsync(() async {
        await tester.tap(find.text('Complete'));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      await tester.pumpAndSettle();

      expect(harness.returned, isTrue);
      expect(harness.result, isNotNull);
      expect(harness.result!.bytes, isNotEmpty);
      expect(harness.result!.width, greaterThan(0));
      expect(find.byType(SignaturePadPage), findsNothing);
    });

    testWidgets('the result keeps the signature out of its toString', (
      tester,
    ) async {
      final harness = _Harness();

      await _open(tester, _buildApp(harness));
      await _sign(tester);

      await tester.runAsync(() async {
        await tester.tap(find.text('Complete'));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      await tester.pumpAndSettle();

      // A signature is not something to drop into a log line.
      expect(harness.result.toString(), isNot(contains('bytes')));
      expect(harness.result.toString(), contains('PNG'));
    });
  });

  group('cancellation', () {
    testWidgets('closing an empty pad returns null without asking', (
      tester,
    ) async {
      final harness = _Harness();

      await _open(tester, _buildApp(harness));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(harness.returned, isTrue);
      expect(harness.result, isNull);
      expect(find.byType(SignaturePadPage), findsNothing);
    });

    testWidgets('closing a signed pad asks before discarding it', (
      tester,
    ) async {
      final harness = _Harness();

      await _open(tester, _buildApp(harness));
      await _sign(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Discard signature?'), findsOneWidget);

      // Cancelling the dialog keeps the signature.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(SignaturePadPage), findsOneWidget);
      expect(_button(tester, 'Complete').onPressed, isNotNull);
      expect(harness.returned, isFalse);

      // Confirming discards it and returns nothing.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.byType(SignaturePadPage), findsNothing);
      expect(harness.returned, isTrue);
      expect(harness.result, isNull);
    });

    testWidgets('system back goes through the same confirmation', (
      tester,
    ) async {
      await _open(tester, _buildApp(_Harness()));
      await _sign(tester);

      // Android back and the iOS swipe both end in maybePop, which is
      // what consults PopScope.
      final context = tester.element(find.byType(SignaturePadPage));

      await Navigator.of(context).maybePop();
      await tester.pumpAndSettle();

      expect(find.text('Discard signature?'), findsOneWidget);
    });

    testWidgets('the confirmation can be turned off', (tester) async {
      final harness = _Harness();

      await _open(
        tester,
        _buildApp(
          harness,
          config: const SignaturePadConfig(confirmDiscard: false),
        ),
      );
      await _sign(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Discard signature?'), findsNothing);
      expect(harness.result, isNull);
      expect(find.byType(SignaturePadPage), findsNothing);
    });
  });

  group('configuration', () {
    testWidgets('copy can be replaced', (tester) async {
      await _open(
        tester,
        _buildApp(
          _Harness(),
          config: const SignaturePadConfig(
            title: 'Sign the delivery receipt',
            hint: 'Your signature',
            clearLabel: 'Start over',
            completeLabel: 'Confirm',
          ),
        ),
      );

      expect(find.text('Sign the delivery receipt'), findsOneWidget);
      expect(find.text('Your signature'), findsOneWidget);
      expect(find.text('Start over'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('the hint can be hidden entirely', (tester) async {
      await _open(
        tester,
        _buildApp(_Harness(), config: const SignaturePadConfig(hint: '')),
      );

      expect(find.text('Sign here'), findsNothing);
    });
  });

  group('accessibility', () {
    testWidgets('the close button and signing area are labelled', (
      tester,
    ) async {
      await _open(tester, _buildApp(_Harness()));

      expect(
        tester
            .widget<IconButton>(
              find.ancestor(
                of: find.byIcon(Icons.close),
                matching: find.byType(IconButton),
              ),
            )
            .tooltip,
        'Close signature pad',
      );

      expect(find.bySemanticsLabel('Signature drawing area'), findsOneWidget);
    });
  });
}
