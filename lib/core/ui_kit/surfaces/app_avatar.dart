import 'package:flutter/material.dart';

import '../tokens/app_sizing.dart';

/// The Core UI Kit's avatar.
///
/// Shows [imageUrl] when available, falling back to [initials] —
/// on a missing URL, a failed image load, or an empty string —
/// instead of leaving a broken image.
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double size;
  final String? semanticLabel;

  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.initials,
    this.size = AppSizing.avatarMd,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Semantics(
      label: semanticLabel ?? 'Avatar',
      image: hasImage,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundImage: hasImage ? NetworkImage(imageUrl!) : null,
        onForegroundImageError: hasImage ? (_, _) {} : null,
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
