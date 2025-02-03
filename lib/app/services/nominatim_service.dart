import 'package:flutter/foundation.dart';
import 'package:gruene_app/app/geocode/nominatim.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

part 'nominatim_service.g.dart';

class NominatimService {
  final Logger _logger = Logger();

  final String countryCode;

  NominatimService({required this.countryCode});

  Future<AddressModel> getLocationAddress(LatLng location) async {
    try {
      final place = await Nominatim.reverseSearch(
        lat: location.latitude,
        lon: location.longitude,
      );
      String? cityOverride;
      if (place.getCity().isEmpty) {
        var osmType = switch (place.osmType) {
          'way' => 'W',
          'node' => 'N',
          'relation' => 'R',
          String() => throw UnimplementedError(),
          null => throw UnimplementedError(),
        };
        final addressDetail = await Nominatim.details(osmType: osmType, osmId: place.osmId!);
        cityOverride = addressDetail.getCity();
      }

      final address = AddressModel.fromPlace(place, cityOverride: cityOverride);
      return address;
    } catch (e) {
      _logger.e(
        'Nominatim reverse search failed on (lat: ${location.latitude}, lon: ${location.longitude}): ${e.toString()}',
      );
      return AddressModel();
    }
  }

  Future<List<SearchResultItem>> findStreetOrCity(String query, LatLngBounds viewBox) async {
    try {
      searchOnMap({String? city, String? street, String? query}) async {
        return await Nominatim.searchByName(
          query: query,
          street: street,
          city: city,
          layer: 'address',
          viewBox: ViewBox(
            viewBox.northeast.latitude,
            viewBox.southwest.latitude,
            viewBox.northeast.longitude,
            viewBox.southwest.longitude,
          ),
          bounded: true,
          dedupe: true,
          addressDetails: true,
          limit: 50,
          language: countryCode,
        );
      }

      final unstructured = await searchOnMap(query: query);
      final streetsResult = await searchOnMap(street: query);
      final cities = await searchOnMap(city: query);
      final unstructuredList = _getList(unstructured);
      final streetList = _getList(streetsResult);
      final cityList = _getList(cities);
      return streetList + cityList + unstructuredList;
    } catch (e) {
      _logger.e(
        'Nominatim search failed on (q: $query: ${e.toString()}',
      );
      return <SearchResultItem>[];
    }
  }

  List<SearchResultItem> _getList(List<Place> places) {
    var filteredAddressTypes = ['road', 'town', 'village', 'municipality', 'place', 'building'];
    if (kDebugMode) {
      // print list of addressTypes in case we might want to investigate
      places
          .where((x) => !filteredAddressTypes.contains(x.addressType))
          .map((x) => x.addressType)
          .toSet()
          .toList() // make it unique
          .forEach(debugPrint);
    }
    return places.where((x) => filteredAddressTypes.contains(x.addressType)).map(SearchResultItem.fromPlace).toList();
  }
}

class SearchResultItem {
  final LatLng location;
  final String displayName;

  SearchResultItem({required this.location, required this.displayName});

  SearchResultItem.fromPlace(Place place)
      : location = LatLng(place.lat, place.lon),
        displayName = place.getAddress();
}

@JsonSerializable()
class AddressModel {
  final String street;
  final String city;
  final String zipCode;
  final String houseNumber;

  AddressModel({this.street = '', this.houseNumber = '', this.zipCode = '', this.city = ''});

  /*
  * More details on how to find and categorize "places" can be found in the OSM Wiki:
  * https://wiki.openstreetmap.org/wiki/Template:Generic:Map_Features:place
  * If road is absent we take hamlet oder dwelling as Street Information.
  * For City we take in descending order city, town, or village, whatever is first.
  * Hopefully, this will solve most issues with that kind of address composition.
  */
  AddressModel.fromPlace(Place place, {String? cityOverride})
      : street = place.getRoad(),
        houseNumber = place.getHouseNumber(),
        zipCode = place.getZipCode(),
        city = cityOverride ?? place.getCityOrVillage();

  /// Connect the generated [_$AddressModelFromJson] function to the `fromJson`
  /// factory.
  factory AddressModel.fromJson(Map<String, dynamic> json) => _$AddressModelFromJson(json);

  /// Connect the generated [_$AddressModelToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$AddressModelToJson(this);
}
