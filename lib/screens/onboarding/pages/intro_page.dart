import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/gen/assets.gen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gruene_app/routing/routes.dart';
import 'package:gruene_app/screens/onboarding/pages/widget/button_group.dart';
import 'package:vector_graphics/vector_graphics.dart';

class IntroPage extends StatefulWidget {
  final PageController controller;

  const IntroPage(this.controller, {super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SvgPicture(AssetBytesLoader(Assets.images.gruenenTopicOekologieSvg),
            height: size.height / 100 * 40),
        const SizedBox(height: 10),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.customPageHeadline1,
                  style: Theme.of(context).primaryTextTheme.displayLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.customPageHeadline2,
                  style: Theme.of(context).primaryTextTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        ButtonGroupNextPrevious(
          next: () => widget.controller.nextPage(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeIn),
          nextText: AppLocalizations.of(context)!.askForInterest,
          previous: () => context.go(startScreen),
          previousText: AppLocalizations.of(context)!.skip,
        ),
      ],
    );
  }
}
