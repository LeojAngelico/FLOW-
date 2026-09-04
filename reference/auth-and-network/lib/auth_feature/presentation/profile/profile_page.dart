import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/locale/locale_notifier.dart';
import '../../../../core/localization/error_localizer.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/user.dart';

import '../session/auth_session_notifier.dart';

import 'profile_notifier.dart';
import 'profile_state.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(profileNotifierProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.profileTitle)),
      body: SafeArea(child: _buildBody(context, state)),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state.isLoading) {
      return const AppLoadingIndicator();
    }

    if (state.errorMessage != null) {
      return AppErrorState(
        message: ErrorLocalizer.resolve(context, state.errorMessage!),
        retryLabel: AppLocalizations.of(context)!.retry,
        onRetry: () {
          ref.read(profileNotifierProvider.notifier).loadProfile();
        },
      );
    }

    final user = state.user;

    if (user == null) {
      return AppEmptyState(
        icon: Icons.person_outline,
        title: AppLocalizations.of(context)!.profileNoInfo,
      );
    }

    final loc = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () {
        return ref.read(profileNotifierProvider.notifier).loadProfile();
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          AppAvatar(
            imageUrl: user.avatar.fullPath,
            initials: _getInitials(user),
            size: 100,
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            user.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            '@${user.username}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: AppSpacing.xxl),

          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                _buildInfoTile(
                  context,
                  icon: Icons.email_outlined,
                  label: loc.emailLabel,
                  value: user.email,
                ),

                _buildInfoTile(
                  context,
                  icon: Icons.person_outline,
                  label: loc.firstNameLabel,
                  value: user.firstName,
                ),

                _buildInfoTile(
                  context,
                  icon: Icons.person_outline,
                  label: loc.lastNameLabel,
                  value: user.lastName,
                ),

                if (user.middleName.isNotEmpty)
                  _buildInfoTile(
                    context,
                    icon: Icons.person_outline,
                    label: loc.middleNameLabel,
                    value: user.middleName,
                  ),

                _buildInfoTile(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: loc.profileMemberSince,
                  value: user.dateCreated.monthYear,
                ),

                _buildLanguageTile(context, ref),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          AppButton(
            label: loc.profileLogout,
            icon: Icons.logout,
            variant: AppButtonVariant.outlined,
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // LANGUAGE
  // --------------------------------------------------

  Widget _buildLanguageTile(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeNotifierProvider);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.language_outlined),
      title: Text(loc.profileLanguageLabel),
      subtitle: Text(_languageName(loc, currentLocale.languageCode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguagePicker(context, ref, currentLocale),
    );
  }

  String _languageName(AppLocalizations loc, String languageCode) {
    switch (languageCode) {
      case 'fil':
        return loc.languageFilipino;
      case 'ceb':
        return loc.languageCebuano;
      default:
        return loc.languageEnglish;
    }
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
  ) async {
    final loc = AppLocalizations.of(context)!;

    const options = [Locale('en'), Locale('fil'), Locale('ceb')];

    final selected = await showDialog<Locale>(
      context: context,
      builder: (dialogContext) {
        return AppDialog(
          title: loc.profileLanguageLabel,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in options)
                RadioListTile<Locale>(
                  value: option,
                  groupValue: currentLocale,
                  title: Text(_languageName(loc, option.languageCode)),
                  onChanged: (value) {
                    Navigator.pop(dialogContext, value);
                  },
                ),
            ],
          ),
        );
      },
    );

    if (selected != null && selected != currentLocale) {
      ref.read(localeNotifierProvider.notifier).setLocale(selected);
    }
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  String _getInitials(User user) {
    final first = user.firstName.isNotEmpty ? user.firstName[0] : '';

    final last = user.lastName.isNotEmpty ? user.lastName[0] : '';

    return '$first$last'.toUpperCase();
  }

  Future<void> _showLogoutDialog() async {
    final loc = AppLocalizations.of(context)!;

    await AppConfirmationDialog.show(
      context,
      title: loc.profileLogout,
      message: loc.profileLogoutConfirmMessage,
      confirmLabel: loc.profileLogout,
      cancelLabel: loc.cancel,
      isDestructive: true,
      onConfirm: _performLogout,
    );
  }

  Future<void> _performLogout() async {
    final loc = AppLocalizations.of(context)!;

    AppLoadingDialog.show(context, message: loc.profileLoggingOut);

    try {
      await ref.read(authSessionNotifierProvider.notifier).logout();
    } finally {
      if (mounted) {
        AppLoadingDialog.hide(context);
      }
    }
  }
}
