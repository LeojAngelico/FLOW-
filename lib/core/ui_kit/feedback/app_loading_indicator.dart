import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';

enum AppLoadingSize { small, medium, large }

/// A centered loading spinner, with an optional label underneath.
///
/// Replaces the bare `CircularProgressIndicator()` duplicated
/// across screens with one consistent, sizeable loading state.
class AppLoadingIndicator extends StatelessWidget {
  final AppLoadingSize size;
  final String? label;

  const AppLoadingIndicator({
    super.key,
    this.size = AppLoadingSize.medium,
    this.label,
  });

  double get _dimension {
    switch (size) {
      case AppLoadingSize.small:
        return 20;
      case AppLoadingSize.medium:
        return 32;
      case AppLoadingSize.large:
        return 48;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _dimension,
            height: _dimension,
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(label!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
