import 'package:flutter/material.dart';

import '../core/fresh_controller.dart';
import '../core/fresh_state.dart';
import '../indicator/classic_footer.dart';
import '../indicator/classic_header.dart';
import '../sliver/sliver_pull_refresh.dart';
import '../sliver/sliver_push_load.dart';

/// 便捷封装：自动把 SliverPullRefresh 放在最前、SliverPushLoad 放在最后。
/// 需要更自由的位置时，直接手写 CustomScrollView 使用这两个 sliver。
class Refreshable extends StatelessWidget {
  const Refreshable({
    super.key,
    required this.state,
    required this.slivers,
    this.controller,
    this.onRefresh,
    this.onLoad,
    this.physics,
    this.header = const ClassicHeader(),
    this.footer = const ClassicFooter(),
    this.refreshTriggerDistance = 60,
    this.loadTriggerDistance = 60,
    this.autoLoadWhenShort = true,
  });

  final FreshState state;
  final List<Widget> slivers;
  final FreshController? controller;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoad;
  final ScrollPhysics? physics;
  final Widget header;
  final Widget footer;
  final double refreshTriggerDistance;
  final double loadTriggerDistance;
  final bool autoLoadWhenShort;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics:
          physics ??
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        if (onRefresh != null)
          SliverPullRefresh(
            state: state,
            controller: controller,
            onRefresh: onRefresh,
            triggerDistance: refreshTriggerDistance,
            child: header,
          ),
        ...slivers,
        if (onLoad != null)
          SliverPushLoad(
            state: state,
            controller: controller,
            onLoad: onLoad,
            triggerDistance: loadTriggerDistance,
            autoLoadWhenShort: autoLoadWhenShort,
            child: footer,
          ),
      ],
    );
  }
}
