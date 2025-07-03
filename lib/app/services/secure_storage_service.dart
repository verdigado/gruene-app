import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void registerSecureStorage() {
  getIt.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true)),
  );
}
