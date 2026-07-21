import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.enums.swagger.dart';

enum BadgeVariant { light, dark }

class ChallengeBadge extends StatelessWidget {
  final ChallengeActivityType activityType;
  final int maxActivityCount;
  final BadgeVariant variant;

  const ChallengeBadge({super.key, required this.activityType, required this.maxActivityCount, required this.variant});

  @override
  Widget build(BuildContext context) {
    final badge = switch (activityType) {
      ChallengeActivityType.house => 'door_${variant.name}.svg',
      ChallengeActivityType.flyerSpot => 'flyer_${variant.name}.svg',
      ChallengeActivityType.poster => 'poster_${variant.name}.svg',
      _ => throw UnimplementedError(),
    };
    final digits = maxActivityCount.toString().length;
    final double fontSize = 48 - digits * 4;
    final double fontTop = digits * 3;
    final double size = 80;
    final double innerSize = 0.9 * size;
    final theme = Theme.of(context);

    return SizedBox(
      height: size,
      width: size,
      child: RotationTransition(
        turns: AlwaysStoppedAnimation(-6 / 360),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset('assets/badges/challenges/base_${variant.name}.svg', width: size, height: size),
            Positioned(
              top: fontTop,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => LinearGradient(
                  begin: variant == BadgeVariant.dark ? AlignmentGeometry.bottomRight : AlignmentGeometry.topLeft,
                  end: variant == BadgeVariant.dark ? AlignmentGeometry.topLeft : AlignmentGeometry.bottomRight,
                  colors: [Color(0xFF145F32), Color(0xFF19B457)],
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: Padding(
                  // Fix the text overlapping the shader due to the italic font
                  padding: const EdgeInsets.only(right: 2),
                  child: Text(
                    maxActivityCount.toString(),
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: fontSize),
                  ),
                ),
              ),
            ),
            Container(
              width: innerSize,
              height: innerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.bottomCenter,
                  radius: 0.5,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
            SvgPicture.asset('assets/badges/challenges/$badge', width: innerSize, height: innerSize),
          ],
        ),
      ),
    );
  }
}
