import 'package:flutter/foundation.dart';

class FilterModel<T> {
  void Function(T newValue) update;
  T initial;
  T current;

  FilterModel({required this.update, required this.initial, required this.current});

  void reset() {
    update(initial);
  }

  bool modified([T? other]) {
    final localInitial = initial;
    final localSelected = other ?? current;
    if (localInitial is List && localSelected is List) {
      return !setEquals(localInitial.toSet(), localSelected.toSet());
    }
    if (localInitial is Set && localSelected is Set) {
      return !setEquals(localInitial, localSelected);
    }
    return localInitial != localSelected;
  }
}

class SelectionFilterModel<T, P> extends FilterModel<T> {
  P values;

  SelectionFilterModel({required super.update, required super.initial, required super.current, required this.values});
}

extension FilterModelListExtension on List<FilterModel<dynamic>> {
  bool modified() => any((filter) => filter.modified());
}
