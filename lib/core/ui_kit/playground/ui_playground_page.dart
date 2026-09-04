import 'package:flutter/material.dart';

import '../../image_viewer/image_viewer.dart';
import '../ui_kit.dart';

/// Living visual documentation for the Core UI Kit.
///
/// Debug-only — see the `kDebugMode`-gated route in `app_router.dart`
/// and the floating shortcut in `app.dart`. Every section shows a
/// component's name, purpose, and its available states side by side.
class UiPlaygroundPage extends StatefulWidget {
  const UiPlaygroundPage({super.key});

  @override
  State<UiPlaygroundPage> createState() => _UiPlaygroundPageState();
}

class _UiPlaygroundPageState extends State<UiPlaygroundPage> {
  bool _isButtonLoading = false;
  bool _chipSelected = false;

  // --------------------------------------------------
  // IMAGE VIEWER — reference integration
  // --------------------------------------------------
  //
  // Hand it images, await the close. Public placeholder photos are
  // used here so the demo needs nothing from the project's own
  // storage; a feature would pass its own URLs, files or bytes.

  static const List<String> _demoImageUrls = [
    'https://picsum.photos/id/1015/1200/1600',
    'https://picsum.photos/id/1025/1600/1200',
    'https://picsum.photos/id/1035/1400/1400',
    'https://picsum.photos/id/1045/1200/1800',
  ];

  static const Object _heroTag = 'playground-image-hero';

