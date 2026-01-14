import 'dart:io';

import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiUserService extends GrueneApiBaseService {
  Future<User> getSelf() async => getFromApi(apiRequest: (api) => api.v1UsersSelfGet());
  Future<UserRbacStructure> getOwnRbac() async => getFromApi(apiRequest: (api) => api.v1UsersSelfRbacStructureGet());
  Future<UserRbacStructure> addDeviceToken(String deviceToken) async {
    var platform = Platform.isAndroid
        ? AddDeviceTokenPlatform.android
        : (Platform.isIOS ? AddDeviceTokenPlatform.ios : AddDeviceTokenPlatform.swaggerGeneratedUnknown);
    return getFromApi(
      apiRequest: (api) => api.v1UsersSelfSettingsDeviceTokensPost(
        body: AddDeviceToken(deviceToken: deviceToken, platform: platform),
      ),
    );
  }
}
