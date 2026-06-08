import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/recent_rooms_storage.dart';
import '../../core/storage/session_storage.dart';
import '../../core/theme/app_decorations.dart';

/// Home welcome: primary actions, recent rooms, optional archive.
class HomeWelcomeContent extends StatelessWidget {
  const HomeWelcomeContent({
    super.key,
    required this.configured,
    required this.isLoading,
    required this.recentRooms,
    required this.storedSession,
    required this.showResume,
    required this.archiveCount,
    required this.onResume,
    required this.onOpenCreate,
    required this.onOpenJoin,
    required this.onOpenRecent,
    required this.onTemplate,
    required this.onArchive,
  });

  final bool configured;
  final bool isLoading;
  final List<RecentRoomEntry> recentRooms;
  final StoredSession? storedSession;
  final bool showResume;
  final int archiveCount;
  final VoidCallback? onResume;
  final VoidCallback? onOpenCreate;
  final VoidCallback? onOpenJoin;
  final Future<void> Function(RecentRoomEntry entry) onOpenRecent;
  final VoidCallback? onTemplate;
  final VoidCallback? onArchive;

  bool get _enabled => configured && !isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showResume && storedSession != null) ...[
          _ResumeBanner(
            roomName: storedSession!.roomName ?? l10n.appName,
            roomCode: storedSession!.roomCode ?? '',
            enabled: _enabled,
            onTap: onResume,
          ),
          const SizedBox(height: 20),
        ],
        FilledButton.icon(
          onPressed: _enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onOpenCreate?.call();
                }
              : null,
          icon: const Icon(Icons.storefront_outlined),
          label: Text(l10n.openLocale),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onOpenJoin?.call();
                }
              : null,
          icon: const Icon(Icons.door_front_door_outlined),
          label: Text(l10n.enterBancone),
        ),
        if (recentRooms.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionLabel(text: l10n.recentRooms),
          const SizedBox(height: 10),
          _RecentRoomsCard(
            entries: recentRooms,
            enabled: _enabled,
            onOpen: onOpenRecent,
          ),
        ],
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: _enabled
                ? () {
                    HapticFeedback.lightImpact();
                    onTemplate?.call();
                  }
                : null,
            icon: const Icon(Icons.dashboard_customize_outlined, size: 20),
            label: Text(l10n.createFromTemplate),
          ),
        ),
        if (archiveCount > 0)
          Center(
            child: TextButton.icon(
              onPressed: onArchive,
              icon: const Icon(Icons.archive_outlined, size: 20),
              label: Text('${l10n.pastSessions} ($archiveCount)'),
            ),
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
    );
  }
}

class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner({
    required this.roomName,
    required this.roomCode,
    required this.enabled,
    required this.onTap,
  });

  final String roomName;
  final String roomCode;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                onTap?.call();
              }
            : null,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.restore_rounded,
                color: scheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.resumeSession,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.resumeSessionSubtitle(roomName, roomCode),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onPrimaryContainer
                                .withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentRoomsCard extends StatelessWidget {
  const _RecentRoomsCard({
    required this.entries,
    required this.enabled,
    required this.onOpen,
  });

  final List<RecentRoomEntry> entries;
  final bool enabled;
  final Future<void> Function(RecentRoomEntry entry) onOpen;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppDecorations.surfaceCard(context),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ListTile(
              enabled: enabled,
              leading: const Icon(Icons.history_rounded),
              title: Text(entries[i].name),
              subtitle: Text(entries[i].code),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: enabled ? () => unawaited(onOpen(entries[i])) : null,
            ),
          ],
        ],
      ),
    );
  }
}
