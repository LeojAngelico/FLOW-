import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flow/core/face_capture/face_capture.dart';
import 'package:flow/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// permission_handler is faked at its method channel, so these tests
// need no extra dependency. Status codes are the plugin's wire values:
// denied 0, granted 1, restricted 2, permanentlyDenied 4.
const MethodChannel _permissionChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

const int _denied = 0;
const int _permanentlyDenied = 4;
const int _cameraPermission = 1;

class _PermissionCalls {
  int requests = 0;
  int settingsOpened = 0;
}

_PermissionCalls _mockPermission({required int status}) {
  final calls = _PermissionCalls();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_permissionChannel, (call) async {
        switch (call.method) {
          case 'checkPermissionStatus':
            return status;
          case 'requestPermissions':
            calls.requests++;
            return <int, int>{_cameraPermission: status};
          case 'openAppSettings':
            calls.settingsOpened++;
            return true;
        }

        return null;
      });

  return calls;
}

class _CaptureHarness {
  bool hasResult = false;
  FaceCaptureResult? result;
}

/// A one-screen app whose button calls face capture exactly the way a
/// feature would, so the tests drive the real public entry point.
Widget _buildApp(_CaptureHarness harness) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final captured = await AppFaceCapture.capture(context);

                  harness
                    ..hasResult = true
                    ..result = captured;
                },
                child: const Text('open capture'),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppFaceCapture.routePath,
        builder: (context, state) => FaceCapturePage(
          config:
              state.extra as FaceCaptureConfig? ?? const FaceCaptureConfig(),
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

Future<void> _openCapture(WidgetTester tester, _CaptureHarness harness) async {
  await tester.pumpWidget(_buildApp(harness));
  await tester.tap(find.text('open capture'));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_permissionChannel, null);
  });

  // The live camera and ML Kit detection cannot run in a widget test —
  // both are platform code. These cover the paths that gate the
  // camera; readiness, orientation and auto-capture are covered by the
  // evaluator/tracker/projection tests, and the rest needs a device.
  group('FaceCapturePage — permission handling', () {
    testWidgets('asks for the camera when it can still be granted', (
      tester,
    ) async {
      final calls = _mockPermission(status: _denied);

      await _openCapture(tester, _CaptureHarness());

      expect(calls.requests, 1);

      // Never a blank camera screen: the user gets a way forward.
      expect(find.text('Camera access needed'), findsOneWidget);
      expect(find.text('Allow camera access'), findsOneWidget);
    });

    testWidgets('sends the user to Settings when the camera is blocked', (
      tester,
    ) async {
      final calls = _mockPermission(status: _permanentlyDenied);

      await _openCapture(tester, _CaptureHarness());

      expect(find.text('Allow camera access'), findsNothing);

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(calls.settingsOpened, 1);
      // Asking again would be pointless, so it never happened.
      expect(calls.requests, 0);
    });

    testWidgets('returns null when the user closes it', (tester) async {
      _mockPermission(status: _permanentlyDenied);

      final harness = _CaptureHarness();

      await _openCapture(tester, harness);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(harness.hasResult, isTrue);
      expect(harness.result, isNull);
      expect(find.byType(FaceCapturePage), findsNothing);
    });

    testWidgets('shows the configured title', (tester) async {
      _mockPermission(status: _permanentlyDenied);

      await tester.pumpWidget(_buildApp(_CaptureHarness()));

      // Push the route directly with a config, as AppFaceCapture does.
      final context = tester.element(find.text('open capture'));

      GoRouter.of(context).push<FaceCaptureResult>(
        AppFaceCapture.routePath,
        extra: const FaceCaptureConfig(title: 'Verify Account'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify Account'), findsOneWidget);
    });
  });
}
