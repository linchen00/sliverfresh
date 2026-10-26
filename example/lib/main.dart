import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sliverfresh/sliverfresh.dart';

import 'pages/animated_list_page.dart';
import 'pages/basic_page.dart';
import 'pages/custom_indicator_page.dart';
import 'pages/custom_scroll_view_page.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final delegate = SliverFreshLocalizations.delegate();
    return MaterialApp(
      localizationsDelegates: [
        delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: delegate.supportedLocales,
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = <String, Widget>{
      '基础用法': const BasicPage(),
      '自定义指示器': const CustomIndicatorPage(),
      '直接用 sliver': const CustomScrollViewPage(),
      'SliverAnimatedList': const AnimatedListPage(),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('sliverfresh')),
      body: ListView(
        children: [
          for (final e in pages.entries)
            ListTile(
              title: Text(e.key),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => e.value),
              ),
            ),
        ],
      ),
    );
  }
}
