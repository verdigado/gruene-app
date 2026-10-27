import 'dart:io';

import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class UsersApiService extends BaseApiService {
  Future<User> getSelf() async => send(request: (api) => api.v1UsersSelfGet());

  Future<UserRbacStructure> getOwnRbac() async => send(request: (api) => api.v1UsersSelfRbacStructureGet());

  Future<void> addDeviceToken(String deviceToken) async {
    var platform = Platform.isAndroid
        ? AddDeviceTokenPlatform.android
        : (Platform.isIOS ? AddDeviceTokenPlatform.ios : AddDeviceTokenPlatform.swaggerGeneratedUnknown);
    return send(
      request: (api) => api.v1UsersSelfSettingsDeviceTokensPost(
        body: AddDeviceToken(deviceToken: deviceToken, platform: platform),
      ),
    );
  }
}
