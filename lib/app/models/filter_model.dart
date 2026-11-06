import 'package:flutter/foundation.dart';

class FilterModel<T> {
  void Function(T newValue) update;
  T initial;
  T current;

  FilterModel({required this.update, required this.initial, required this.current});

  void reset() {
    update(initial);
  }

  bool modified() => differsFromInitial(current);

  bool differsFromInitial(T value) {
    final localInitial = initial;
    if (localInitial is List && value is List) {
      return !setEquals(localInitial.toSet(), value.toSet());
    }
    if (localInitial is Set && value is Set) {
      return !setEquals(localInitial, value);
    }
    return localInitial != value;
  }
}

class SelectionFilterModel<T, P> extends FilterModel<T> {
  P values;

  SelectionFilterModel({required super.update, required super.initial, required super.current, required this.values});
}

extension FilterModelListExtension on List<FilterModel<dynamic>> {
  bool modified() => any((filter) => filter.modified());
}
