import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/fresh_state.dart';

part 'sliver_fresh_localizations_en.dart';
part 'sliver_fresh_localizations_zh.dart';

/// 刷新和加载文案。通过 delegate 的语言映射覆盖文案或扩展语言。
abstract class SliverFreshLocalizations {
  const SliverFreshLocalizations();

  /// 内置中英文，自定义资源优先；映射中的值为文案资源实例。
  static SliverFreshLocalizationsDelegate delegate([
    Map<Locale, SliverFreshLocalizations> translations = const {},
  ]) => SliverFreshLocalizationsDelegate._(translations);

  static SliverFreshLocalizations of(BuildContext context) {
    final localizations = Localizations.of<SliverFreshLocalizations>(
      context,
      SliverFreshLocalizations,
    );

    return localizations ?? const SliverFreshLocalizationsEn();
  }

  String get refreshIdleText;
  String get refreshArmedText;
  String get refreshingText;
  String get refreshCompletedText;
  String get refreshFailedText;
  String get loadIdleText;
  String get loadArmedText;
  String get loadingText;
  String get loadFailedText;
  String get loadNoMoreText;

  String refreshText(RefreshStatus status) => switch (status) {
    RefreshStatus.idle => refreshIdleText,
    RefreshStatus.armed => refreshArmedText,
    RefreshStatus.refreshing => refreshingText,
    RefreshStatus.completed => refreshCompletedText,
    RefreshStatus.failed => refreshFailedText,
  };

  String loadText(LoadStatus status) => switch (status) {
    LoadStatus.idle => loadIdleText,
    LoadStatus.armed => loadArmedText,
    LoadStatus.loading => loadingText,
    LoadStatus.failed => loadFailedText,
    LoadStatus.noMore => loadNoMoreText,
  };
}

/// 包含内置与自定义语言的委托，supportedLocales 可直接传给宿主应用。
class SliverFreshLocalizationsDelegate
    extends LocalizationsDelegate<SliverFreshLocalizations> {
  SliverFreshLocalizationsDelegate._(
    Map<Locale, SliverFreshLocalizations> translations,
  ) : _translations = Map.unmodifiable({
        const Locale('en'): const SliverFreshLocalizationsEn(),
        const Locale('zh'): const SliverFreshLocalizationsZh(),
        ...translations,
      });

  final Map<Locale, SliverFreshLocalizations> _translations;

  late final List<Locale> supportedLocales = List.unmodifiable(
    _translations.keys,
  );

  late final Map<String, SliverFreshLocalizations> _translationsByTag = {
    for (final entry in _translations.entries)
      entry.key.toLanguageTag(): entry.value,
  };

  @override
  bool isSupported(Locale locale) =>
      _translationsByTag.containsKey(locale.toLanguageTag());

  @override
  Future<SliverFreshLocalizations> load(Locale locale) => SynchronousFuture(
    _translationsByTag[locale.toLanguageTag()] ??
        const SliverFreshLocalizationsEn(),
  );

  @override
  bool shouldReload(SliverFreshLocalizationsDelegate old) =>
      !mapEquals(_translations, old._translations);
}
