import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/icon.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MembershipCardScreen extends StatelessWidget {
  const MembershipCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MainAppBar(title: t.profiles.myMembershipCard),
      body: FutureLoadingScreen(
        load: fetchOwnProfile,
        buildChild: (profile, _) {
          Division? partyDivision = profile.partyDivision;

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 640),
            child: Container(
              margin: screenPadding,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ThemeColors.primary, ThemeColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Text(
                    t.profiles.membershipCard,
                    style: theme.textTheme.labelLarge?.copyWith(color: ThemeColors.background),
                  ),
                  Text(
                    '${profile.firstName}\n${profile.lastName}',
                    style: theme.textTheme.headlineLarge?.copyWith(color: ThemeColors.background),
                  ),
                  if (partyDivision != null)
                    Text(
                      partyDivision.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(color: ThemeColors.background),
                    ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              '${t.common.party}\n${t.profiles.personalId}:\n${profile.personalId}',
                              style: theme.textTheme.labelLarge?.copyWith(color: ThemeColors.background),
                            ),
                          ),
                          CustomIcon(path: 'assets/icons/sunflower.svg', height: 48, color: ThemeColors.background),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: QrImageView(
                          data: profile.personalId,
                          version: QrVersions.auto,
                          size: 192,
                          backgroundColor: ThemeColors.background,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
