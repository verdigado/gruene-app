import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

extension IterableX<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var item in this) {
      if (test(item)) {
        return item;
      }
    }
    return null;
  }
}

extension IsBetween on DateTime {
  bool isBetween(DateTimeRange dateRange) {
    final safeEndDate = dateRange.end.copyWith(day: dateRange.end.day + 1);
    return !dateRange.start.isAfter(this) && safeEndDate.isAfter(this);
  }
}

extension ContainsAny<T> on List<T> {
  bool containsAny(List<T> other) {
    return any((element) => other.contains(element));
  }
}

extension WithDividers on Iterable<Widget> {
  List<Widget> withDividers([Widget? divider]) => expand((item) => [item, Divider()]).toList()..removeLast();
}

extension PushNested on BuildContext {
  void pushNested(String nestedSlug, {Object? extra}) {
    final currentPath = GoRouterState.of(this).fullPath;
    push('$currentPath/$nestedSlug', extra: extra);
  }
}

Future<bool> hasInternetAccess() async {
  final customCheckOptions = [InternetCheckOption(uri: Uri.parse(Config.ipV4ServiceUrl))];
  final connection = InternetConnection.createInstance(customCheckOptions: customCheckOptions);
  return await connection.hasInternetAccess;
}
