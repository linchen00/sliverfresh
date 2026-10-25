import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:sliverfresh/indicator/fresh_scope.dart';

import '../core/fresh_controller.dart';
import '../core/fresh_state.dart';
import 'render_sliver_push_load.dart';

class SliverPushLoad extends StatefulWidget {
  const SliverPushLoad({
    super.key,
    required this.state,
    required this.child,
    required this.triggerDistance,
    this.controller,
    this.onLoad,
    this.autoLoadWhenShort = true,
  });

  final FreshState state;
  final FreshController? controller;

  /// 加载结果由业务通过 state 报告：loadComplete / loadFailed / loadNoData。
  /// 抛出异常时会自动 loadFailed。
  final Future<void> Function()? onLoad;
  final Widget child;
  final double triggerDistance;

  /// 内容不足一屏时自动触发加载（内容没有增长则不再重复触发）
  final bool autoLoadWhenShort;

  @override
  State<SliverPushLoad> createState() => _SliverPushLoadState();
}

class _SliverPushLoadState extends State<SliverPushLoad> {
  ScrollNotificationObserverState? _observer;

  double _extent = 0;
  double _lastPulled = 0;
  bool _fingerDown = false;
  bool _loading = false; // 同步的重入保护，不依赖延迟写入的状态
  bool _requesting = false;
  double? _lastAutoPreceding;
  late LoadStatus _lastStatus;

  @override
  void initState() {
    super.initState();
    _lastStatus = widget.state.loadState.value;
    widget.state.loadState.addListener(_onStatusChanged);
    widget.controller?.attachLoad(_requestLoad);

    // 外部持有的 state 可能遗留过渡状态，归位（noMore 是数据结论，保留）
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final s = widget.state.loadState.value;
      if (s == LoadStatus.armed ||
          s == LoadStatus.loading ||
          s == LoadStatus.failed) {
        widget.state.loadState.value = LoadStatus.idle;
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
  void didUpdateWidget(SliverPushLoad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      oldWidget.state.loadState.removeListener(_onStatusChanged);
      widget.state.loadState.addListener(_onStatusChanged);
      _lastStatus = widget.state.loadState.value;
      _loading = false;
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detachLoad(_requestLoad);
      widget.controller?.attachLoad(_requestLoad);
    }
  }

  @override
  void dispose() {
    widget.controller?.detachLoad(_requestLoad);
    widget.state.loadState.removeListener(_onStatusChanged);
    _observer?.removeListener(_onScroll);
    super.dispose();
  }

  void _onStatusChanged() {
    final status = widget.state.loadState.value;
    // noMore 被重置后，内容长度的基准作废，允许再次自动加载
    if (_lastStatus == LoadStatus.noMore && status == LoadStatus.idle) {
      _lastAutoPreceding = null;
    }
    if (status != LoadStatus.loading) _loading = false;
    _lastStatus = status;
  }

  void _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return;
    if (widget.onLoad == null || _loading) return;

    final status = widget.state.loadState.value;
    if (status == LoadStatus.loading || status == LoadStatus.noMore) return;

    final pulled = math.max(0.0, n.metrics.pixels - n.metrics.maxScrollExtent);

    if (n is ScrollUpdateNotification) {
      final canTrack = status == LoadStatus.idle || status == LoadStatus.armed;
      if (canTrack && pulled != _extent) {
        setState(() => _extent = pulled);
      }

      if (n.dragDetails != null) {
        _fingerDown = true;
        if (status == LoadStatus.idle && pulled >= widget.triggerDistance) {
          widget.state.loadState.value = LoadStatus.armed;
        } else if (status == LoadStatus.armed &&
            pulled < widget.triggerDistance) {
          widget.state.loadState.value = LoadStatus.idle;
        }
      } else if (_fingerDown && pulled != _lastPulled) {
        // 手指已松开
        _fingerDown = false;
        if (status == LoadStatus.armed ||
            (status == LoadStatus.failed && pulled >= widget.triggerDistance)) {
          _startLoad();
        }
      }
      _lastPulled = pulled;
    } else if (n is ScrollEndNotification) {
      _fingerDown = false;
    }
  }

  void _startLoad() {
    final onLoad = widget.onLoad;
    if (onLoad == null || _loading) return;
    _loading = true;
    _fingerDown = false;
    _extent = 0;
    widget.state.loadState.value = LoadStatus.loading;
    _run(widget.state, onLoad);
  }

  Future<void> _run(FreshState state, Future<void> Function() onLoad) async {
    try {
      await onLoad();
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'sliverfresh',
          context: ErrorDescription('while running onLoad'),
        ),
      );
      state.loadFailed();
    }
  }

  /// controller.requestLoad()：像手指上拉一样把 footer 拉出来，再开始加载
  Future<void> _requestLoad() async {
    if (_loading || _requesting || widget.onLoad == null) return;
    final status = widget.state.loadState.value;
    if (status == LoadStatus.failed) {
      _startLoad(); // footer 已经在占位，直接重试
      return;
    }
    if (status != LoadStatus.idle) return;

    final position = Scrollable.maybeOf(context)?.position;
    final render = context.findRenderObject();
    if (position == null || render is! RenderSliverPushLoad) return;

    _requesting = true;
    final target = position.maxScrollExtent + render.indicatorExtent;
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
    if (widget.state.loadState.value != LoadStatus.idle) return;
    if ((position.pixels - target).abs() > 1) return; // 被手指打断
    _startLoad();
  }

  /// 内容不足一屏时自动加载；内容没有增长就不再触发，避免死循环
  void _onContentLayout(double preceding, bool unfilled) {
    if (!mounted || !widget.autoLoadWhenShort || !unfilled) return;
    if (widget.onLoad == null || _loading) return;
    if (widget.state.loadState.value != LoadStatus.idle) return;
    if (widget.state.refreshState.value != RefreshStatus.idle) return;
    final last = _lastAutoPreceding;
    if (last != null && preceding <= last) return;
    _lastAutoPreceding = preceding;
    _startLoad();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LoadStatus>(
      valueListenable: widget.state.loadState,
      builder: (context, status, _) {
        final hold =
            status == LoadStatus.loading ||
            status == LoadStatus.failed ||
            status == LoadStatus.noMore;
        return _PushLoadRenderWidget(
          hasLayoutExtent: hold,
          onContentLayout: _onContentLayout,
          child: LoadScope(
            status: status,
            extent: _extent,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _PushLoadRenderWidget extends SingleChildRenderObjectWidget {
  const _PushLoadRenderWidget({
    required this.hasLayoutExtent,
    required this.onContentLayout,
    super.child,
  });

  final bool hasLayoutExtent;
  final PushLayoutCallback onContentLayout;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderSliverPushLoad(
    hasLayoutExtent: hasLayoutExtent,
    onContentLayout: onContentLayout,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverPushLoad renderObject,
  ) {
    renderObject
      ..hasLayoutExtent = hasLayoutExtent
      ..onContentLayout = onContentLayout;
  }
}
