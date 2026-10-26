import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// 内容布局信息：前面所有 sliver 的总长度、是否没填满视口
typedef PushLayoutCallback =
    void Function(double precedingExtent, bool unfilled);

class RenderSliverPushLoad extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  RenderSliverPushLoad({
    required this._hasLayoutExtent,
    this.onContentLayout,
    RenderBox? child,
  }) {
    this.child = child;
  }

  bool get hasLayoutExtent => _hasLayoutExtent;
  bool _hasLayoutExtent;
  set hasLayoutExtent(bool value) {
    if (value == _hasLayoutExtent) return;
    _hasLayoutExtent = value;
    markNeedsLayout();
  }

  PushLayoutCallback? onContentLayout;

  double get indicatorExtent => _indicatorExtent;
  double _indicatorExtent = 0.0;

  double _reportedPreceding = -1.0;
  bool _reportedUnfilled = false;

  @override
  void performLayout() {
    child!.layout(
      constraints.asBoxConstraints(maxExtent: double.infinity),
      parentUsesSize: true,
    );
    _indicatorExtent = child!.size.height;

    final double layoutExtent = _hasLayoutExtent ? _indicatorExtent : 0.0;

    final double base = math.max(
      0.0,
      constraints.viewportMainAxisExtent -
          constraints.precedingScrollExtent -
          layoutExtent,
    );

    final double pulled = math.max(
      0.0,
      constraints.remainingPaintExtent - layoutExtent - base,
    );

    final double paintExtent = math.min(
      pulled + layoutExtent,
      constraints.remainingPaintExtent,
    );

    geometry = SliverGeometry(
      scrollExtent: layoutExtent,
      paintExtent: paintExtent,
      paintOrigin: 0.0,
      layoutExtent: math.min(layoutExtent, paintExtent),
      maxPaintExtent: pulled + layoutExtent,
    );

    _reportContent(
      constraints.precedingScrollExtent,
      constraints.precedingScrollExtent < constraints.viewportMainAxisExtent,
    );
  }

  void _reportContent(double preceding, bool unfilled) {
    if (preceding == _reportedPreceding && unfilled == _reportedUnfilled) {
      return;
    }
    _reportedPreceding = preceding;
    _reportedUnfilled = unfilled;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!attached) return;
      onContentLayout?.call(_reportedPreceding, _reportedUnfilled);
    });
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || !geometry!.visible) return;
    context.paintChild(child!, offset);
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}
