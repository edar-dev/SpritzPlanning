import 'package:flutter/material.dart';

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isFacilitator
                  ? const Color(AppColors.spritzOrange)
                  : const Color(AppColors.oliveGreen),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (showVoteStatus)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: hasVoted ? Colors.green : Colors.grey.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            if (isFacilitator)
              Positioned(
                top: -4,
                right: -4,
                child: Icon(
                  Icons.local_bar,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 64,
          child: Text(
            nickname,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
