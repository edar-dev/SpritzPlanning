import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_config.dart';
import '../../core/l10n/l10n_extensions.dart';
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
      decoration: AppDecorations.surfaceCard(),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stackButtons = constraints.maxWidth < 420;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.codiceBancone,
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
          label: Text(context.l10n.copyCode),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showQrSheet(context),
          icon: const Icon(Icons.qr_code_2_rounded, size: 18),
          label: Text(context.l10n.showQr),
        ),
        if (onShare != null) ...[
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_rounded, size: 18),
            label: Text(context.l10n.shareCode),
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
          label: Text(context.l10n.copyCode),
        ),
        OutlinedButton.icon(
          onPressed: () => _showQrSheet(context),
          icon: const Icon(Icons.qr_code_2_rounded, size: 18),
          label: Text(context.l10n.showQr),
        ),
        if (onShare != null)
          FilledButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_rounded, size: 18),
            label: Text(context.l10n.shareCode),
          ),
      ],
    );
  }

  void _showQrSheet(BuildContext context) {
    final joinUrl = AppConfig.joinUrlForCode(code);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.qrBanconeTitle,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.qrBanconeHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: const Color(AppColors.textSecondary),
                      ),
                ),
                const SizedBox(height: 20),
                DecoratedBox(
                  decoration: AppDecorations.surfaceCard(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: QrImageView(
                      data: joinUrl,
                      size: 220,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  code,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        letterSpacing: 3,
                        fontWeight: FontWeight.w700,
                        color: const Color(AppColors.spritzOrange),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.codeCopied)),
    );
  }
}
