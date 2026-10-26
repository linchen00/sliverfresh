import 'package:flutter/material.dart';
import 'package:sliverfresh/sliverfresh.dart';

class AnimatedListPage extends StatefulWidget {
  const AnimatedListPage({super.key});

  @override
  State<AnimatedListPage> createState() => _AnimatedListPageState();
}

class _AnimatedListPageState extends State<AnimatedListPage> {
  final state = FreshState();
  final listKey = GlobalKey<SliverAnimatedListState>();
  final items = <int>[for (var i = 0; i < 10; i++) i];
  int next = 10;

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  Widget _tile(int value, Animation<double> animation) => SizeTransition(
    sizeFactor: animation,
    child: ListTile(title: Text('item $value')),
  );

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    items.insert(0, next);
    listKey.currentState?.insertItem(0);
    next++;
    state.refreshCompleted();
  }

  Future<void> _load() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    for (var i = 0; i < 3; i++) {
      items.add(next++);
      listKey.currentState?.insertItem(items.length - 1);
    }
    state.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SliverAnimatedList')),
      body: Refreshable(
        state: state,
        onRefresh: _refresh,
        onLoad: _load,
        slivers: [
          SliverAnimatedList(
            key: listKey,
            initialItemCount: items.length,
            itemBuilder: (context, index, animation) =>
                _tile(items[index], animation),
          ),
        ],
      ),
    );
  }
}
