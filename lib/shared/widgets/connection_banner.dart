import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(AppColors.errorRed),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
