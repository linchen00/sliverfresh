import 'package:flutter/material.dart';

import '../core/fresh_state.dart';
import 'custom_footer.dart';

class ClassicFooter extends StatelessWidget {
  const ClassicFooter({
    super.key,
    this.height = 60,
    this.idleText = '上拉加载更多',
    this.armedText = '释放立即加载',
    this.loadingText = '正在加载…',
    this.failedText = '加载失败，上拉重试',
    this.noMoreText = '没有更多数据了',
  });

  final double height;
  final String idleText;
  final String armedText;
  final String loadingText;
  final String failedText;
  final String noMoreText;

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
              Text(_text(status)),
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

  String _text(LoadStatus status) {
    switch (status) {
      case LoadStatus.idle:
        return idleText;
      case LoadStatus.armed:
        return armedText;
      case LoadStatus.loading:
        return loadingText;
      case LoadStatus.failed:
        return failedText;
      case LoadStatus.noMore:
        return noMoreText;
    }
  }
}
