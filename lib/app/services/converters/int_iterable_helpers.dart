part of '../converters.dart';

extension IntIterableHelpers on Iterable<int> {
  int sum() {
    return fold(0, (prev, current) => prev + current.round());
  }
}
