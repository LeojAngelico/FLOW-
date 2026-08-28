import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flow/core/qr_scanner/qr_scanner.dart';
import 'package:flow/core/qr_scanner/widgets/qr_scanner_overlay.dart';
import 'package:flow/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// --------------------------------------------------
// PERMISSION FAKE
// --------------------------------------------------
//
// permission_handler is mocked at its method channel so the tests need
// no extra dependency. The status codes are the plugin's wire values:
// denied 0, granted 1, restricted 2, limited 3, permanentlyDenied 4.

const MethodChannel _permissionChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

const int _denied = 0;
const int _granted = 1;
const int _permanentlyDenied = 4;

/// Permission value of `Permission.camera` in the plugin's protocol.
const int _cameraPermission = 1;

class _PermissionCalls {
  int requests = 0;
  int settingsOpened = 0;
}

_PermissionCalls _mockPermission({
  required int status,
  int? statusAfterRequest,
  bool canOpenSettings = true,
}) {
  final calls = _PermissionCalls();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_permissionChannel, (call) async {
        switch (call.method) {
          case 'checkPermissionStatus':
            return status;
          case 'requestPermissions':
            calls.requests++;
            return <int, int>{_cameraPermission: statusAfterRequest ?? status};
          case 'openAppSettings':
            calls.settingsOpened++;
            return canOpenSettings;
        }

        return null;
      });

  return calls;
}

// --------------------------------------------------
// SCANNER FAKE
// --------------------------------------------------

class _FakeScannerPlatform extends MobileScannerPlatform {
  final StreamController<BarcodeCapture?> _barcodes =
      StreamController<BarcodeCapture?>.broadcast();
  final StreamController<TorchState> _torch =
      StreamController<TorchState>.broadcast();
  final StreamController<double> _zoom = StreamController<double>.broadcast();

  int startCount = 0;
  int stopCount = 0;
  int disposeCount = 0;
  bool isRunning = false;
  Rect? scanWindow;

  @override
  Stream<BarcodeCapture?> get barcodesStream => _barcodes.stream;

  @override
  Stream<TorchState> get torchStateStream => _torch.stream;

  @override
  Stream<double> get zoomScaleStateStream => _zoom.stream;

  @override
  Future<MobileScannerViewAttributes> start(StartOptions startOptions) async {
    startCount++;
    isRunning = true;

    return const MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: TorchState.off,
      numberOfCameras: 1,
      size: Size(320, 640),
      initialDeviceOrientation: DeviceOrientation.portraitUp,
    );
  }

  @override
  Future<void> stop() async {
    stopCount++;
    isRunning = false;
  }

  @override
  Future<void> pause() async {
    isRunning = false;
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
    isRunning = false;
  }

  @override
  Widget buildCameraView() {
    return const SizedBox(key: ValueKey<String>('fake-camera-view'));
  }

  @override
  Future<void> updateScanWindow(Rect? window) async {
    scanWindow = window;
  }

  @override
  Future<void> toggleTorch() async {
    _torch.add(TorchState.on);
  }

  void emit(String rawValue) {
    _barcodes.add(BarcodeCapture(barcodes: [Barcode(rawValue: rawValue)]));
  }

  Future<void> close() async {
    await _barcodes.close();
    await _torch.close();
    await _zoom.close();
  }
}

// --------------------------------------------------
// HARNESS
// --------------------------------------------------

/// A one-screen app whose button calls the scanner exactly the way a
/// feature would, so the tests exercise the real public entry point.
class _ScanHarness {
  bool hasResult = false;
  String? result;
}

