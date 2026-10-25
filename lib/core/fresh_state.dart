import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

enum RefreshStatus { idle, armed, refreshing, completed, failed }

enum LoadStatus { idle, armed, loading, failed, noMore }

class FreshState {
  FreshState({
    RefreshStatus initialRefreshStatus = RefreshStatus.idle,
    LoadStatus initialLoadStatus = LoadStatus.idle,
  }) {
    refreshState = ValueNotifier(initialRefreshStatus);
    loadState = ValueNotifier(initialLoadStatus);
  }

  late final ValueNotifier<RefreshStatus> refreshState;
  late final ValueNotifier<LoadStatus> loadState;

  void dispose() {
    refreshState.dispose();
    loadState.dispose();
  }

  void refreshToIdle() {
    refreshState.value = RefreshStatus.idle;
  }

  void refreshing() {
    refreshState.value = RefreshStatus.refreshing;
  }

  void refreshCompleted() {
    refreshState.value = RefreshStatus.completed;
    resetNoData();
  }

  void refreshFailed() {
    refreshState.value = RefreshStatus.failed;
  }

  void loading() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      loadState.value = LoadStatus.loading;
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void loadComplete() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      loadState.value = LoadStatus.idle;
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void loadFailed() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      loadState.value = LoadStatus.failed;
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void loadNoData() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      loadState.value = LoadStatus.noMore;
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void resetNoData() {
    if (loadState.value == LoadStatus.noMore) {
      loadState.value = LoadStatus.idle;
    }
  }
}
