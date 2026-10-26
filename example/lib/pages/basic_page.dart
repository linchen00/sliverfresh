import 'package:flutter/material.dart';
import 'package:sliverfresh/sliverfresh.dart';

class BasicPage extends StatefulWidget {
  const BasicPage({super.key});

  @override
  State<BasicPage> createState() => _BasicPageState();
}

class _BasicPageState extends State<BasicPage> {
  final state = FreshState();
  final controller = FreshController();
  int count = 5;

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => count = 5);
    state.refreshCompleted();
  }

  Future<void> _load() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    if (count >= 50) {
      state.loadNoData();
      return;
    }
    setState(() => count += 10);
    state.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基础用法'),
        actions: [
          TextButton(
            onPressed: controller.requestRefresh,
            child: const Text('刷新'),
          ),
          TextButton(
            onPressed: controller.requestLoad,
            child: const Text('加载'),
          ),
        ],
      ),
      body: Refreshable(
        state: state,
        controller: controller,
        onRefresh: _refresh,
        onLoad: _load,
        slivers: [
          SliverList.builder(
            itemCount: count,
            itemBuilder: (_, i) => ListTile(title: Text('item $i')),
          ),
        ],
      ),
    );
  }
}
