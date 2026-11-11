import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../labels.dart';
import '../view_models/view_state.dart';

/// Shown while a screen's data is loading.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: CircularProgressIndicator(semanticsLabel: context.l10n.loading),
  );
}

/// Shown when a list has loaded but has nothing to show.
class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space5),
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: scheme.primary.withValues(alpha: .6)),
              const SizedBox(height: AppTheme.space4),
              Text(message, textAlign: TextAlign.center),
              if (onAction != null) ...[
                const SizedBox(height: AppTheme.space4),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when loading failed. Offers a retry when [onRetry] is given.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppTheme.space4),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.space4),
              FilledButton(
                onPressed: onRetry,
                child: Text(context.l10n.tryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shows the right view for a [ViewState] and cross-fades between them.
class StateSwitcher<T> extends StatelessWidget {
  const StateSwitcher({
    required this.state,
    required this.loaded,
    required this.empty,
    this.onRetry,
    super.key,
  });

  final ViewState<T> state;
  final Widget Function(T data) loaded;
  final Widget empty;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppTheme.medium,
      switchInCurve: Curves.easeOut,
      child: switch (state) {
        Loading() => const LoadingView(key: ValueKey('loading')),
        Empty() => KeyedSubtree(key: const ValueKey('empty'), child: empty),
        Failed(:final error) => ErrorView(
          key: const ValueKey('failed'),
          message: context.l10n.error(error),
          onRetry: onRetry,
        ),
        Loaded(:final data) => KeyedSubtree(
          key: const ValueKey('loaded'),
          child: loaded(data),
        ),
      },
    );
  }
}

/// Fades and slides its child in when first built. [index] staggers the
/// start, so list items appear one after another.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({required this.child, this.index = 0, super.key});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final delay = (index.clamp(0, 10)) * 50;
    final total = AppTheme.medium.inMilliseconds + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// A number that counts up to [value] whenever it changes.
class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber({
    required this.value,
    required this.format,
    this.style,
    super.key,
  });

  final double value;
  final String Function(double) format;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: value),
    duration: AppTheme.slow,
    curve: Curves.easeOutCubic,
    builder: (context, v, _) => Text(format(v), style: style),
  );
}
