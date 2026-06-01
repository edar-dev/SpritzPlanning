import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_colors.dart';

class ParticipantAvatar extends StatelessWidget {
  const ParticipantAvatar({
    super.key,
    required this.nickname,
    required this.isFacilitator,
    this.hasVoted = false,
    this.showVoteStatus = false,
    this.isAbsent = false,
    this.isObserver = false,
    this.onLongPress,
  });

  final String nickname;
  final bool isFacilitator;
  final bool hasVoted;
  final bool showVoteStatus;
  final bool isAbsent;
  final bool isObserver;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final initial = nickname.isNotEmpty ? nickname[0].toUpperCase() : '?';
    final avatarColor = isFacilitator
        ? const Color(AppColors.spritzOrange)
        : const Color(AppColors.oliveGreen);

    final avatar = SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFacilitator
                        ? const Color(AppColors.spritzOrange).withValues(alpha: 0.4)
                        : const Color(AppColors.border),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: avatarColor.withValues(alpha: 0.15),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: avatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              if (isObserver)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              if (showVoteStatus)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: hasVoted
                          ? const Color(AppColors.success)
                          : const Color(AppColors.border),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            nickname,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(AppColors.textPrimary),
                ),
          ),
          if (isObserver) ...[
            const SizedBox(height: 2),
            Text(
              context.l10n.observerBadge,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(AppColors.textSecondary),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ] else if (isFacilitator) ...[
            const SizedBox(height: 2),
            Text(
              context.l10n.barman,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(AppColors.spritzOrange),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ] else if (isAbsent) ...[
            const SizedBox(height: 2),
            Text(
              context.l10n.assente,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(AppColors.textSecondary),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );

    final semanticsLabel = _semanticsLabel(context);

    final wrapped = Semantics(
      label: semanticsLabel,
      child: avatar,
    );

    if (onLongPress == null) return wrapped;

    return GestureDetector(
      onLongPress: onLongPress,
      child: wrapped,
    );
  }

  String _semanticsLabel(BuildContext context) {
    final l10n = context.l10n;
    final parts = <String>[nickname];
    if (isObserver) parts.add(l10n.observerBadge);
    if (isFacilitator) parts.add(l10n.barman);
    if (showVoteStatus && hasVoted) {
      parts.add(l10n.voteSubmitted);
    }
    if (isAbsent) parts.add(l10n.assente);
    return parts.join(', ');
  }
}