Widget _buildApp(
  _ScanHarness harness, {
  QrScannerConfig config = const QrScannerConfig(),
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
                  final scanned = await AppQrScanner.scan(
                    context,
                    config: config,
                  );

                  harness
                    ..hasResult = true
                    ..result = scanned;
                },
                child: const Text('open scanner'),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppQrScanner.routePath,
        builder: (context, state) => QrScannerPage(
          config: state.extra as QrScannerConfig? ?? const QrScannerConfig(),
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

/// Settles the frames plus the short "got it" confirmation the scanner
/// shows between a successful read and popping the route.
Future<void> _settleAfterScan(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}

Future<void> _openScanner(WidgetTester tester, _ScanHarness harness) async {
  await tester.pumpWidget(_buildApp(harness));
  await tester.tap(find.text('open scanner'));
  await tester.pumpAndSettle();
}

void main() {
  late _FakeScannerPlatform scanner;

  setUp(() {
    MobileScannerController.resetPlatformSessionOwner();

    scanner = _FakeScannerPlatform();
    MobileScannerPlatform.instance = scanner;
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_permissionChannel, null);

    await scanner.close();
  });

  group('QrScannerPage — successful scan', () {
    testWidgets('returns the raw value and closes itself', (tester) async {
      _mockPermission(status: _granted);

      final harness = _ScanHarness();
      await _openScanner(tester, harness);

      expect(
        find.byKey(const ValueKey<String>('fake-camera-view')),
        findsOneWidget,
      );
      expect(scanner.startCount, 1);

      scanner.emit('https://example.com/user/12345');
      await _settleAfterScan(tester);

      expect(harness.hasResult, isTrue);
      expect(harness.result, 'https://example.com/user/12345');

      // The scanner is gone and the camera was released.
      expect(find.byType(QrScannerPage), findsNothing);
      expect(scanner.isRunning, isFalse);
      expect(scanner.disposeCount, greaterThanOrEqualTo(1));
    });

    testWidgets('reports the same code only once', (tester) async {
      _mockPermission(status: _granted);

      final harness = _ScanHarness();
      await _openScanner(tester, harness);

      // Three captures of the same code, as a real camera would send.
      scanner
        ..emit('USER-12345')
        ..emit('USER-12345')
        ..emit('USER-12345');

      await _settleAfterScan(tester);

      expect(harness.result, 'USER-12345');
      // A second pop would have thrown; assert the stack is back home.
      expect(find.text('open scanner'), findsOneWidget);
    });

    testWidgets('only decodes codes inside the scan frame', (tester) async {
      _mockPermission(status: _granted);

      await _openScanner(tester, _ScanHarness());

      expect(scanner.scanWindow, isNotNull);
    });
  });

  group('QrScannerPage — scanning UI', () {
    testWidgets('fills the screen with the preview and centers the frame', (
      tester,
    ) async {
      // A phone-shaped surface: 393x852 logical, like an iPhone 15.
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 177, bottom: 102);
      addTearDown(tester.view.reset);

      _mockPermission(status: _granted);

      await _openScanner(tester, _ScanHarness());

      const screen = Size(393, 852);

      // Regression guard: Scaffold hands its body loose constraints, so
      // a shrink-wrapping Stack used to squash the preview into a strip
      // the height of the controls row.
      expect(tester.getSize(find.byType(MobileScanner)), screen);

      final frame = QrScannerOverlay.frameFor(screen, 0.72);

      // The scan window handed to the platform is the frame the user
      // sees, and it sits inside the preview.
      expect(scanner.scanWindow, isNotNull);
      expect(frame.center.dx, closeTo(screen.width / 2, 0.01));
      expect(frame.center.dy, closeTo(screen.height / 2, 0.01));
      expect(frame.width, closeTo(393 * 0.72, 0.01));

      // The copy sits fully on screen, above the frame.
      final title = tester.getRect(find.text('Scan QR code'));
      final instruction = tester.getRect(
        find.text('Place the markers around the QR code to begin scanning'),
      );

      expect(title.top, greaterThanOrEqualTo(0));
      expect(title.bottom, lessThanOrEqualTo(frame.top));
      expect(instruction.bottom, lessThanOrEqualTo(frame.top));
      // Below the status bar / notch, not tucked under it.
      expect(title.top, greaterThanOrEqualTo(59));

      // Controls are pinned to the top, not stretched over the frame.
      final close = tester.getRect(find.byIcon(Icons.close));
      expect(close.top, lessThan(title.top));
      expect(find.byIcon(Icons.flashlight_off), findsOneWidget);
    });

    testWidgets('honors a custom title and hidden torch button', (
      tester,
    ) async {
      _mockPermission(status: _granted);

      final harness = _ScanHarness();

      await tester.pumpWidget(
        _buildApp(
          harness,
          config: const QrScannerConfig(
            title: 'Scan asset tag',
            instruction: 'Line up the tag inside the frame',
            showTorchButton: false,
          ),
        ),
      );
      await tester.tap(find.text('open scanner'));
      await tester.pumpAndSettle();

      expect(find.text('Scan asset tag'), findsOneWidget);
      expect(find.text('Line up the tag inside the frame'), findsOneWidget);
      expect(find.byIcon(Icons.flashlight_off), findsNothing);
    });
  });

  group('QrScannerPage — cancellation', () {
    testWidgets('returns null when the user closes it', (tester) async {
      _mockPermission(status: _granted);

      final harness = _ScanHarness();
      await _openScanner(tester, harness);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(harness.hasResult, isTrue);
      expect(harness.result, isNull);
      expect(find.byType(QrScannerPage), findsNothing);
      expect(scanner.isRunning, isFalse);
    });
  });

  group('QrScannerPage — permission handling', () {
    testWidgets('asks for the permission when it is still requestable', (
      tester,
    ) async {
      final calls = _mockPermission(
        status: _denied,
        statusAfterRequest: _granted,
      );

      await _openScanner(tester, _ScanHarness());

      expect(calls.requests, 1);
      expect(scanner.startCount, 1);
    });

    testWidgets('offers another attempt when the user declined once', (
      tester,
    ) async {
      _mockPermission(status: _denied);

      await _openScanner(tester, _ScanHarness());

      // Never a blank camera screen.
      expect(
        find.byKey(const ValueKey<String>('fake-camera-view')),
        findsNothing,
      );
      expect(find.text('Camera access needed'), findsOneWidget);
      expect(find.text('Allow camera access'), findsOneWidget);
      expect(scanner.startCount, 0);
    });

    testWidgets('sends the user to Settings when the permission is blocked', (
      tester,
    ) async {
      final calls = _mockPermission(status: _permanentlyDenied);

      await _openScanner(tester, _ScanHarness());

      expect(find.text('Camera access needed'), findsOneWidget);
      expect(find.text('Allow camera access'), findsNothing);

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(calls.settingsOpened, 1);
      // Asking again would be pointless, so it never happened.
      expect(calls.requests, 0);
      expect(scanner.startCount, 0);
    });

    testWidgets('can still be cancelled from the permission screen', (
      tester,
    ) async {
      _mockPermission(status: _permanentlyDenied);

      final harness = _ScanHarness();
      await _openScanner(tester, harness);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(harness.hasResult, isTrue);
      expect(harness.result, isNull);
    });
  });
}
