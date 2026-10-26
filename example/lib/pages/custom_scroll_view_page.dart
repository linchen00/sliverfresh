import 'package:flutter/material.dart';
import 'package:sliverfresh/sliverfresh.dart';

/// 不用 Refreshable，直接把两个 sliver 放进自己的 CustomScrollView
class CustomScrollViewPage extends StatefulWidget {
  const CustomScrollViewPage({super.key});

  @override
  State<CustomScrollViewPage> createState() => _CustomScrollViewPageState();
}

class _CustomScrollViewPageState extends State<CustomScrollViewPage> {
  final state = FreshState();
  int count = 20;

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('直接用 sliver')),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPullRefresh(
            state: state,
            triggerDistance: 60,
            child: const ClassicHeader(),
            onRefresh: () async {
              await Future<void>.delayed(const Duration(seconds: 1));
              if (mounted) state.refreshCompleted();
            },
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 120,
              color: Colors.orange.shade200,
              alignment: Alignment.center,
              child: const Text('banner'),
            ),
          ),
          SliverGrid.count(
            crossAxisCount: 3,
            children: [
              for (var i = 0; i < 6; i++)
                Container(
                  margin: const EdgeInsets.all(4),
                  color: Colors.teal.shade100,
                ),
            ],
          ),
          SliverList.builder(
            itemCount: count,
            itemBuilder: (_, i) => ListTile(title: Text('item $i')),
          ),
          SliverPushLoad(
            state: state,
            triggerDistance: 60,
            child: const ClassicFooter(),
            onLoad: () async {
              await Future<void>.delayed(const Duration(seconds: 1));
              if (!mounted) return;
              setState(() => count += 10);
              state.loadComplete();
            },
          ),
        ],
      ),
    );
  }
}
