import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestApiService extends BaseApiService {
  Future<List<Division>> getInvitationDivisions() async =>
      send(request: (api) => api.v1GuestInvitationsDivisionsGet(), map: (result) => result.data);

  Future<List<GuestInvitation>> getInvitations() async =>
      send(request: (api) => api.v1GuestInvitationsGet(), map: (result) => result.data);

  Future<GuestInvitation> createInvitation({required String email, required String divisionKey}) async => send(
    request: (api) => api.v1GuestInvitationsPost(
      body: CreateGuestInvitation(email: email, divisionKey: divisionKey),
    ),
  );

  Future<GuestInvitation> resendInvitation(String invitationId) async =>
      send(request: (api) => api.v1GuestInvitationsInvitationIdResendPost(invitationId: invitationId));

  Future<void> revokeInvitation(String invitationId) async =>
      send(request: (api) => api.v1GuestInvitationsInvitationIdDelete(invitationId: invitationId));
}
