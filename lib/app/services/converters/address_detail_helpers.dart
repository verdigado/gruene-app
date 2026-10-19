part of '../converters.dart';

extension AddressDetailHelpers on AddressDetail {
  String? getCity() {
    return addressTags?['city']?.toString();
  }
}
