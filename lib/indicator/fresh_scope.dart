import 'package:flutter/widgets.dart';

import '../core/fresh_state.dart';

class RefreshScope extends InheritedWidget {
  const RefreshScope({
    super.key,
    required this.status,
    required this.extent,
    required super.child,
  });

  final RefreshStatus status;
  final double extent;

  static RefreshScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RefreshScope>();
    assert(
      scope != null,
      'RefreshScope not found: header 必须放在 SliverPullRefresh 里',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(RefreshScope old) =>
      status != old.status || extent != old.extent;
}

class LoadScope extends InheritedWidget {
  const LoadScope({
    super.key,
    required this.status,
    required this.extent,
    required super.child,
  });

  final LoadStatus status;
  final double extent;

  static LoadScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LoadScope>();
    assert(scope != null, 'LoadScope not found: footer 必须放在 SliverPushLoad 里');
    return scope!;
  }

  @override
  bool updateShouldNotify(LoadScope old) =>
      status != old.status || extent != old.extent;
}
