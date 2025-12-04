import 'package:maplibre_gl/maplibre_gl.dart';

final germanyBounds = LatLngBounds(southwest: LatLng(46.8, 5.6), northeast: LatLng(55.1, 15.5));
final germanyCenter = LatLng(51.163361, 10.447683);
final germanyZoom = 4.5;
final zoomPreference = MinMaxZoomPreference(4.5, 18.0);
