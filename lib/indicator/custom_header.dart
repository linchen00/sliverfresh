import 'package:flutter/widgets.dart';

import '../core/fresh_state.dart';
import 'fresh_scope.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    RefreshStatus status,
    double extent,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    final scope = RefreshScope.of(context);
    return builder(context, scope.status, scope.extent);
  }
}
