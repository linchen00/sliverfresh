import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliverfresh/indicator/custom_header.dart';

import '../core/fresh_state.dart';
import '../l10n/sliver_fresh_localizations.dart';

class ClassicHeader extends StatelessWidget {
  const ClassicHeader({
    super.key,
    this.height = 60,
    this.idleText,
    this.armedText,
    this.refreshingText,
    this.completedText,
    this.failedText,
  });

  final double height;
  final String? idleText;
  final String? armedText;
  final String? refreshingText;
  final String? completedText;
  final String? failedText;

  @override
  Widget build(BuildContext context) {
    return CustomHeader(
      builder: (context, status, extent) {
        return SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _icon(status),
              const SizedBox(width: 8),
              Text(_text(context, status)),
            ],
          ),
        );
      },
    );
  }

  Widget _icon(RefreshStatus status) {
    switch (status) {
      case RefreshStatus.idle:
        return const Icon(Icons.arrow_downward, size: 20);
      case RefreshStatus.armed:
        return const Icon(Icons.arrow_upward, size: 20);
      case RefreshStatus.refreshing:
        return CupertinoActivityIndicator();
      case RefreshStatus.completed:
        return const Icon(Icons.check, size: 20);
      case RefreshStatus.failed:
        return const Icon(Icons.error_outline, size: 20);
    }
  }

  String _text(BuildContext context, RefreshStatus status) {
    final l10n = SliverFreshLocalizations.of(context);
    switch (status) {
      case RefreshStatus.idle:
        return idleText ?? l10n.refreshIdleText;
      case RefreshStatus.armed:
        return armedText ?? l10n.refreshArmedText;
      case RefreshStatus.refreshing:
        return refreshingText ?? l10n.refreshingText;
      case RefreshStatus.completed:
        return completedText ?? l10n.refreshCompletedText;
      case RefreshStatus.failed:
        return failedText ?? l10n.refreshFailedText;
    }
  }
}
