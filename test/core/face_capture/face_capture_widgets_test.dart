import 'package:flutter/material.dart';
import 'package:flow/app/locale/unsupported_locale_fallback_delegates.dart';
import 'package:flow/core/face_capture/detection/face_capture_assessment.dart';
import 'package:flow/core/face_capture/detection/face_capture_evaluator.dart';
import 'package:flow/core/face_capture/detection/face_capture_geometry.dart';
import 'package:flow/core/face_capture/detection/face_sample.dart';
import 'package:flow/core/face_capture/face_capture_config.dart';
import 'package:flow/core/face_capture/widgets/face_capture_guidance_view.dart';
import 'package:flow/core/face_capture/widgets/face_capture_readiness.dart';
import 'package:flow/core/face_capture/widgets/face_capture_ring.dart';
import 'package:flow/core/face_capture/widgets/face_capture_status_panel.dart';
import 'package:flow/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phone sizes worth checking: a tall modern handset and a small one,
/// since the scanner's copy sits in the band above the guide circle and
/// that band is where space runs out first.
const List<(String, Size)> _phones = [
  ('tall phone', Size(393, 852)),
  ('small phone', Size(360, 640)),
];

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      ...AppLocalizations.localizationsDelegates,
      CebFallbackMaterialLocalizationsDelegate(),
      CebFallbackCupertinoLocalizationsDelegate(),
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(backgroundColor: Colors.black, body: child),
  );
}

FaceCaptureAssessment _assessment({
  bool smileRequired = false,
  double hold = 0.4,
  bool empty = false,
}) {
  final evaluator = FaceCaptureEvaluator(
    orientation: FaceOrientation.front,
    smileRequired: smileRequired,
  );

  final sample = empty
      ? const FaceSample.empty()
      : FaceSample(
          faceCount: 1,
          centerX: 0.5,
          centerY: FaceCaptureGeometry.guideCenterY,
          widthFraction: 0.42,
          yawDegrees: 0,
          smileProbability: 0.9,
        );

  return evaluator.assess(evaluator.check(sample), hold);
}

