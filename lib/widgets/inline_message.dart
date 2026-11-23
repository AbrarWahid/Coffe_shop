import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum InlineMessageTone { error, info, success }

/// Animated banner for form-level errors and contextual hints.
/// Renders nothing when [message] is null.
class InlineMessage extends StatelessWidget {
  const InlineMessage({
    super.key,
    required this.message,
    this.tone = InlineMessageTone.error,
  });

  final String? message;
  final InlineMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (tone) {
      InlineMessageTone.error => (
        AppColors.danger.withValues(alpha: 0.1),
        AppColors.danger,
        Icons.error_outline_rounded,
      ),
      InlineMessageTone.info => (
        AppColors.copperSoft,
        AppColors.copperDeep,
        Icons.info_outline_rounded,
      ),
      InlineMessageTone.success => (
        AppColors.success.withValues(alpha: 0.12),
        AppColors.success,
        Icons.check_circle_outline_rounded,
      ),
    };
    return AnimatedSize(
      duration: AppMotion.medium,
      curve: AppMotion.curve,
      alignment: Alignment.topCenter,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message!,
                        style: AppText.body(
                          13,
                          weight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
