import 'package:flutter/foundation.dart';

class FreshController {
  VoidCallback? _refreshHandler;
  VoidCallback? _loadHandler;

  void attachRefresh(VoidCallback handler) => _refreshHandler = handler;

  void detachRefresh(VoidCallback handler) {
    if (_refreshHandler == handler) _refreshHandler = null;
  }

  void attachLoad(VoidCallback handler) => _loadHandler = handler;

  void detachLoad(VoidCallback handler) {
    if (_loadHandler == handler) _loadHandler = null;
  }

  void requestRefresh() => _refreshHandler?.call();

  void requestLoad() => _loadHandler?.call();
}