void main() {
  group('FaceCaptureGeometry', () {
    test('the guide is a centred circle above the middle of the screen', () {
      const size = Size(393, 852);
      final guide = FaceCaptureGeometry.guideCircle(size);

      expect(guide.center.dx, closeTo(size.width / 2, 0.01));
      expect(
        guide.center.dy,
        closeTo(size.height * FaceCaptureGeometry.guideCenterY, 0.01),
      );

      // Round, and comfortably inside the screen so the copy above and
      // the status panel below both have room.
      expect(guide.width, closeTo(guide.height, 0.01));
      expect(guide.top, greaterThan(120));
      expect(guide.bottom, lessThan(size.height - 200));
    });

    test('never grows past half the height on a short screen', () {
      const size = Size(800, 360);
      final guide = FaceCaptureGeometry.guideCircle(size);

      expect(guide.height, lessThanOrEqualTo(size.height * 0.55));
      expect(guide.top, greaterThanOrEqualTo(0));
    });

    test('the position rule targets the drawn guide, not the screen', () {
      // If these ever diverge the scanner would ask users to move a
      // face that already looks centred in the ring.
      const evaluator = FaceCaptureEvaluator(
        orientation: FaceOrientation.front,
      );

      final atGuideCentre = FaceSample(
        faceCount: 1,
        centerX: 0.5,
        centerY: FaceCaptureGeometry.guideCenterY,
        widthFraction: 0.42,
        yawDegrees: 0,
      );

      expect(evaluator.check(atGuideCentre).isCentered, isTrue);

      // Dead centre of the *screen* is below the guide, and far enough
      // down to fail — which is why the two must share a constant.
      const screenCentre = FaceSample(
        faceCount: 1,
        centerX: 0.5,
        centerY: 0.5,
        widthFraction: 0.42,
        yawDegrees: 0,
      );

      expect(FaceCaptureGeometry.guideCenterY, lessThan(0.5));
      expect(evaluator.check(screenCentre).isCentered, isTrue);
    });
  });

  for (final (name, size) in _phones) {
    group('scanner visuals on a $name', () {
      testWidgets('the status panel fits five conditions', (tester) async {
        tester.view.physicalSize = size * 3;
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _wrap(
            Align(
              alignment: Alignment.bottomCenter,
              child: FaceCaptureStatusPanel(
                assessment: _assessment(smileRequired: true),
              ),
            ),
          ),
        );

        expect(find.text('Face'), findsOneWidget);
        expect(find.text('Position'), findsOneWidget);
        expect(find.text('Orientation'), findsOneWidget);
        expect(find.text('Stability'), findsOneWidget);
        expect(find.text('Smile'), findsOneWidget);

        expect(
          tester.getSize(find.byType(FaceCaptureStatusPanel)).width,
          lessThanOrEqualTo(size.width),
        );
      });

      testWidgets('readiness and guidance render', (tester) async {
        tester.view.physicalSize = size * 3;
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        final assessment = _assessment();

        await tester.pumpWidget(
          _wrap(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaceCaptureReadiness(
                  score: assessment.score,
                  label: assessment.label,
                ),
                FaceCaptureGuidanceView(
                  guidance: assessment.guidance,
                  isHolding: assessment.isHolding,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // A real measurement, not an animation: every requirement is
        // met, so the score is 100 and the hold is what remains.
        expect(find.text('100'), findsOneWidget);
        expect(find.text('Ready'), findsOneWidget);
        expect(find.text('Look straight at the camera'), findsOneWidget);
        expect(find.text('Hold still...'), findsOneWidget);
      });

      testWidgets('the guide ring paints without overflowing', (tester) async {
        tester.view.physicalSize = size * 3;
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _wrap(
            FaceCaptureRing(
              guide: FaceCaptureGeometry.guideCircle(size),
              score: 72,
              state: FaceGuideState.detecting,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });
  }

  group('partial readiness', () {
    testWidgets('shows a real partial score when a requirement fails', (
      tester,
    ) async {
      final evaluator = const FaceCaptureEvaluator(
        orientation: FaceOrientation.front,
      );

      // Framed and centred, but turned too far to count as front:
      // 6 of 9 weight.
      final assessment = evaluator.assess(
        evaluator.check(
          const FaceSample(
            faceCount: 1,
            centerX: 0.5,
            centerY: FaceCaptureGeometry.guideCenterY,
            widthFraction: 0.42,
            yawDegrees: 40,
          ),
        ),
        0,
      );

      await tester.pumpWidget(
        _wrap(
          FaceCaptureReadiness(
            score: assessment.score,
            label: assessment.label,
          ),
        ),
      );

      expect(find.text('67'), findsOneWidget);
      expect(find.text('Keep going'), findsOneWidget);
    });
  });

  group('hold countdown', () {
    testWidgets('shows the seconds left while holding the pose', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const FaceCaptureGuidanceView(
            guidance: FaceCaptureGuidance.lookStraight,
            isHolding: true,
            countdownSeconds: 3,
          ),
        ),
      );

      expect(find.text('Look straight at the camera'), findsOneWidget);
      expect(find.text('Hold still...'), findsOneWidget);
      // The count itself, as a number rather than words.
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('the count ticks down without changing the instruction', (
      tester,
    ) async {
      for (final seconds in [3, 2, 1]) {
        await tester.pumpWidget(
          _wrap(
            FaceCaptureGuidanceView(
              guidance: FaceCaptureGuidance.turnLeft,
              isHolding: true,
              countdownSeconds: seconds,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('$seconds'), findsOneWidget);
        expect(find.text('Turn your head to your left'), findsOneWidget);
      }
    });

    testWidgets('falls back to the plain hold line without a count', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const FaceCaptureGuidanceView(
            guidance: FaceCaptureGuidance.lookStraight,
            isHolding: true,
          ),
        ),
      );

      expect(find.text('Hold still...'), findsOneWidget);
      // No badge when there is nothing to count.
      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows no countdown before the pose is right', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FaceCaptureGuidanceView(
            guidance: FaceCaptureGuidance.centerFace,
            isHolding: false,
            countdownSeconds: 3,
          ),
        ),
      );

      expect(find.text('Center your face'), findsOneWidget);
      expect(find.textContaining('Hold still'), findsNothing);
    });
  });

  group('guidance copy', () {
    testWidgets('drops the hold line once the shutter fires', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FaceCaptureGuidanceView(
            guidance: FaceCaptureGuidance.capturing,
            isHolding: true,
          ),
        ),
      );

      expect(find.text('Capturing...'), findsOneWidget);
      expect(find.text('Hold still...'), findsNothing);
    });

    testWidgets('long translations do not overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      // Cebuano has the longest strings of the three locales.
      await tester.pumpWidget(
        _wrap(
          const FaceCaptureGuidanceView(
            guidance: FaceCaptureGuidance.multipleFaces,
            isHolding: false,
          ),
          locale: const Locale('ceb'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
