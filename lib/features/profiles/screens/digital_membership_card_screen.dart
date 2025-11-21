import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/membership.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/icon.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DigitalMembershipCardScreen extends StatelessWidget {
  const DigitalMembershipCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MainAppBar(title: t.profiles.digitalMembershipCard.title),
      body: FutureLoadingScreen(
        load: fetchOwnProfile,
        buildChild: (Profile data, _) {
          DivisionMembership? kvMembership = extractKvMembership(data.memberships);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 12, 12),
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
                children: [
                  Text(t.profiles.digitalMembershipCard.card.title, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${data.firstName}\n${data.lastName}',
                    style: theme.textTheme.headlineLarge?.copyWith(color: ThemeColors.background),
                  ),
                  if (kvMembership != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      '${kvMembership.division.name1} ${kvMembership.division.name2}',
                      style: theme.textTheme.titleSmall?.copyWith(color: ThemeColors.background),
                    ),
                  ],
                  const SizedBox(height: 80),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              '${t.common.party}\n${t.profiles.digitalMembershipCard.card.membershipNumber}\n${data.personalId}',
                              style: theme.textTheme.labelLarge?.copyWith(color: ThemeColors.background),
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomIcon(path: 'assets/icons/sunflower.svg', height: 48, color: ThemeColors.background),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: QrImageView(
                          data: data.personalId,
                          version: QrVersions.auto,
                          size: 212,
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
