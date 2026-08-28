import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/error_localizer.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'registration_notifier.dart';
import 'registration_state.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationNotifierProvider);
    final loc = AppLocalizations.of(context)!;

    ref.listen<RegistrationState>(registrationNotifierProvider, (
      previous,
      next,
    ) {
      if (next.isSuccess && previous?.isSuccess != true) {
        context.go(
          Uri(
            path: '/login',
            queryParameters: {'message': loc.registrationSuccessMessage},
          ).toString(),
        );

        return;
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackbar.error(
          context,
          message: ErrorLocalizer.resolve(context, next.errorMessage!),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(loc.registrationTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                controller: _firstNameController,
                label: loc.firstNameLabel,
                field: 'firstname',
                state: state,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: AppSpacing.lg),

              _buildField(
                controller: _lastNameController,
                label: loc.lastNameLabel,
                field: 'lastname',
                state: state,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: AppSpacing.lg),

              _buildField(
                controller: _middleNameController,
                label: loc.middleNameLabel,
                field: 'middlename',
                state: state,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: AppSpacing.lg),

              _buildField(
                controller: _usernameController,
                label: loc.registrationUsernameLabel,
                field: 'username',
                state: state,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: AppSpacing.lg),

              _buildField(
                controller: _emailController,
                label: loc.emailLabel,
                field: 'email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                state: state,
              ),

              const SizedBox(height: AppSpacing.lg),

              AppPasswordField(
                controller: _passwordController,
                label: loc.passwordLabel,
                enabled: !state.isLoading,
                textInputAction: TextInputAction.done,
                errorText: _fieldError(state, 'password'),
                onChanged: (_) {
                  ref
                      .read(registrationNotifierProvider.notifier)
                      .clearFieldError('password');
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              AppButton(
                label: loc.registrationButton,
                isLoading: state.isLoading,
                onPressed: state.isLoading ? null : _register,
              ),

              const SizedBox(height: AppSpacing.md),

              AppButton(
                label: loc.registrationAlreadyHaveAccount,
                variant: AppButtonVariant.text,
                onPressed: state.isLoading
                    ? null
                    : () {
                        context.pop();
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _fieldError(RegistrationState state, String field) {
    final errors = state.fieldErrors[field];

    return errors != null && errors.isNotEmpty ? errors.first : null;
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String field,
    required RegistrationState state,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return AppTextField(
      controller: controller,
      label: label,
      enabled: !state.isLoading,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      errorText: _fieldError(state, field),
      onChanged: (_) {
        ref.read(registrationNotifierProvider.notifier).clearFieldError(field);
      },
    );
  }

  Future<void> _register() async {
    await ref
        .read(registrationNotifierProvider.notifier)
        .register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          middleName: _middleNameController.text.trim(),
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }
}
