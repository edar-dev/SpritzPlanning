import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/recent_rooms_storage.dart';
import '../../core/storage/session_storage.dart';
import '../../core/theme/app_decorations.dart';
/// Home welcome: primary actions, recent rooms, secondary tools in sections.
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
    required this.onOrg,
    required this.onWorkspace,
    required this.onPlan,
    required this.onOpsHealth,
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
  final void Function(RecentRoomEntry entry) onOpenRecent;
  final VoidCallback? onTemplate;
  final VoidCallback? onOrg;
  final VoidCallback? onWorkspace;
  final VoidCallback? onPlan;
  final VoidCallback? onOpsHealth;
  final VoidCallback? onArchive;

  bool get _enabled => configured && !isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

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
        _SectionLabel(text: l10n.homeGetStarted),
        const SizedBox(height: 12),
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 20),
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: scheme.outline.withValues(alpha: 0.5),
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            shape: const Border(),
            collapsedShape: const Border(),
            title: Text(
              l10n.homeMoreOptions,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            children: [
              _ManageListTile(
                icon: Icons.groups_outlined,
                title: l10n.orgTitle,
                subtitle: l10n.orgManageSubtitle,
                onTap: _enabled ? onOrg : null,
              ),
              _ManageListTile(
                icon: Icons.business_outlined,
                title: l10n.workspaceTitle,
                subtitle: l10n.workspaceManageSubtitle,
                onTap: _enabled ? onWorkspace : null,
              ),
              _ManageListTile(
                icon: Icons.workspace_premium_outlined,
                title: l10n.planUpgradeTitle,
                subtitle: l10n.planManageSubtitle,
                onTap: onPlan,
              ),
              _ManageListTile(
                icon: Icons.monitor_heart_outlined,
                title: l10n.opsHealthTitle,
                subtitle: l10n.opsHealthSubtitle,
                onTap: _enabled ? onOpsHealth : null,
              ),
              if (archiveCount > 0)
                _ManageListTile(
                  icon: Icons.archive_outlined,
                  title: l10n.pastSessions,
                  subtitle: '$archiveCount',
                  onTap: onArchive,
                ),
            ],
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
  final void Function(RecentRoomEntry entry) onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: AppDecorations.surfaceCard(context, radius: AppDecorations.radiusMd),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: Column(
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0) Divider(height: 1, color: scheme.outline.withValues(alpha: 0.6)),
              _RecentRoomTile(
                entry: entries[i],
                enabled: enabled,
                onTap: () => onOpen(entries[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentRoomTile extends StatelessWidget {
  const _RecentRoomTile({
    required this.entry,
    required this.enabled,
    required this.onTap,
  });

  final RecentRoomEntry entry;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 22,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.code,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            letterSpacing: 0.8,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageListTile extends StatelessWidget {
  const _ManageListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, size: 22, color: scheme.onSurfaceVariant),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: scheme.onSurfaceVariant,
      ),
      enabled: enabled,
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onTap!();
            }
          : null,
    );
  }
}
