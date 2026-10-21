import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hafatra/core/design_system/app_colors.dart';
import 'package:hafatra/core/design_system/app_spacing.dart';

/// En-tête de section : surtitre en petites capitales, filet et action
/// facultative à droite.
final class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.xl,
        AppSpacing.gutter,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              gradient: context.gradients.brand,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Carte de contenu : la profondeur vient de l'ombre, pas de la bordure.
final class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color,
    this.accent,
    this.elevated = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? accent;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? surfaces.card,
        borderRadius: AppRadius.card(),
        boxShadow: elevated
            ? AppElevation.medium(surfaces.shadow)
            : AppElevation.low(surfaces.shadow),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card(),
        child: Stack(
          children: [
            if (accent != null)
              PositionedDirectional(
                top: 0,
                bottom: 0,
                start: 0,
                child: Container(width: 4, color: accent),
              ),
            PressableScale(
              onTap: onTap,
              borderRadius: AppRadius.card(),
              child: Padding(padding: padding, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

/// Support de micro-interaction : les éléments tactiles s'enfoncent légèrement
/// au lieu de simplement changer de teinte. Aucun effet quand le système
/// demande de réduire les animations.
final class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.scaleFactor = 0.98,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final double scaleFactor;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

final class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final animate = !AppMotion.reduceMotion(context) && widget.onTap != null;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        borderRadius: widget.borderRadius,
        onHighlightChanged: _setPressed,
        child: AnimatedScale(
          scale: animate && _pressed ? widget.scaleFactor : 1,
          duration: AppMotion.press,
          curve: AppMotion.standard,
          child: widget.child,
        ),
      ),
    );
  }
}

enum InfoTone { neutral, accent, warning, error }

/// Bandeau d'information compact : icône dans un disque teinté, fond et
/// filet dans la même teinte, action facultative.
final class InfoBanner extends StatelessWidget {
  const InfoBanner({
    required this.icon,
    required this.message,
    this.tone = InfoTone.accent,
    this.action,
    super.key,
  });

  final IconData icon;
  final String message;
  final InfoTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = context.surfaces;
    // Le fond reste une surface de la rampe, à peine teintée de l'accent :
    // les conteneurs Material virent au marron en sombre sur du papier chaud.
    final (base, emphasis) = switch (tone) {
      InfoTone.neutral => (surfaces.field, scheme.onSurfaceVariant),
      InfoTone.accent => (surfaces.card, scheme.primary),
      InfoTone.warning => (surfaces.card, scheme.secondary),
      InfoTone.error => (surfaces.card, scheme.error),
    };
    final background = Color.alphaBlend(emphasis.withValues(alpha: 0.08), base);
    final foreground = scheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: emphasis.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: emphasis.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: emphasis),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foreground,
                  height: 1.42,
                ),
              ),
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: AppSpacing.sm),
            action!,
          ],
        ],
      ),
    );
  }
}

/// État vide illustré : halo dégradé derrière l'icône, titre et corps.
final class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final gradients = context.gradients;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradients.brandSoft,
                boxShadow: AppElevation.glow(context.surfaces.glow),
              ),
              child: SizedBox.square(
                dimension: 88,
                child: Center(
                  child: Icon(icon, size: 36, color: scheme.onPrimaryContainer),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Petite pastille de statut : teinte + icône + texte, jamais la couleur seule.
final class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.color,
    this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: AppSpacing.xs + 1),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tuile de statistique utilisée sur l'écran maillage.
final class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.tone,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = context.surfaces;
    final color = tone ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: surfaces.card,
        borderRadius: AppRadius.card(),
        boxShadow: AppElevation.low(surfaces.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Avatar à initiales, coloré de façon stable à partir du nom affiché.
final class InitialAvatar extends StatelessWidget {
  const InitialAvatar({
    required this.name,
    this.size = 38,
    this.color,
    super.key,
  });

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tone =
        color ?? _palette[name.hashCode.abs() % _palette.length](scheme);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tone.withValues(alpha: 0.95), tone.withValues(alpha: 0.7)],
        ),
      ),
      child: Center(
        child: Text(
          _initials(name),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final buffer = StringBuffer();
    for (final part in parts.take(2)) {
      if (part.isNotEmpty) buffer.write(part[0].toUpperCase());
    }
    final initials = buffer.toString();
    return initials.isEmpty ? '?' : initials;
  }

  static final List<Color Function(ColorScheme)> _palette = [
    (scheme) => scheme.primary,
    (scheme) => scheme.tertiary,
    (scheme) => scheme.secondary,
    (scheme) => const Color(0xFF2E7D32),
  ];
}

/// Indicateur d'activité du maillage : pulsation lente quand le transport
/// tourne, point fixe sinon. Neutralisé si le système réduit les animations.
final class LiveDot extends StatefulWidget {
  const LiveDot({
    required this.active,
    required this.color,
    this.size = 9,
    super.key,
  });

  final bool active;
  final Color color;
  final double size;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

final class _LiveDotState extends State<LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(LiveDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _sync();
    }
  }

  void _sync() {
    if (widget.active && !AppMotion.reduceMotion(context)) {
      _controller.repeat();
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = AppMotion.reduceMotion(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final diameter = math.min(
          widget.size * (1 + t * 1.6),
          widget.size * 2.2,
        );
        return SizedBox.square(
          dimension: widget.size * 2.2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!reduce)
                Opacity(
                  opacity: widget.active ? (0.4 - t * 0.4).clamp(0.0, 0.4) : 0,
                  child: Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color,
                    ),
                  ),
                ),
              child!,
            ],
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.active
              ? widget.color
              : Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
