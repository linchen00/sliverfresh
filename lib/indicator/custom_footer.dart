import 'package:flutter/widgets.dart';

import '../core/fresh_state.dart';
import 'fresh_scope.dart';

/// builder 返回的 widget 必须有确定高度，这个高度就是加载时 footer 占的位置。
class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key, required this.builder});

  final Widget Function(BuildContext context, LoadStatus status, double extent)
  builder;

  @override
  Widget build(BuildContext context) {
    final scope = LoadScope.of(context);
    return builder(context, scope.status, scope.extent);
  }
}
