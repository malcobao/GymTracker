import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/widgets/state_views.dart';

/// One headline number with its label; the number counts up when it changes.
class KpiTile extends StatelessWidget {
  const KpiTile({
    required this.label,
    required this.value,
    required this.format,
    required this.icon,
    this.caption,
    this.width = 172,
    super.key,
  });

  final String label;
  final double value;
  final String Function(double) format;
  final IconData icon;
  final String? caption;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Card(
        margin: const EdgeInsets.all(AppTheme.space1),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: AppTheme.space1),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.space2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: AnimatedNumber(
                  value: value,
                  format: format,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
