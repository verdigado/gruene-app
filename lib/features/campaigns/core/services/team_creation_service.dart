import 'package:gruene_app/app/models/campaigns/team/new_team_details.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/api/team_api_service.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

/// Service responsible for team creation business logic.
/// This is pure domain logic without any UI dependencies.
class TeamCreationService {
  final TeamApiService _apiService;

  TeamCreationService(this._apiService);

  /// Validates if the creating user is joining the new team
  bool isCreatingUserInNewTeam(NewTeamDetails details, UserRbacStructure currentUser) {
    return details.getAllMemberships().any((m) => m.userId == currentUser.userId);
  }

  /// Checks if the user is already in a team and needs confirmation
  Future<bool> needsTeamChangeConfirmation({
    required NewTeamDetails newTeamDetails,
    required UserRbacStructure currentUser,
    required Team? currentTeam,
  }) async {
    final isJoiningNewTeam = isCreatingUserInNewTeam(newTeamDetails, currentUser);
    return isJoiningNewTeam && currentTeam != null;
  }

  /// Creates a new team with the provided details
  /// Throws [ApiException] on API errors
  Future<Team> createTeam(NewTeamDetails details) async {
    return await _apiService.createNewTeam(details);
  }

  /// Full team creation flow with validation
  /// Returns [TeamCreationResult] with success status
  Future<TeamCreationResult> executeTeamCreation(TeamCreationInput input) async {
    try {
      final currentTeam = await _apiService.getOwnTeam();

      final needsConfirmation = await needsTeamChangeConfirmation(
        newTeamDetails: input.details,
        currentUser: input.currentUser,
        currentTeam: currentTeam,
      );

      if (needsConfirmation && !input.skipConfirmation) {
        // The actual confirmation UI logic is handled at the UI layer
        // This service just identifies the need for confirmation
        return TeamCreationResult(success: false, errorMessage: 'Confirmation required for team change');
      }

      final createdTeam = await createTeam(input.details);

      return TeamCreationResult(success: true, createdTeam: createdTeam);
    } on ApiException catch (e) {
      return TeamCreationResult(success: false, errorMessage: e.toString());
    } catch (e) {
      return TeamCreationResult(success: false, errorMessage: e.toString());
    }
  }
}

/// Result of a team creation attempt
class TeamCreationResult {
  final bool success;
  final String? errorMessage;
  final Team? createdTeam;

  TeamCreationResult({required this.success, this.errorMessage, this.createdTeam});
}

/// Input for team creation validation
class TeamCreationInput {
  final NewTeamDetails details;
  final UserRbacStructure currentUser;
  final bool skipConfirmation;

  TeamCreationInput({required this.details, required this.currentUser, this.skipConfirmation = false});
}
