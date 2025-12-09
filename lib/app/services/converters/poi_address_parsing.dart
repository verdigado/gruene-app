part of '../converters.dart';

extension PoiAddressParsing on PoiAddress {
  AddressModel transformToAddressModel() {
    final address = this;
    return AddressModel(
      street: address.street.safe(),
      houseNumber: address.houseNumber.safe(),
      zipCode: address.zip.safe(),
      city: address.city.safe(),
    );
  }
}
