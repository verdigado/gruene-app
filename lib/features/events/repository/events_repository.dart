import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<List<String>?> readCalendarFilterKeys() async {
  final secureStorage = GetIt.instance<FlutterSecureStorage>();
  final json = await secureStorage.read(key: SecureStorageKeys.eventsCalendarFilters);
  if (json == null) {
    return null;
  }
  return (jsonDecode(json) as List<dynamic>).map((item) => item as String).toList();
}

Future<void> writeCalendarFilterKeys(List<Calendar> calendars) async {
  final secureStorage = GetIt.instance<FlutterSecureStorage>();
  final divisionKeys = calendars.map((it) => it.id).toList();
  final json = jsonEncode(divisionKeys);
  await secureStorage.write(key: SecureStorageKeys.eventsCalendarFilters, value: json);
}
