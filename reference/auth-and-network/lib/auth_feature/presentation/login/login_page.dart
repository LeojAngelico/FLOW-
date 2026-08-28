import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/error_localizer.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../session/auth_session_notifier.dart';
import 'login_notifier.dart';
import 'login_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? message;

  const LoginPage({super.key, this.message});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Optional message passed by another part of the application,
    // such as a successful registration redirect.
    if (widget.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        AppSnackbar.success(context, message: widget.message!);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final loc = AppLocalizations.of(context)!;

    // Listen for changes coming from the LoginNotifier.
    //
    // We intentionally use ref.listen instead of manually checking
    // the state after calling login(). This keeps the UI reactive
    // to the ViewModel/Notifier state.
    ref.listen<LoginState>(loginNotifierProvider, (previous, next) {
      // ------------------------------------------
      // LOGIN SUCCESS
      // ------------------------------------------

      if (previous?.user == null && next.user != null) {
        // Update the global authentication session.
        ref.read(authSessionNotifierProvider.notifier).authenticated();

        if (!context.mounted) {
          return;
        }

        // Navigate using GoRouter. MainShell will take over and
        // display the Home tab.
        context.go('/home');

        return;
      }

      // ------------------------------------------
      // LOGIN ERROR
      // ------------------------------------------

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackbar.error(
          context,
          message: ErrorLocalizer.resolve(context, next.errorMessage!),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),

                    // --------------------------------
                    // APP ICON
                    // --------------------------------
                    Icon(
                      Icons.shield_outlined,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // --------------------------------
                    // TITLE
                    // --------------------------------
                    Text(
                      loc.appTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      loc.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // --------------------------------
                    // EMAIL
                    // --------------------------------
                    AppTextField(
                      controller: _emailController,
                      label: loc.emailLabel,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !state.isLoading,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.loginEmailRequired;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // --------------------------------
                    // PASSWORD
                    // --------------------------------
                    AppPasswordField(
                      controller: _passwordController,
                      label: loc.passwordLabel,
                      textInputAction: TextInputAction.done,
                      enabled: !state.isLoading,
                      onSubmitted: (_) => _login(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.loginPasswordRequired;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // --------------------------------
                    // LOGIN BUTTON
                    // --------------------------------
                    AppButton(
                      label: loc.loginButton,
                      isLoading: state.isLoading,
                      onPressed: state.isLoading ? null : _login,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // --------------------------------
                    // REGISTRATION
                    // --------------------------------
                    AppButton(
                      label: loc.loginCreateAccount,
                      variant: AppButtonVariant.text,
                      onPressed: state.isLoading
                          ? null
                          : () {
                              context.push('/registration');
                            },
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref
        .read(loginNotifierProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }
}
