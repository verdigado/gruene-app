import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/domain/divisions_api_service.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_challenge_service.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/pressable_opacity.dart';
import 'package:gruene_app/app/widgets/section_card.dart';
import 'package:gruene_app/features/campaigns/screens/challenges/challenge_badge.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/features/profiles/widgets/profile_card.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide ProfileImage, Image;

class ProfileDetails extends StatelessWidget {
  final PublicProfile profile;
  final bool isOwnProfile;

  const ProfileDetails({super.key, required this.profile, this.isOwnProfile = false});

  @override
  Widget build(BuildContext context) {
    final challengeService = GetIt.I<GrueneApiChallengeService>();
    final email = profile.email;
    final mandateRoles = profile.displayRoles(types: [ProfileRoleType.mandate]);
    final officeRoles = profile.displayRoles(types: [ProfileRoleType.office]);
    final sherpaRoles = profile.displayRoles(types: [ProfileRoleType.role]);
    final skills = profile.displayTags(ProfileTagType.skill);
    final interests = profile.displayTags(ProfileTagType.interest);
    final divisions = profile.divisions;
    final partyDivision = profile.partyDivision;
    final parentDivisionKeys = [
      partyDivision?.parentDivisionKey(HierarchyLevel.kv),
      partyDivision?.parentDivisionKey(HierarchyLevel.lv),
    ].where((divisionKey) => divisionKey != partyDivision?.divisionKey).nonNulls.toList();
    final theme = Theme.of(context);

    return FutureLoadingScreen(
      load: () async => (
        challenges: await challengeService.getMyChallenges(),
        profiles: await fetchProfiles(division: partyDivision, limit: maxProfileCards),
        parentDivisions: parentDivisionKeys.isNotEmpty ? await loadDivisions(parentDivisionKeys) : <Division>[],
      ),
      loadingLayoutBuilder: (Widget child) => Padding(padding: EdgeInsetsGeometry.all(16), child: child),
      buildChild: (data, _) {
        final completedChallenges = data.challenges.where((challenge) => challenge.isCompleted()).toList();
        completedChallenges.sort((a, b) => b.end.compareTo(a.end));

        return Column(
          spacing: 16,
          children: [
            if (completedChallenges.isNotEmpty)
              SectionCard(
                title: t.campaigns.challenges.label,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: horizontalScreenPadding,
                      child: Row(
                        spacing: 8,
                        children: completedChallenges
                            .map(
                              (challenge) => PressableOpacity(
                                onTap: () => context.push(
                                  RouteLocations.getRoute([RouteLocations.campaignChallengesDetail, challenge.id]),
                                  extra: challenge,
                                ),
                                child: ChallengeBadge(
                                  activityType: challenge.activities.first.type,
                                  maxActivityCount: challenge.getProgressInfo().maxActivityCount,
                                  variant: BadgeVariant.dark,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            if (email != null || profile.phoneNumbers.isNotEmpty || isOwnProfile)
              SectionCard(
                children: [
                  if (email != null)
                    SectionCardListItem(
                      title: t.profiles.email,
                      value: email,
                      onTap: isOwnProfile ? null : () => openMail(email, context),
                    ),
                  if (profile.phoneNumbers.isNotEmpty)
                    SectionCardListItem(title: t.profiles.phoneNumber, value: profile.phoneNumbers.first.number),
                  if (isOwnProfile)
                    SectionCardListItem(
                      title: t.profiles.personalId,
                      value: profile.personalId,
                      onTap: () => Clipboard.setData(ClipboardData(text: profile.personalId)),
                      trailing: Icon(Icons.copy, color: theme.disabledColor),
                    ),
                ],
              ),
            if (divisions.isNotEmpty)
              SectionCard(
                title: t.profiles.memberships,
                children: [...divisions, ...data.parentDivisions]
                    .sortByLevel(reverseLevel: true)
                    .map((division) {
                      final email = division.emails.firstOrNull?.address;
                      return Column(
                        children: [
                          SectionCardListItem(
                            value: division.shortDisplayName,
                            url: division.urls.firstOrNull,
                            extraTrailing: email != null
                                ? IconButton(
                                    onPressed: () => openMail(email, context),
                                    onLongPress: () => Clipboard.setData(ClipboardData(text: email)),
                                    icon: Icon(Icons.email_outlined, color: theme.primaryColor),
                                  )
                                : null,
                          ),
                          if (isOwnProfile && division.divisionKey == partyDivision?.divisionKey)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: DivisionProfileCards(
                                profiles: data.profiles,
                                division: division,
                                userId: profile.userId,
                              ),
                            ),
                        ],
                      );
                    })
                    .withDividers(Divider(indent: 16, endIndent: 16)),
              ),
            if (mandateRoles.isNotEmpty)
              SectionCard(
                title: t.profiles.mandateRoles,
                children: mandateRoles.map((role) => SectionCardListItem(value: role)),
              ),
            if (officeRoles.isNotEmpty)
              SectionCard(
                title: t.profiles.officeRoles,
                children: officeRoles.map((role) => SectionCardListItem(value: role)),
              ),
            if (sherpaRoles.isNotEmpty)
              SectionCard(
                title: t.profiles.sherpaRoles,
                children: sherpaRoles.map((role) => SectionCardListItem(value: role)),
              ),
            if (profile.socialMedia.isNotEmpty)
              SectionCard(
                title: t.profiles.socialMedia,
                children: profile.socialMedia.map(
                  (platform) => SectionCardListItem(value: platform.label, url: platform.url),
                ),
              ),
            if (skills.isNotEmpty)
              SectionCard(
                title: t.profiles.skills,
                children: skills.map((tag) => SectionCardListItem(value: tag)),
              ),
            if (interests.isNotEmpty)
              SectionCard(
                title: t.profiles.interests,
                children: interests.map((tag) => SectionCardListItem(value: tag)),
              ),
          ],
        );
      },
    );
  }
}
