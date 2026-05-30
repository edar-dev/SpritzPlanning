import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/connection_status.dart';

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({
    super.key,
    this.status,
    this.message,
    this.onRefresh,
  }) : assert(status != null || message != null);

  final ConnectionStatus? status;
  final String? message;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final resolvedStatus = status ?? ConnectionStatus.disconnected;
    final resolvedMessage = message ?? resolvedStatus.bannerMessage;
    if (resolvedMessage == null) return const SizedBox.shrink();

    final backgroundColor = message != null
        ? const Color(AppColors.errorRed)
        : switch (resolvedStatus) {
            ConnectionStatus.disconnected => const Color(AppColors.errorRed),
            _ => const Color(AppColors.spritzOrangeDark),
          };

    final showSpinner =
        status != null && resolvedStatus.showSpinner && message == null;

    return Material(
      color: backgroundColor.withValues(alpha: 0.95),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              if (showSpinner)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  resolvedMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onRefresh != null)
                TextButton(
                  onPressed: onRefresh,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Aggiorna'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
