import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/core/constants/app_constants.dart';
import 'package:hafatra/core/design_system/app_colors.dart';
import 'package:hafatra/core/design_system/app_spacing.dart';
import 'package:hafatra/core/l10n/l10n.dart';
import 'package:hafatra/core/utils/date_format.dart';
import 'package:hafatra/core/widgets/app_widgets.dart';
import 'package:hafatra/features/chat/domain/chat_message.dart';

/// Deux messages se suivent (même émetteur, même minute environ) quand ils
/// se regroupent avec des espacements serrés et une seule signature.
const Duration _groupWindow = Duration(minutes: 3);

/// Salon public du quartier, avec états de transmission honnêtes.
final class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

final class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToLatest() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      0,
      duration: AppMotion.reveal,
      curve: AppMotion.standard,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      _showMessage(l10n.messageEmpty);
      return;
    }
    final bytes = utf8.encode(text).length;
    if (bytes > AppConstants.maxMessageBytes) {
      _showMessage(l10n.messageTooLong(bytes, AppConstants.maxMessageBytes));
      return;
    }
    try {
      await ref.read(chatControllerProvider.notifier).send(text);
      if (!mounted) {
        return;
      }
      _messageController.clear();
      _focusNode.requestFocus();
      _scrollToLatest();
    } on Object {
      if (mounted) {
        _showMessage(l10n.errorGeneric);
      }
    }
  }

  Future<void> _restartMesh() async {
    try {
      await ref.read(meshControllerProvider.notifier).start();
    } on Object {
      if (mounted) {
        _showMessage(context.l10n.errorMeshNotReady);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = context.surfaces;
    final channel = ref.watch(channelProvider);
    final mesh = ref.watch(meshControllerProvider);
    final sending = ref.watch(chatControllerProvider);

    if (channel == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.chatTitle)),
        body: EmptyState(
          icon: Icons.forum_outlined,
          title: l10n.errorGeneric,
          body: l10n.errorMeshNotReady,
        ),
      );
    }

    final messagesAsync = ref.watch(chatMessagesProvider(channel.id));
    ref.listen<AsyncValue<List<ChatMessage>>>(
      chatMessagesProvider(channel.id),
      (previous, next) {
        final previousCount = previous?.value?.length ?? 0;
        final nextCount = next.value?.length ?? 0;
        if (nextCount > previousCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToLatest();
          });
        }
      },
    );

    final statusText = mesh.isRunning
        ? l10n.peersNearby(mesh.peerCount)
        : mesh.isBusy
        ? l10n.meshStarting
        : l10n.meshInactive;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.gutter,
        backgroundColor: surfaces.card,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.7),
          child: ColoredBox(
            color: surfaces.hairline,
            child: const SizedBox(height: 0.7),
          ),
        ),
        title: Row(
          children: [
            LiveDot(active: mesh.isRunning, color: scheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chatTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mesh.isRunning
                          ? scheme.onSurfaceVariant
                          : scheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (mesh.demo)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Center(
                child: StatusBadge(
                  label: l10n.demoTag,
                  color: scheme.secondary,
                  icon: Icons.science_outlined,
                ),
              ),
            ),
          IconButton(
            tooltip: l10n.meshTitle,
            onPressed: () => context.go('/mesh'),
            icon: const Icon(Icons.hub_outlined),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          if (!mesh.demo && !mesh.isRunning)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.md,
                AppSpacing.gutter,
                0,
              ),
              child: InfoBanner(
                icon: Icons.bluetooth_disabled_rounded,
                message: mesh.lastError ?? l10n.errorMeshNotReady,
                tone: InfoTone.error,
                action: TextButton(
                  onPressed: _restartMesh,
                  child: Text(l10n.retryLabel),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.md,
              AppSpacing.gutter,
              0,
            ),
            child: InfoBanner(
              icon: Icons.public_rounded,
              message: l10n.publicChannelWarning,
              tone: InfoTone.warning,
            ),
          ),
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: l10n.errorGeneric,
                body: l10n.errorStorage,
                action: FilledButton.tonal(
                  onPressed: () =>
                      ref.invalidate(chatMessagesProvider(channel.id)),
                  child: Text(l10n.retryLabel),
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: l10n.chatEmptyTitle,
                    body: l10n.chatEmptyBody,
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    AppSpacing.md,
                    AppSpacing.gutter,
                    AppSpacing.lg,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final position = messages.length - 1 - index;
                    final message = messages[position];
                    final older = position > 0 ? messages[position - 1] : null;
                    final newDay =
                        older == null ||
                        AppDateFormat.dayKey(older.createdAt) !=
                            AppDateFormat.dayKey(message.createdAt);
                    final grouped =
                        !newDay &&
                        older.isOutgoing == message.isOutgoing &&
                        older.senderName == message.senderName &&
                        message.createdAt.difference(older.createdAt) <=
                            _groupWindow;
                    return _MessageRow(
                      message: message,
                      grouped: grouped,
                      dayLabel: newDay
                          ? _dayLabel(l10n, message.createdAt)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          _ChatComposer(
            controller: _messageController,
            focusNode: _focusNode,
            sending: sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  String _dayLabel(AppLocalizations l10n, DateTime moment) {
    final local = moment.toLocal();
    final today = DateTime.now();
    final isToday =
        local.year == today.year &&
        local.month == today.month &&
        local.day == today.day;
    if (isToday) return l10n.dateToday;
    final yesterday = today.subtract(const Duration(days: 1));
    final isYesterday =
        local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day;
    if (isYesterday) return l10n.dateYesterday;
    return AppDateFormat.dayLabel(moment);
  }
}

/// Code du salon, copiable d'un tap.
/// Ligne de message : séparateur de jour éventuel, avatar pour les entrants,
/// bulle et métadonnées.
final class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.message,
    required this.grouped,
    required this.dayLabel,
  });

  final ChatMessage message;
  final bool grouped;
  final String? dayLabel;

  @override
  Widget build(BuildContext context) {
    final outgoing = message.isOutgoing;
    return Column(
      children: [
        if (dayLabel != null) _DaySeparator(label: dayLabel!),
        Padding(
          padding: EdgeInsets.only(top: grouped ? 2 : AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!outgoing) ...[
                SizedBox(
                  width: 30,
                  child: grouped
                      ? null
                      : InitialAvatar(name: message.senderName, size: 30),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: _MessageBubble(message: message, grouped: grouped),
              ),
              if (outgoing) const SizedBox(width: 38),
            ],
          ),
        ),
      ],
    );
  }
}

