import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/environment/app_environment.dart';
import '../../core/face_capture/face_capture.dart';
import '../../core/image_viewer/image_viewer.dart';
import '../../core/qr_scanner/qr_scanner.dart';
import '../../core/signature_pad/signature_pad.dart';
import '../../core/ui_kit/playground/ui_playground_page.dart';

import '../../features/auth/presentation/login/login_page.dart';
import '../../features/auth/presentation/registration/registration_page.dart';
import '../../features/auth/presentation/profile/profile_page.dart';
import '../../features/auth/presentation/session/auth_session_notifier.dart';
import '../../features/auth/presentation/session/auth_session_state.dart';
import '../../features/auth/presentation/splash/splash_page.dart';

import '../../features/home/presentation/home_page.dart';

import '../main_shell.dart';
import 'router_refresh_notifier.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerRefresh = RouterRefreshNotifier();

  // Rebuild GoRouter's redirect logic whenever
  // authentication state changes.
  ref.listen<AuthSessionState>(authSessionNotifierProvider, (previous, next) {
    routerRefresh.refresh();
  });

  ref.onDispose(() {
    routerRefresh.dispose();
  });

  return GoRouter(
    initialLocation: '/splash',

    refreshListenable: routerRefresh,

    redirect: (context, state) {
      final authState = ref.read(authSessionNotifierProvider);

      final location = state.matchedLocation;

      final isSplash = location == '/splash';

      final isLogin = location == '/login';

      final isRegistration = location == '/registration';

      final isAuthRoute = isLogin || isRegistration;

      // ------------------------------------------
      // SESSION IS BEING CHECKED
      // ------------------------------------------

      if (authState.status == AuthSessionStatus.checking) {
        if (!isSplash) {
          return '/splash';
        }

        return null;
      }

      // ------------------------------------------
      // USER IS AUTHENTICATED
      // ------------------------------------------

      if (authState.status == AuthSessionStatus.authenticated) {
        // Authenticated users should not stay
        // on splash/login/registration.
        if (isSplash || isAuthRoute) {
          return '/home';
        }

        return null;
      }

      // ------------------------------------------
      // USER IS NOT AUTHENTICATED
      // ------------------------------------------

      if (authState.status == AuthSessionStatus.unauthenticated) {
        // Allow login and registration pages.
        if (isAuthRoute) {
          return null;
        }

        // Anything else requires authentication.
        return '/login';
      }

      return null;
    },

    routes: [
      // ------------------------------------------
      // UI KIT PLAYGROUND
      // ------------------------------------------
      //
      // Visibility depends on flavor + build mode — see
      // AppEnvironment.enableUiPlayground. Never available in prod.
      if (AppEnvironment.current.enableUiPlayground)
        GoRoute(
          path: '/ui-playground',
          builder: (context, state) {
            return const UiPlaygroundPage();
          },
        ),

      // ------------------------------------------
      // QR SCANNER (core capability, full-screen)
      // ------------------------------------------
      //
      // Opened with AppQrScanner.scan(context), which pushes this
      // route and awaits the popped String. Available in every
      // flavor — any feature may need to scan a code.
      GoRoute(
        path: AppQrScanner.routePath,
        builder: (context, state) {
          final config = state.extra as QrScannerConfig?;

          return QrScannerPage(config: config ?? const QrScannerConfig());
        },
      ),

      // ------------------------------------------
      // FACE CAPTURE (core capability, full-screen)
      // ------------------------------------------
      //
      // Opened with AppFaceCapture.capture(context), which pushes
      // this route and awaits the popped FaceCaptureResult.
      GoRoute(
        path: AppFaceCapture.routePath,
        builder: (context, state) {
          final config = state.extra as FaceCaptureConfig?;

          return FaceCapturePage(config: config ?? const FaceCaptureConfig());
        },
      ),

      // ------------------------------------------
      // IMAGE VIEWER (core capability, full-screen)
      // ------------------------------------------
      //
      // Opened with AppImageViewer.show / .showGallery. Registering it
      // as a route rather than a bespoke overlay is what makes the
      // Android back gesture close it for free.
      GoRoute(
        path: AppImageViewer.routePath,
        builder: (context, state) {
          final args = state.extra as AppImageViewerArgs?;

          return ImageViewerPage(
            args: args ?? const AppImageViewerArgs(images: []),
          );
        },
      ),

      // ------------------------------------------
      // SIGNATURE PAD (core capability, full-screen)
      // ------------------------------------------
      //
      // Opened with AppSignaturePad.show(context), which pushes this
      // route and awaits the popped SignatureResult. Full-screen
      // because a signature needs every pixel the device has.
      GoRoute(
        path: AppSignaturePad.routePath,
        builder: (context, state) {
          final config = state.extra as SignaturePadConfig?;

          return SignaturePadPage(config: config ?? const SignaturePadConfig());
        },
      ),

      // ------------------------------------------
      // SPLASH
      // ------------------------------------------
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          return const SplashPage();
        },
      ),

      // ------------------------------------------
      // AUTH
      // ------------------------------------------
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final message = state.uri.queryParameters['message'];

          return LoginPage(message: message);
        },
      ),

      GoRoute(
        path: '/registration',
        builder: (context, state) {
          return const RegistrationPage();
        },
      ),

      // ------------------------------------------
      // MAIN APPLICATION
      // ------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // ----------------------------------------
          // HOME
          // ----------------------------------------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) {
                  return const HomePage();
                },
              ),
            ],
          ),

          // ----------------------------------------
          // PROFILE
          // ----------------------------------------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) {
                  return const ProfilePage();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
