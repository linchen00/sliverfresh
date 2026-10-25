import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sliverfresh/core/fresh_controller.dart';
import 'package:sliverfresh/core/fresh_state.dart';
import 'package:sliverfresh/indicator/fresh_scope.dart';
import 'package:sliverfresh/sliver/render_sliver_pull_refresh.dart';

class SliverPullRefresh extends StatefulWidget {
  const SliverPullRefresh({
    super.key,
    required this.state,
    this.controller,
    this.onRefresh,
    required this.triggerDistance,
    required this.child,
  });

  final FreshState state;
  final FreshController? controller;
  final AsyncCallback? onRefresh;
  final double triggerDistance;
  final Widget child;

  @override
  State<SliverPullRefresh> createState() => _SliverPullRefreshState();
}

class _SliverPullRefreshState extends State<SliverPullRefresh> {
  ScrollNotificationObserverState? _observer;
  double _extent = 0;
  double _lastPulled = 0;
  bool _collapsing = false;
  bool _collapseSawPull = false; // 收起开始后，是否已经看到过 pulled > 0

  bool _hasLayoutExtent = false;
  bool _fingerDown = false;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    widget.state.refreshState.addListener(_onStatusChanged);
    widget.controller?.attachRefresh(_requestRefresh);

    // 遗留的过渡状态归位。不能直接写：initState 在 build 阶段，
    // 别的监听者会在 build 期间 setState 而报错，所以推迟到帧后
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.state.refreshState.value != RefreshStatus.idle) {
        widget.state.refreshToIdle();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _observer?.removeListener(_onScroll);
    _observer = ScrollNotificationObserver.maybeOf(context);
    _observer?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(SliverPullRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state != widget.state) {
      oldWidget.state.refreshState.removeListener(_onStatusChanged);
      widget.state.refreshState.addListener(_onStatusChanged);
    }

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detachRefresh(_requestRefresh);
      widget.controller?.attachRefresh(_requestRefresh);
    }
  }

  @override
  void dispose() {
    widget.controller?.detachRefresh(_requestRefresh);
    widget.state.refreshState.removeListener(_onStatusChanged);
    _observer?.removeListener(_onScroll);
    super.dispose();
  }

  Future<void> _requestRefresh() async {
    if (_requesting) return;
    if (widget.state.refreshState.value != RefreshStatus.idle) return;

    final position = Scrollable.maybeOf(context)?.position;
    final render = context.findRenderObject();
    if (position == null || render is! RenderSliverPullRefresh) return;

    _requesting = true;
    final target = -render.indicatorExtent;
    try {
      await position.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } finally {
      _requesting = false;
    }

    if (!mounted) return;
    if (widget.state.refreshState.value != RefreshStatus.idle) return;
    if ((position.pixels - target).abs() > 1) return; // 动画被用户手指打断了
    _startRefresh();
  }

  void _onStatusChanged() {
    final status = widget.state.refreshState.value;
    if (status == RefreshStatus.completed || status == RefreshStatus.failed) {
      _collapse(status);
    }
  }

  Future<void> _collapse(RefreshStatus shown) async {
    // 停留一会儿，让用户看到"成功/失败"
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    // 停留期间状态被改过（比如又触发了新的刷新），就不再收起
    if (widget.state.refreshState.value != shown) return;

    _collapsing = true;
    _collapseSawPull = false;
    // 关闭占位，开始收起；状态保持 completed / failed，
    // 等回弹结束后由 _onScroll 切回 idle
    setState(() => _hasLayoutExtent = false);
  }

  void _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return;

    final pulled = n.metrics.pixels < 0 ? -n.metrics.pixels : 0.0;

    // 收起阶段：等回弹结束（pulled 先大于 0，再回到 0）
    if (_collapsing) {
      if (n is ScrollUpdateNotification) {
        if (pulled > 0) {
          _collapseSawPull = true;
        } else if (_collapseSawPull) {
          _collapsing = false;
          _fingerDown = false;
          _lastPulled = 0;
          setState(() => _extent = 0);
          widget.state.refreshToIdle();
        }
      }
      return;
    }

    // 只在 idle、armed 时响应手指
    final status = widget.state.refreshState.value;
    if (status != RefreshStatus.idle && status != RefreshStatus.armed) return;

    if (n is ScrollUpdateNotification) {
      // 1. 更新给 header 的距离，只在变化时重建
      if (pulled != _extent) {
        setState(() => _extent = pulled);
      }

      // 2. 状态推进
      if (n.dragDetails != null) {
        _fingerDown = true;
        if (pulled >= widget.triggerDistance && status == RefreshStatus.idle) {
          widget.state.refreshState.value = RefreshStatus.armed;
        } else if (pulled < widget.triggerDistance &&
            status == RefreshStatus.armed) {
          widget.state.refreshState.value = RefreshStatus.idle;
        }
      } else if (_fingerDown && pulled != _lastPulled) {
        // 手指已松开：上一条还在拖，这一条没有 dragDetails 且位置变了
        _fingerDown = false;
        if (status == RefreshStatus.armed) _startRefresh();
      }
      _lastPulled = pulled;
    } else if (n is ScrollEndNotification) {
      _fingerDown = false;
    }
  }

  void _startRefresh() {
    _collapsing = false;
    _collapseSawPull = false;
    _extent = 0;
    widget.state.refreshing();
    setState(() => _hasLayoutExtent = true);
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _PullRefreshRenderWidget(
      hasLayoutExtent: _hasLayoutExtent,
      child: ValueListenableBuilder(
        valueListenable: widget.state.refreshState,
        builder: (context, status, _) =>
            RefreshScope(status: status, extent: _extent, child: widget.child),
      ),
    );
  }
}

class _PullRefreshRenderWidget extends SingleChildRenderObjectWidget {
  const _PullRefreshRenderWidget({required this.hasLayoutExtent, super.child});

  final bool hasLayoutExtent;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSliverPullRefresh(hasLayoutExtent: hasLayoutExtent);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverPullRefresh renderObject,
  ) {
    renderObject.hasLayoutExtent = hasLayoutExtent;
  }
}
