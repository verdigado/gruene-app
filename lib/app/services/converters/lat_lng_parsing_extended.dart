part of '../converters.dart';

extension LatLngParsingExtended on List<double> {
  LatLng toLatLng() {
    if (length != 2) throw ArgumentError('coordinates should contain 2 items');
    return LatLng(this[1], this[0]);
  }
}
