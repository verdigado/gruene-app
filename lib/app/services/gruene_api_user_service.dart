import 'dart:io';

import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiUserService extends GrueneApiBaseService {
  Future<User> getSelf() async => getFromApi(apiRequest: (api) => api.v1UsersSelfGet());

  Future<UserRbacStructure> getOwnRbac() async => getFromApi(apiRequest: (api) => api.v1UsersSelfRbacStructureGet());

  Future<void> addDeviceToken(String deviceToken) async {
    var platform = Platform.isAndroid
        ? AddDeviceTokenPlatform.android
        : (Platform.isIOS ? AddDeviceTokenPlatform.ios : AddDeviceTokenPlatform.swaggerGeneratedUnknown);
    return getFromApi(
      apiRequest: (api) => api.v1UsersSelfSettingsDeviceTokensPost(
        body: AddDeviceToken(deviceToken: deviceToken, platform: platform),
      ),
    );
  }

  Future<FindJoinedChallengesResponse> getUserChallenges({
    required String userId,
    List<ChallengeStatus>? challengeStatus,
    String? campaignId,
    ChallengeSort? sorting,
    bool? onlyCompleted,
    bool? onlyActiveCampaigns,
    required num offset,
    required num limit,
  }) async => getFromApi(
    apiRequest: (api) => api.v1UsersUserIdChallengesGet(
      userId: userId,
      state: challengeStatus,
      campaignId: campaignId,
      sort: sorting.getSortString(),
      onlyCompleted: onlyCompleted,
      onlyActiveCampaigns: onlyActiveCampaigns,
      offset: offset,
      limit: limit,
    ),
  );
}