final class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = context.surfaces;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: surfaces.hairline)),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: surfaces.field,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Container(height: 1, color: surfaces.hairline)),
        ],
      ),
    );
  }
}

final class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.grouped});

  final ChatMessage message;
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = context.surfaces;
    final gradients = context.gradients;
    final outgoing = message.isOutgoing;
    final foreground = outgoing ? gradients.brandInk : scheme.onSurface;
    final muted = outgoing
        ? gradients.brandInk.withValues(alpha: 0.78)
        : scheme.onSurfaceVariant;

    const tight = Radius.circular(AppRadius.sm);
    const round = Radius.circular(AppRadius.lg);
    final radius = outgoing
        ? BorderRadius.only(
            topLeft: round,
            topRight: grouped ? round : tight,
            bottomLeft: round,
            bottomRight: grouped ? tight : round,
          )
        : BorderRadius.only(
            topLeft: grouped ? round : tight,
            topRight: round,
            bottomLeft: grouped ? tight : round,
            bottomRight: round,
          );

    return Align(
      alignment: outgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.74,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: outgoing
                ? AppElevation.glow(surfaces.glow)
                : AppElevation.low(surfaces.shadow),
            gradient: outgoing ? gradients.brand : null,
            color: outgoing ? null : surfaces.card,
            border: outgoing
                ? null
                : Border.all(color: surfaces.hairlineStrong, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!outgoing && !grouped) ...[
                Text(
                  message.senderName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(
                message.body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: foreground,
                  height: 1.42,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppDateFormat.time(message.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (outgoing) ...[
                    const SizedBox(width: AppSpacing.xs + 2),
                    Icon(_statusIcon, size: 14, color: _statusColor(context)),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        _statusLabel(l10n),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _statusColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return message.status == ChatMessageStatus.failed
        ? scheme.error
        : context.gradients.brandInk.withValues(alpha: 0.85);
  }

  IconData get _statusIcon => switch (message.status) {
    ChatMessageStatus.queued => Icons.schedule_rounded,
    ChatMessageStatus.sent => Icons.check_rounded,
    ChatMessageStatus.relayed => Icons.done_all_rounded,
    ChatMessageStatus.seen => Icons.visibility_outlined,
    ChatMessageStatus.failed => Icons.error_outline_rounded,
  };

  String _statusLabel(AppLocalizations l10n) {
    return switch (message.status) {
      ChatMessageStatus.queued => l10n.statusQueued,
      ChatMessageStatus.sent => l10n.statusSent,
      ChatMessageStatus.relayed =>
        message.relayCount > 0
            ? l10n.relayedBy(message.relayCount)
            : l10n.statusRelayed,
      ChatMessageStatus.seen =>
        message.seenCount > 0
            ? l10n.seenBy(message.seenCount)
            : l10n.statusSeen,
      ChatMessageStatus.failed => l10n.statusFailed,
    };
  }
}

/// Barre de composition : champ en pilule et bouton d'envoi en dégradé.
final class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = context.surfaces;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaces.card,
        boxShadow: [
          BoxShadow(
            color: surfaces.shadow,
            blurRadius: 24,
            offset: const Offset(0, -3),
          ),
          BoxShadow(
            color: surfaces.hairline,
            blurRadius: 0,
            offset: const Offset(0, -0.7),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            final text = value.text.trim();
            final bytes = utf8.encode(text).length;
            final tooLong = bytes > AppConstants.maxMessageBytes;
            final canSend = text.isNotEmpty && !tooLong && !sending;
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bytes > AppConstants.maxMessageBytes ~/ 2)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.lg,
                        bottom: AppSpacing.xs,
                      ),
                      child: Text(
                        tooLong
                            ? l10n.messageTooLong(
                                bytes,
                                AppConstants.maxMessageBytes,
                              )
                            : '$bytes / ${AppConstants.maxMessageBytes}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: tooLong
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                          fontWeight: tooLong
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          minLines: 1,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.newline,
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: l10n.chatComposerHint,
                            filled: true,
                            fillColor: surfaces.field,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                              borderSide: BorderSide(color: surfaces.hairline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                              borderSide: BorderSide(
                                color: scheme.primary,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _SendButton(
                        enabled: canSend,
                        sending: sending,
                        onSend: onSend,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.enabled,
    required this.sending,
    required this.onSend,
  });

  final bool enabled;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surfaces = context.surfaces;
    final gradients = context.gradients;
    final active = enabled || sending;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: active ? gradients.brand : null,
        color: active ? null : surfaces.field,
        boxShadow: active ? AppElevation.glow(surfaces.glow) : null,
      ),
      child: Material(
        type: MaterialType.circle,
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onSend : null,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 50,
            child: Center(
              child: sending
                  ? SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: gradients.brandInk,
                      ),
                    )
                  : Icon(
                      Icons.arrow_upward_rounded,
                      size: 24,
                      color: active
                          ? gradients.brandInk
                          : scheme.onSurfaceVariant,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
