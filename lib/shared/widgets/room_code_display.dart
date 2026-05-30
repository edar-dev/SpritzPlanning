import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

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
    return DecoratedBox(
      decoration: AppDecorations.surfaceCard(radius: AppDecorations.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stackButtons = constraints.maxWidth < 420;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.codiceBancone,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(AppColors.textSecondary),
                      ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.primarySoft),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SelectableText(
                      code,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                            color: const Color(AppColors.spritzOrange),
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (stackButtons)
                  _buildStackedActions(context)
                else
                  _buildRowActions(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStackedActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => _copyCode(context),
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text(AppStrings.copyCode),
        ),
        if (onShare != null) ...[
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text(AppStrings.shareCode),
          ),
        ],
      ],
    );
  }

  Widget _buildRowActions(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => _copyCode(context),
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text(AppStrings.copyCode),
        ),
        if (onShare != null)
          FilledButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text(AppStrings.shareCode),
          ),
      ],
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Codice copiato!')),
    );
  }
}
