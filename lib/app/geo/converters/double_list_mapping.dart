part of '../geo.dart';

extension DoubleListMapping on List<double?>? {
  turf.Position toPosition() => turf.Position(this![0]!, this![1]!);
  turf.Point toTurfPoint() => turf.Point(coordinates: toPosition());
}

extension DoubleListListMapping on List<List<double?>?> {
  List<turf.Position> toPositionList() => map((p) => p.toPosition()).toList();
}

extension DoubleListLatLngMapping on List<double> {
  LatLng toLatLng() {
    if (length != 2) throw ArgumentError('coordinates should contain 2 items');
    return LatLng(this[1], this[0]);
  }
}
