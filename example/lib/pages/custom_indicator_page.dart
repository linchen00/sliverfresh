import 'package:flutter/material.dart';
import 'package:sliverfresh/sliverfresh.dart';

class CustomIndicatorPage extends StatefulWidget {
  const CustomIndicatorPage({super.key});

  @override
  State<CustomIndicatorPage> createState() => _CustomIndicatorPageState();
}

class _CustomIndicatorPageState extends State<CustomIndicatorPage> {
  final state = FreshState();
  int count = 15;

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自定义指示器')),
      body: Refreshable(
        state: state,
        header: CustomHeader(
          builder: (context, status, extent) => SizedBox(
            height: 80, // 必须有确定高度
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(SliverFreshLocalizations.of(context).refreshText(status)),
                const SizedBox(height: 6),
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    value: status == RefreshStatus.refreshing
                        ? null
                        : (extent / 60).clamp(0.0, 1.0),
                  ),
                ),
              ],
            ),
          ),
        ),
        footer: CustomFooter(
          builder: (context, status, extent) => SizedBox(
            height: 50,
            child: Center(
              child: Text(SliverFreshLocalizations.of(context).loadText(status)),
            ),
          ),
        ),
        onRefresh: () async {
          await Future<void>.delayed(const Duration(seconds: 1));
          if (mounted) state.refreshCompleted();
        },
        onLoad: () async {
          await Future<void>.delayed(const Duration(seconds: 1));
          if (!mounted) return;
          setState(() => count += 10);
          state.loadComplete();
        },
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
