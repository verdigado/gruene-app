import 'package:flutter/foundation.dart';

class FilterModel<T> {
  void Function(T newValue) update;
  T initial;
  T selected;
  T values;

  FilterModel({required this.update, required this.initial, required this.selected, T? values})
    : values = values ?? initial;

  void reset() {
    update(initial);
  }

  bool modified([T? other]) {
    final localInitial = initial;
    final localSelected = other ?? selected;
    if (localInitial is List && localSelected is List) {
      return !setEquals(localInitial.toSet(), localSelected.toSet());
    }
    if (localInitial is Set && localSelected is Set) {
      return !setEquals(localInitial, localSelected);
    }
    return localInitial != localSelected;
  }
}

extension FilterModelListExtension on List<FilterModel<dynamic>> {
  bool modified() => any((filter) => filter.modified());
}