  List<AppImageSource> get _demoImages {
    return [
      for (var i = 0; i < _demoImageUrls.length; i++)
        AppImageSource.network(
          _demoImageUrls[i],
          semanticLabel: 'Sample photo ${i + 1}',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI Kit Playground')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Section(
            name: 'AppButton',
            purpose:
                'One flexible button with five variants, loading '
                'and disabled states, and optional icons.',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                AppButton(label: 'Primary', onPressed: () {}),
                AppButton(
                  label: 'Secondary',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'Outlined',
                  variant: AppButtonVariant.outlined,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'Text',
                  variant: AppButtonVariant.text,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'Destructive',
                  variant: AppButtonVariant.destructive,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'With icon',
                  icon: Icons.download_outlined,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'Trailing icon',
                  icon: Icons.arrow_forward,
                  iconPosition: AppButtonIconPosition.trailing,
                  variant: AppButtonVariant.outlined,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'Loading',
                  isLoading: _isButtonLoading,
                  onPressed: () {
                    setState(() => _isButtonLoading = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _isButtonLoading = false);
                    });
                  },
                ),
                const AppButton(label: 'Disabled', onPressed: null),
              ],
            ),
          ),
          _Section(
            name: 'AppTextField',
            purpose: 'Standard text input with label/hint/error support.',
            child: const Column(
              children: [
                AppTextField(label: 'Email', hint: 'you@example.com'),
                SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Password',
                  errorText: 'Password is required.',
                ),
              ],
            ),
          ),
          _Section(
            name: 'AppPasswordField',
            purpose: 'Password input with a built-in visibility toggle.',
            child: const AppPasswordField(label: 'Password'),
          ),
          _Section(
            name: 'AppCard',
            purpose: 'Tappable card surface shared by list/grid items.',
            child: AppCard(
              onTap: () {},
              child: const Row(
                children: [
                  Icon(Icons.description_outlined),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: Text('Tap this card')),
                ],
              ),
            ),
          ),
          _Section(
            name: 'AppBottomSheet',
            purpose:
                'Generic action sheet — a title plus a list of '
                'tappable actions.',
            child: AppButton(
              label: 'Show actions',
              variant: AppButtonVariant.outlined,
              onPressed: () => AppBottomSheet.showActions(
                context,
                title: 'Choose a photo',
                actions: [
                  AppBottomSheetAction(
                    icon: Icons.photo_camera_outlined,
                    label: 'Take Photo',
                    onTap: () {},
                  ),
                  AppBottomSheetAction(
                    icon: Icons.photo_library_outlined,
                    label: 'Choose from Gallery',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          _Section(
            name: 'AppAvatar',
            purpose: 'Image avatar with initials fallback.',
            child: const Row(
              children: [
                AppAvatar(initials: 'JD', size: AppSizing.avatarSm),
                SizedBox(width: AppSpacing.md),
                AppAvatar(initials: 'JD'),
                SizedBox(width: AppSpacing.md),
                AppAvatar(initials: 'JD', size: AppSizing.avatarLg),
              ],
            ),
          ),
          _Section(
            name: 'AppBadge',
            purpose: 'Status pills for list items and card headers.',
            child: const Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppBadge(label: 'Neutral'),
                AppBadge(label: 'Info', variant: AppBadgeVariant.info),
                AppBadge(label: 'Success', variant: AppBadgeVariant.success),
                AppBadge(label: 'Warning', variant: AppBadgeVariant.warning),
                AppBadge(label: 'Error', variant: AppBadgeVariant.error),
              ],
            ),
          ),
          _Section(
            name: 'AppChip',
            purpose: 'Selectable filter chip.',
            child: AppChip(
              label: 'Filter',
              icon: Icons.filter_alt_outlined,
              selected: _chipSelected,
              onSelected: (value) => setState(() => _chipSelected = value),
            ),
          ),
          _Section(
            name: 'AppSnackbar',
            purpose: 'Themed feedback banners for success/error/warning/info.',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                AppButton(
                  label: 'Success',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => AppSnackbar.success(
                    context,
                    message: 'Saved successfully.',
                  ),
                ),
                AppButton(
                  label: 'Error',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => AppSnackbar.error(
                    context,
                    message: 'Something went wrong.',
                  ),
                ),
                AppButton(
                  label: 'Warning',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => AppSnackbar.warning(
                    context,
                    message: 'This action needs review.',
                  ),
                ),
                AppButton(
                  label: 'Info',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => AppSnackbar.info(
                    context,
                    message: 'Heads up — something changed.',
                  ),
                ),
              ],
            ),
          ),
          _Section(
            name: 'AppLoadingIndicator',
            purpose: 'Sizeable loading spinner with an optional label.',
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppLoadingIndicator(size: AppLoadingSize.small),
                AppLoadingIndicator(size: AppLoadingSize.medium),
                AppLoadingIndicator(
                  size: AppLoadingSize.large,
                  label: 'Loading…',
                ),
              ],
            ),
          ),
          _Section(
            name: 'AppEmptyState',
            purpose: 'Centered "nothing here" state with an optional action.',
            child: AppEmptyState(
              icon: Icons.inbox_outlined,
              title: 'No items yet',
              message: 'Items you add will show up here.',
              actionLabel: 'Add item',
              onAction: () {},
            ),
          ),
          _Section(
            name: 'AppErrorState',
            purpose: 'Centered error message with a retry action.',
            child: AppErrorState(
              message: 'Failed to load data.',
              onRetry: () {},
            ),
          ),
          _Section(
            name: 'AppDialog / AppConfirmationDialog',
            purpose:
                'Composable dialog shell, plus a ready-made '
                'confirm/cancel dialog built on top of it.',
            child: Wrap(
              spacing: AppSpacing.md,
              children: [
                AppButton(
                  label: 'Show dialog',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => AppDialog(
                      title: 'Export complete',
                      icon: Icons.check_circle_outline,
                      content: const Text(
                        'Your report was saved to Downloads.',
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        AppButton(
                          label: 'OK',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
                AppButton(
                  label: 'Confirm dialog',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => AppConfirmationDialog.show(
                    context,
                    title: 'Delete Report',
                    message: 'Are you sure you want to delete this report?',
                    isDestructive: true,
                    confirmLabel: 'Delete',
                    onConfirm: () {
                      AppSnackbar.success(context, message: 'Report deleted.');
                    },
                  ),
                ),
              ],
            ),
          ),
          _Section(
            name: 'AppImageViewer (Core capability)',
            purpose:
                'Immersive image viewer with pinch and double-tap '
                'zoom, panning, and swiping between images. Built on '
                'Flutter\'s InteractiveViewer — no image viewer package. '
                'Lives in core/image_viewer/.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tapping the thumbnail shows the Hero transition:
                // the same tag on both sides is all it takes.
                Align(
                  child: Semantics(
                    button: true,
                    label: 'Open sample photo',
                    child: InkWell(
                      onTap: () => AppImageViewer.show(
                        context,
                        AppImageSource.network(
                          _demoImageUrls.first,
                          semanticLabel: 'Sample photo',
                          heroTag: _heroTag,
                        ),
                      ),
                      borderRadius: AppRadius.mdAll,
                      child: Hero(
                        tag: _heroTag,
                        child: ClipRRect(
                          borderRadius: AppRadius.mdAll,
                          child: Image.network(
                            _demoImageUrls.first,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, _) => Container(
                              width: 120,
                              height: 120,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.image_outlined),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    AppButton(
                      label: 'Single image',
                      icon: Icons.image_outlined,
                      onPressed: () => AppImageViewer.show(
                        context,
                        AppImageSource.network(_demoImageUrls.first),
                      ),
                    ),
                    AppButton(
                      label: 'Gallery from 3rd',
                      icon: Icons.collections_outlined,
                      variant: AppButtonVariant.outlined,
                      onPressed: () => AppImageViewer.showGallery(
                        context,
                        _demoImages,
                        initialIndex: 2,
                      ),
                    ),
                    AppButton(
                      label: 'With a title + action',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => AppImageViewer.showGallery(
                        context,
                        _demoImages,
                        config: AppImageViewerConfig(
                          title: 'Evidence photos',
                          actions: [
                            AppImageViewerAction(
                              icon: Icons.info_outline,
                              label: 'Photo details',
                              onPressed: (index, image) => AppSnackbar.info(
                                context,
                                message:
                                    'Action fired for image '
                                    '${index + 1}.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppButton(
                      label: 'Error state',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => AppImageViewer.show(
                        context,
                        AppImageSource.network(
                          'https://example.invalid/missing.jpg',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _Section(
            name: 'AppLoadingDialog',
            purpose:
                'Non-dismissible blocking dialog for short, '
                'must-wait operations (e.g. logging out).',
            child: AppButton(
              label: 'Show loading dialog',
              variant: AppButtonVariant.outlined,
              onPressed: () async {
                AppLoadingDialog.show(context, message: 'Loading…');
                await Future.delayed(const Duration(seconds: 2));
                if (context.mounted) AppLoadingDialog.hide(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String name;
  final String purpose;
  final Widget child;

  const _Section({
    required this.name,
    required this.purpose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            purpose,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
          const Divider(height: AppSpacing.xxl * 2),
        ],
      ),
    );
  }
}
