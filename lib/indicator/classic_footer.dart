import 'package:flutter/material.dart';

import '../core/fresh_state.dart';
import '../l10n/sliver_fresh_localizations.dart';
import 'custom_footer.dart';

class ClassicFooter extends StatelessWidget {
  const ClassicFooter({
    super.key,
    this.height = 60,
    this.idleText,
    this.armedText,
    this.loadingText,
    this.failedText,
    this.noMoreText,
  });

  final double height;
  final String? idleText;
  final String? armedText;
  final String? loadingText;
  final String? failedText;
  final String? noMoreText;

  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      builder: (context, status, extent) {
        final icon = _icon(status);
        return SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon, const SizedBox(width: 8)],
              Text(_text(context, status)),
            ],
          ),
        );
      },
    );
  }

  Widget? _icon(LoadStatus status) {
    switch (status) {
      case LoadStatus.idle:
        return const Icon(Icons.arrow_upward, size: 20);
      case LoadStatus.armed:
        return const Icon(Icons.arrow_downward, size: 20);
      case LoadStatus.loading:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case LoadStatus.failed:
        return const Icon(Icons.error_outline, size: 20);
      case LoadStatus.noMore:
        return null;
    }
  }

  String _text(BuildContext context, LoadStatus status) {
    final l10n = SliverFreshLocalizations.of(context);
    switch (status) {
      case LoadStatus.idle:
        return idleText ?? l10n.loadIdleText;
      case LoadStatus.armed:
        return armedText ?? l10n.loadArmedText;
      case LoadStatus.loading:
        return loadingText ?? l10n.loadingText;
      case LoadStatus.failed:
        return failedText ?? l10n.loadFailedText;
      case LoadStatus.noMore:
        return noMoreText ?? l10n.loadNoMoreText;
    }
  }
}
