import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flow/core/face_capture/face_capture.dart';
import 'package:flow/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// A real 1x1 PNG, so completed slots decode an actual image rather
/// than falling through to the error placeholder.
const String _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42m'
    'P8z8DwHwAFAAH/q842iQAAAABJRU5ErkJggg==';

late Directory _tempDir;
late String _imagePath;

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  setUpAll(() async {
    _tempDir = await Directory.systemTemp.createTemp('face_capture_test');
    _imagePath = '${_tempDir.path}/face.png';

    await File(_imagePath).writeAsBytes(base64Decode(_pngBase64));
  });

  tearDownAll(() async {
    await _tempDir.delete(recursive: true);
  });

  group('FaceCaptureReviewView', () {
    testWidgets('shows a slot per capture position with its state', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FaceCaptureReviewView(
            slots: [
              FaceCaptureReviewSlot(
                orientation: FaceOrientation.left,
                imagePath: _imagePath,
              ),
              const FaceCaptureReviewSlot(orientation: FaceOrientation.front),
              const FaceCaptureReviewSlot(
                orientation: FaceOrientation.right,
                isRequired: false,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);

      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);

      // Only the captured slot carries the success badge.
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      // The two empty slots show the placeholder avatar.
      expect(find.byIcon(Icons.person), findsNWidgets(2));
    });

    testWidgets('renders the default copy and tips', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FaceCaptureReviewView(
            slots: [FaceCaptureReviewSlot(orientation: FaceOrientation.front)],
          ),
        ),
      );

      expect(find.text('Take your selfie'), findsOneWidget);
      expect(find.text('Make sure to use a bright photo'), findsOneWidget);
      expect(find.text('Tips for a good photo'), findsOneWidget);
      expect(find.text('Use a well-lit area'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('an empty tips list hides the card', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FaceCaptureReviewView(
            slots: [FaceCaptureReviewSlot(orientation: FaceOrientation.front)],
            tips: [],
          ),
        ),
      );

      expect(find.text('Tips for a good photo'), findsNothing);
    });

    testWidgets('tapping a slot reports which position was tapped', (
      tester,
    ) async {
      final tapped = <FaceOrientation>[];

      await tester.pumpWidget(
        _wrap(
          FaceCaptureReviewView(
            slots: const [
              FaceCaptureReviewSlot(orientation: FaceOrientation.left),
              FaceCaptureReviewSlot(orientation: FaceOrientation.front),
            ],
            onSlotTapped: tapped.add,
          ),
        ),
      );

      await tester.tap(find.text('Left'));
      await tester.pumpAndSettle();

      expect(tapped, [FaceOrientation.left]);
    });

    testWidgets('the primary action is disabled until the caller enables it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const FaceCaptureReviewView(
            slots: [FaceCaptureReviewSlot(orientation: FaceOrientation.front)],
          ),
        ),
      );

      final disabled = tester.widget<FilledButton>(find.byType(FilledButton));

      expect(disabled.onPressed, isNull);

      var continued = false;

      await tester.pumpWidget(
        _wrap(
          FaceCaptureReviewView(
            slots: const [
              FaceCaptureReviewSlot(orientation: FaceOrientation.front),
            ],
            onContinue: () => continued = true,
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(continued, isTrue);
    });

    testWidgets('the retake action only appears when offered', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FaceCaptureReviewView(
            slots: [FaceCaptureReviewSlot(orientation: FaceOrientation.front)],
          ),
        ),
      );

      expect(find.text('Retake'), findsNothing);

      var retaken = false;

      await tester.pumpWidget(
        _wrap(
          FaceCaptureReviewView(
            slots: const [
              FaceCaptureReviewSlot(orientation: FaceOrientation.front),
            ],
            onRetake: () => retaken = true,
          ),
        ),
      );

      await tester.tap(find.text('Retake'));
      await tester.pumpAndSettle();

      expect(retaken, isTrue);
    });

    testWidgets('a missing image file falls back to the placeholder', (
      tester,
    ) async {
      // Real async, so the failing file read actually completes and
      // the error builder gets its turn.
      await tester.runAsync(() async {
        await tester.pumpWidget(
          _wrap(
            const FaceCaptureReviewView(
              slots: [
                FaceCaptureReviewSlot(
                  orientation: FaceOrientation.front,
                  imagePath: '/does/not/exist.png',
                ),
              ],
            ),
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 100));
      });

      await tester.pump();

      // Temp files can vanish; the review screen must not go down
      // with them.
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });
  });

  group('allRequiredCompleted', () {
    test('ignores optional slots', () {
      expect(
        FaceCaptureReviewView.allRequiredCompleted(const [
          FaceCaptureReviewSlot(
            orientation: FaceOrientation.front,
            imagePath: 'a.png',
          ),
          FaceCaptureReviewSlot(
            orientation: FaceOrientation.left,
            isRequired: false,
          ),
        ]),
        isTrue,
      );
    });

    test('is false while a required slot is empty', () {
      expect(
        FaceCaptureReviewView.allRequiredCompleted(const [
          FaceCaptureReviewSlot(
            orientation: FaceOrientation.front,
            imagePath: 'a.png',
          ),
          FaceCaptureReviewSlot(orientation: FaceOrientation.left),
        ]),
        isFalse,
      );
    });
  });
}
