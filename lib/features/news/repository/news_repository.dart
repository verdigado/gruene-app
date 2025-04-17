import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<List<String>?> readDivisionFilterKeys() async {
  final secureStorage = GetIt.instance<FlutterSecureStorage>();
  final json = await secureStorage.read(key: SecureStorageKeys.newsDivisionFilters);
  if (json == null) {
    return null;
  }
  return (jsonDecode(json) as List<dynamic>).map((item) => item as String).toList();
}

Future<void> writeDivisionFilterKeys(List<Division> divisions) async {
  final secureStorage = GetIt.instance<FlutterSecureStorage>();
  final divisionKeys = divisions.map((it) => it.divisionKey).toList();
  final json = jsonEncode(divisionKeys);
  await secureStorage.write(key: SecureStorageKeys.newsDivisionFilters, value: json);
}
