part of '../converters.dart';

extension PlaceHelpers on Place {
  String getAddress() {
    var road = getRoad();
    var housenumber = getHouseNumber();
    var city = getCityOrVillage();
    var zipCode = getZipCode();
    var state = getState();
    var municipality = getMunicipality();
    var village = getVillage();
    var county = getCounty();

    switch (addressType) {
      case 'municipality':
        return ''.appendIfNotEmpty(municipality).appendLineIfNotEmpty(county).appendLineIfNotEmpty(state);

      case 'town':
        return ''.appendIfNotEmpty('$zipCode $city').appendLineIfNotEmpty(county).appendLineIfNotEmpty(state);

      case 'village':
        return ''
            .appendIfNotEmpty('$zipCode $village')
            .appendLineIfNotEmpty([municipality, county].where((x) => x.isNotEmpty).join(', '))
            .appendLineIfNotEmpty(state);

      case 'road':
        return ''.appendIfNotEmpty(road).appendLineIfNotEmpty('$zipCode $city').appendLineIfNotEmpty(state);

      case 'building':
      case 'place':
        return ''
            .appendIfNotEmpty('$road $housenumber')
            .appendLineIfNotEmpty('$zipCode $city')
            .appendLineIfNotEmpty(state);

      default:
        return displayName;
    }
  }

  String getRoad() {
    return address?['road']?.toString() ??
        address?['hamlet']?.toString() ??
        address?['isolated_dwelling']?.toString() ??
        '';
  }

  String getCityOrVillage() {
    var city = getCity();
    return city.isEmpty ? (address?['village']?.toString() ?? '') : city;
  }

  String getCity() {
    return address?['city']?.toString() ?? address?['town']?.toString() ?? '';
  }

  String getZipCode() {
    return address?['postcode']?.toString() ?? '';
  }

  String getHouseNumber() {
    return address?['house_number']?.toString() ?? '';
  }

  String getState() {
    return address?['state']?.toString() ?? '';
  }

  String getMunicipality() {
    return address?['municipality']?.toString() ?? '';
  }

  String getVillage() {
    return address?['village']?.toString() ?? '';
  }

  String getCounty() {
    return address?['county']?.toString() ?? '';
  }
}
