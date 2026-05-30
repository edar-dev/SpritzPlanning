import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';

class ParticipantAvatar extends StatelessWidget {
  const ParticipantAvatar({
    super.key,
    required this.nickname,
    required this.isFacilitator,
    this.hasVoted = false,
    this.showVoteStatus = false,
  });

  final String nickname;
  final bool isFacilitator;
  final bool hasVoted;
  final bool showVoteStatus;

  @override
  Widget build(BuildContext context) {
    final initial = nickname.isNotEmpty ? nickname[0].toUpperCase() : '?';
    final avatarColor = isFacilitator
        ? const Color(AppColors.spritzOrange)
        : const Color(AppColors.oliveGreen);

    return SizedBox(
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
          if (isFacilitator) ...[
            const SizedBox(height: 2),
            Text(
              AppStrings.barman,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(AppColors.spritzOrange),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
