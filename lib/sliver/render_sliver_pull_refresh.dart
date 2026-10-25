import 'package:flutter/rendering.dart';

class RenderSliverPullRefresh extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  RenderSliverPullRefresh({required this._hasLayoutExtent, RenderBox? child}) {
    this.child = child;
  }

  bool _hasLayoutExtent;

  double _indicatorExtent = 0.0;

  double _appliedLayoutExtent = 0.0;

  bool get hasLayoutExtent => _hasLayoutExtent;

  set hasLayoutExtent(bool value) {
    if (value == _hasLayoutExtent) return;
    _hasLayoutExtent = value;
    markNeedsLayout();
  }

  double get indicatorExtent => _indicatorExtent;

  @override
  void performLayout() {
    final double overscrolled = constraints.overlap < 0.0
        ? -constraints.overlap
        : 0.0;

    child!.layout(
      constraints.asBoxConstraints(maxExtent: double.infinity),
      parentUsesSize: true,
    );
    _indicatorExtent = child!.size.height;

    final double layoutExtent = _hasLayoutExtent ? indicatorExtent : 0.0;

    if (layoutExtent != _appliedLayoutExtent) {
      final correction = layoutExtent - _appliedLayoutExtent;
      debugPrint(
        'CORRECTION $correction  scrollOffset=${constraints.scrollOffset}',
      );
      _appliedLayoutExtent = layoutExtent;
      geometry = SliverGeometry(scrollOffsetCorrection: correction);
      return;
    }

    final double paintExtent = overscrolled + layoutExtent;

    geometry = SliverGeometry(
      scrollExtent: layoutExtent,
      paintExtent: paintExtent,
      paintOrigin: -overscrolled,
      layoutExtent: layoutExtent,
      maxPaintExtent: paintExtent,
    );
  }

  double _childOffsetY() => geometry!.paintExtent - child!.size.height;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || !geometry!.visible) return;
    context.paintChild(child!, offset + Offset(0, _childOffsetY()));
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    transform.translateByDouble(0.0, _childOffsetY(), 0.0, 1.0);
  }
}
