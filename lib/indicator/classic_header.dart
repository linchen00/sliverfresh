import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliverfresh/indicator/custom_header.dart';

import '../core/fresh_state.dart';

class ClassicHeader extends StatelessWidget {
  const ClassicHeader({
    super.key,
    this.height = 60,
    this.idleText = '下拉刷新',
    this.armedText = '释放立即刷新',
    this.refreshingText = '正在刷新…',
    this.completedText = '刷新成功',
    this.failedText = '刷新失败',
  });

  final double height;
  final String idleText;
  final String armedText;
  final String refreshingText;
  final String completedText;
  final String failedText;

  @override
  Widget build(BuildContext context) {
    return CustomHeader(
      builder: (context, status, extent) {
        return SizedBox(
          height: height, // 必须有确定高度，它就是刷新时撑住的高度
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _icon(status),
              const SizedBox(width: 8),
              Text(_text(status)),
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

  String _text(RefreshStatus status) {
    switch (status) {
      case RefreshStatus.idle:
        return idleText;
      case RefreshStatus.armed:
        return armedText;
      case RefreshStatus.refreshing:
        return refreshingText;
      case RefreshStatus.completed:
        return completedText;
      case RefreshStatus.failed:
        return failedText;
    }
  }
}
