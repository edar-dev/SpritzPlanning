import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';

class RoomCodeDisplay extends StatelessWidget {
  const RoomCodeDisplay({
    super.key,
    required this.code,
    this.onShare,
  });

  final String code;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(AppColors.barCounter),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppStrings.codiceBancone,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(AppColors.darkWood),
                  ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              code,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: const Color(AppColors.spritzOrange),
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Codice copiato!')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text(AppStrings.copyCode),
                ),
                if (onShare != null) ...[
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text(AppStrings.shareCode),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
