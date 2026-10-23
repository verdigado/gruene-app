import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GrueneApiGuestService extends GrueneApiBaseService {
  Future<List<Division>> getInvitationDivisions() async =>
      getFromApi(apiRequest: (api) => api.v1GuestInvitationsDivisionsGet(), map: (result) => result.data);

  Future<List<GuestInvitation>> getInvitations() async =>
      getFromApi(apiRequest: (api) => api.v1GuestInvitationsGet(), map: (result) => result.data);

  Future<GuestInvitation> createInvitation({required String email, required String divisionKey}) async => getFromApi(
    apiRequest: (api) => api.v1GuestInvitationsPost(
      body: CreateGuestInvitation(email: email, divisionKey: divisionKey),
    ),
  );

  Future<GuestInvitation> resendInvitation(String invitationId) async =>
      getFromApi(apiRequest: (api) => api.v1GuestInvitationsInvitationIdResendPost(invitationId: invitationId));

  Future<void> revokeInvitation(String invitationId) async =>
      getFromApi(apiRequest: (api) => api.v1GuestInvitationsInvitationIdDelete(invitationId: invitationId));

  Future<List<Guest>> getGuests() async =>
      getFromApi(apiRequest: (api) => api.v1GuestsGet(), map: (result) => result.data);

  Future<GuestDetail> getGuest(String userId) async =>
      getFromApi(apiRequest: (api) => api.v1GuestsUserIdGet(userId: userId));

  Future<Guest> renewGuest(String userId) async =>
      getFromApi(apiRequest: (api) => api.v1GuestsUserIdRenewalPost(userId: userId));

  Future<Guest> blockGuest(String userId) async =>
      getFromApi(apiRequest: (api) => api.v1GuestsUserIdBlockPost(userId: userId));

  Future<Guest> unblockGuest(String userId) async =>
      getFromApi(apiRequest: (api) => api.v1GuestsUserIdBlockDelete(userId: userId));
}
