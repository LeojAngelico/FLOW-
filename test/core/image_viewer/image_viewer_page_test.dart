import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flow/core/image_viewer/image_viewer.dart';
import 'package:flow/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// A real 1x1 PNG, so images decode instead of falling through to the
/// error state.
final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42m'
  'P8z8DwHwAFAAH/q842iQAAAABJRU5ErkJggg==',
);

/// Bytes that are not an image — the simplest way to fail a load
/// without touching the network.
final Uint8List _corrupt = Uint8List.fromList([0, 1, 2, 3, 4, 5]);

AppImageSource _image({String? label}) {
  return AppImageSource.memory(_png, semanticLabel: label);
}

List<AppImageSource> _gallery(int count) {
  return [for (var i = 0; i < count; i++) _image(label: 'Photo ${i + 1}')];
}

class _Harness {
  bool returned = false;
}

/// A one-screen app whose button opens the viewer exactly the way a
/// feature would, so the tests drive the real public entry point.
Widget _buildApp(
  _Harness harness, {
  required List<AppImageSource> images,
  int initialIndex = 0,
  AppImageViewerConfig config = const AppImageViewerConfig(),
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
                  await AppImageViewer.showGallery(
                    context,
                    images,
                    initialIndex: initialIndex,
                    config: config,
                  );

                  harness.returned = true;
                },
                child: const Text('open viewer'),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppImageViewer.routePath,
        builder: (context, state) => ImageViewerPage(
          args:
              state.extra as AppImageViewerArgs? ??
              const AppImageViewerArgs(images: []),
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

/// Bounded pumps rather than `pumpAndSettle`: the loading indicator is
/// a continuous animation, so nothing ever "settles" while an image is
/// still decoding.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _open(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await tester.tap(find.text('open viewer'));
  await _settle(tester);
}

Future<void> _doubleTap(WidgetTester tester, Finder target) async {
  await tester.tap(target);
  await tester.pump(kDoubleTapMinTime);
  await tester.tap(target);
  await _settle(tester);
}

ScrollPhysics? _pagePhysics(WidgetTester tester) {
  return tester.widget<PageView>(find.byType(PageView)).physics;
}

void main() {
  group('single image', () {
    testWidgets('shows the image with no counter to show', (tester) async {
      await _open(tester, _buildApp(_Harness(), images: [_image()]));

      expect(find.byType(ZoomableImage), findsOneWidget);
      // A counter that always reads "1 / 1" is noise.
      expect(find.byType(ImageViewerCounter), findsNothing);
    });

    testWidgets('closes on the close button, returning to the caller', (
      tester,
    ) async {
      final harness = _Harness();

      await _open(tester, _buildApp(harness, images: [_image()]));

      await tester.tap(find.byIcon(Icons.close));
      await _settle(tester);

      expect(find.byType(ImageViewerPage), findsNothing);
      expect(find.text('open viewer'), findsOneWidget);
      expect(harness.returned, isTrue);
    });

    testWidgets('uses the caller label for accessibility', (tester) async {
      await _open(
        tester,
        _buildApp(_Harness(), images: [_image(label: 'A cat, sleeping')]),
      );

      expect(
        tester.widget<Image>(find.byType(Image)).semanticLabel,
        'A cat, sleeping',
      );
    });

    testWidgets('falls back to a generic label when none is given', (
      tester,
    ) async {
      await _open(tester, _buildApp(_Harness(), images: [_image()]));

      expect(tester.widget<Image>(find.byType(Image)).semanticLabel, 'Image');
    });
  });

  group('gallery', () {
    testWidgets('counts the images and opens on the first', (tester) async {
      await _open(tester, _buildApp(_Harness(), images: _gallery(3)));

      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('honours the initial index', (tester) async {
      await _open(
        tester,
        _buildApp(_Harness(), images: _gallery(5), initialIndex: 2),
      );

      expect(find.text('3 / 5'), findsOneWidget);
    });

    testWidgets('clamps an out-of-range initial index instead of crashing', (
      tester,
    ) async {
      await _open(
        tester,
        _buildApp(_Harness(), images: _gallery(3), initialIndex: 99),
      );

      expect(find.text('3 / 3'), findsOneWidget);

      await _open(
        tester,
        _buildApp(_Harness(), images: _gallery(3), initialIndex: -5),
      );

      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('swiping moves to the next image', (tester) async {
      await _open(tester, _buildApp(_Harness(), images: _gallery(3)));

      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await _settle(tester);

      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('keeps only nearby pages built', (tester) async {
      // Lazy paging is what stops a long gallery decoding every
      // full-resolution image at once.
      await _open(tester, _buildApp(_Harness(), images: _gallery(20)));

      expect(
        find.byType(ZoomableImage, skipOffstage: false).evaluate().length,
        lessThan(5),
      );
    });
  });

  group('zoom', () {
    testWidgets('pages freely at rest', (tester) async {
      await _open(tester, _buildApp(_Harness(), images: _gallery(3)));

      expect(_pagePhysics(tester), isA<PageScrollPhysics>());
    });

    testWidgets('double tap zooms in and suspends paging', (tester) async {
      await _open(tester, _buildApp(_Harness(), images: _gallery(3)));

      await _doubleTap(tester, find.byType(ZoomableImage).first);

      // While magnified, a horizontal drag has to pan the image rather
      // than fight the page.
      expect(_pagePhysics(tester), isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('a second double tap returns to fit and resumes paging', (
      tester,
    ) async {
      await _open(tester, _buildApp(_Harness(), images: _gallery(3)));

      final image = find.byType(ZoomableImage).first;

      await _doubleTap(tester, image);
      expect(_pagePhysics(tester), isA<NeverScrollableScrollPhysics>());

      await _doubleTap(tester, image);
      expect(_pagePhysics(tester), isA<PageScrollPhysics>());
    });

    testWidgets('changing page clears the previous zoom', (tester) async {
      await _open(tester, _buildApp(_Harness(), images: _gallery(3)));

      await _doubleTap(tester, find.byType(ZoomableImage).first);
      expect(_pagePhysics(tester), isA<NeverScrollableScrollPhysics>());

      // Paging is blocked by design while zoomed, so drive the
      // controller the way a "next" affordance would.
      final controller = tester
          .widget<PageView>(find.byType(PageView))
          .controller!;

      controller.jumpToPage(1);
      await _settle(tester);

      expect(find.text('2 / 3'), findsOneWidget);
      expect(_pagePhysics(tester), isA<PageScrollPhysics>());
    });
  });

  group('states', () {
    testWidgets('a failed image offers a retry, not a stack trace', (
      tester,
    ) async {
      // Real async so the decode actually fails and errorBuilder runs.
      await tester.runAsync(() async {
        await tester.pumpWidget(
          _buildApp(_Harness(), images: [AppImageSource.memory(_corrupt)]),
        );
        await tester.tap(find.text('open viewer'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        await Future<void>.delayed(const Duration(milliseconds: 100));
      });

      await tester.pump();

      expect(find.text('Unable to load image.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      // Closing must still work from the error state.
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('an empty list is refused rather than shown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );

      final context = tester.element(find.byType(SizedBox).first);

      // A black screen with a close button is worse than staying put,
      // and in debug an empty list is almost always a caller that
      // forgot to check — so it asserts rather than failing quietly.
      expect(
        () => AppImageViewer.showGallery(context, const []),
        throwsAssertionError,
      );

      expect(AppImageViewer.canShow(const []), isFalse);
      expect(AppImageViewer.canShow(null), isFalse);
      expect(AppImageViewer.canShow([_image()]), isTrue);
    });

    testWidgets('a directly built page with no images does not crash', (
      tester,
    ) async {
      // clamp(0, -1) is itself an error, so this used to throw in
      // initState before any guard could run.
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ImageViewerPage(args: AppImageViewerArgs(images: [])),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ZoomableImage), findsNothing);
    });
  });

  group('configuration', () {
    testWidgets('the counter and close button can be turned off', (
      tester,
    ) async {
      await _open(
        tester,
        _buildApp(
          _Harness(),
          images: _gallery(3),
          config: const AppImageViewerConfig(
            showCounter: false,
            showCloseButton: false,
          ),
        ),
      );

      expect(find.byType(ImageViewerCounter), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('a title and a caller action appear in the bar', (
      tester,
    ) async {
      final fired = <int>[];

      await _open(
        tester,
        _buildApp(
          _Harness(),
          images: _gallery(3),
          initialIndex: 1,
          config: AppImageViewerConfig(
            title: 'Evidence photos',
            actions: [
              AppImageViewerAction(
                icon: Icons.delete_outline,
                label: 'Delete photo',
                onPressed: (index, image) => fired.add(index),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Evidence photos'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await _settle(tester);

      // The action is told which image was on screen.
      expect(fired, [1]);
    });

    testWidgets('action labels are exposed to screen readers', (tester) async {
      await _open(
        tester,
        _buildApp(
          _Harness(),
          images: _gallery(2),
          config: AppImageViewerConfig(
            actions: [
              AppImageViewerAction(
                icon: Icons.delete_outline,
                label: 'Delete photo',
                onPressed: (_, _) {},
              ),
            ],
          ),
        ),
      );

      final button = find.ancestor(
        of: find.byIcon(Icons.delete_outline),
        matching: find.byType(IconButton),
      );

      expect(tester.widget<IconButton>(button).tooltip, 'Delete photo');
    });
  });
}
