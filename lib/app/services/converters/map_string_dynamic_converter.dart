part of '../converters.dart';

extension MapStringDynamicConverter on Map<String, dynamic> {
  Map<String, dynamic> convertLatLongField({String fieldName = 'location'}) {
    if (containsKey(fieldName) && this[fieldName] is List<dynamic>) {
      this[fieldName] = (this[fieldName] as List<dynamic>).cast<double>().toList();
    }
    return this;
  }

  Map<String, dynamic> updateIdField(int id) {
    this['id'] = id.toString();
    return this;
  }
}
