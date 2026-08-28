import 'package:flutter/material.dart';
import 'package:flow/core/face_capture/detection/face_capture_assessment.dart';
import 'package:flow/core/face_capture/face_capture_config.dart';
import 'package:flow/core/face_capture/face_capture_localizer.dart';
import 'package:flow/app/locale/unsupported_locale_fallback_delegates.dart';
import 'package:flow/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a localized app and hands the context to [body].
Future<void> withContext(
  WidgetTester tester,
  Locale locale,
  void Function(BuildContext context) body,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      // Cebuano has no Material/Cupertino translations upstream, so
      // the app's fallback delegates are part of a correct setup —
      // see app.dart.
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        CebFallbackMaterialLocalizationsDelegate(),
        CebFallbackCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          body(context);

          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

void main() {
  // Every locale the app ships, because a guidance string that only
  // exists in English would leave a blank instruction on screen for
  // everyone else.
  const locales = [Locale('en'), Locale('fil'), Locale('ceb')];

  group('FaceCaptureLocalizer', () {
    for (final locale in locales) {
      testWidgets('resolves every enum value in ${locale.languageCode}', (
        tester,
      ) async {
        await withContext(tester, locale, (context) {
          for (final guidance in FaceCaptureGuidance.values) {
            expect(
              FaceCaptureLocalizer.guidance(context, guidance),
              isNotEmpty,
              reason: 'guidance ${guidance.name}',
            );
          }

          for (final label in FaceReadinessLabel.values) {
            expect(
              FaceCaptureLocalizer.readiness(context, label),
              isNotEmpty,
              reason: 'readiness ${label.name}',
            );
          }

          for (final orientation in FaceOrientation.values) {
            expect(
              FaceCaptureLocalizer.orientation(context, orientation),
              isNotEmpty,
              reason: 'orientation ${orientation.name}',
            );
          }

          for (final check in FaceCaptureCheck.values) {
            expect(
              FaceCaptureLocalizer.checkLabel(context, check),
              isNotEmpty,
              reason: 'check ${check.name}',
            );

            for (final status in FaceCheckStatus.values) {
              expect(
                FaceCaptureLocalizer.checkValue(context, check, status),
                isNotEmpty,
                reason: 'check ${check.name} / ${status.name}',
              );
            }
          }
        });
      });
    }

    testWidgets('uses plain language, never detector internals', (
      tester,
    ) async {
      await withContext(tester, const Locale('en'), (context) {
        expect(
          FaceCaptureLocalizer.guidance(context, FaceCaptureGuidance.turnLeft),
          'Turn your head to your left',
        );

        // The user is told about the *face*, not about yaw, euler
        // angles, probabilities or bounding boxes.
        for (final guidance in FaceCaptureGuidance.values) {
          final text = FaceCaptureLocalizer.guidance(
            context,
            guidance,
          ).toLowerCase();

          for (final jargon in ['yaw', 'euler', 'probab', 'bounding']) {
            expect(text.contains(jargon), isFalse, reason: guidance.name);
          }
        }
      });
    });
  });
}
