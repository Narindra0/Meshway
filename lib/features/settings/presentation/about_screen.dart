import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/core/design_system/app_colors.dart';
import 'package:hafatra/core/design_system/app_spacing.dart';
import 'package:hafatra/core/l10n/l10n.dart';
import 'package:hafatra/core/widgets/app_widgets.dart';

/// Fiche « À propos », sans lien réseau.
final class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final version = ref.watch(appVersionProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.xl,
          AppSpacing.gutter,
          AppSpacing.xxl,
        ),
        children: [
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: context.gradients.hero,
                boxShadow: AppElevation.glow(context.surfaces.glow),
              ),
              child: SizedBox.square(
                dimension: 100,
                child: Center(
                  child: Icon(
                    Icons.forum_rounded,
                    size: 46,
                    color: context.gradients.brandInk,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.appName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.appTagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (version != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: StatusBadge(
                label: l10n.versionLabel(version),
                color: scheme.primary,
                icon: Icons.tag_rounded,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Text(
              l10n.aboutBody,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          InfoBanner(
            icon: Icons.wifi_off_rounded,
            message: l10n.aboutOffline,
            tone: InfoTone.accent,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.aboutPrivacy,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoBanner(
            icon: Icons.public_rounded,
            message: l10n.aboutPublicChannel,
            tone: InfoTone.warning,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.aboutLicense,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
