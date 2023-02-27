import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/gen/assets.gen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gruene_app/routing/routes.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final panelMinHeight = size.height / 100 * 10;
    return Scaffold(
        body: SafeArea(
      child: Stack(children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: SvgPicture.asset(Assets.images.grueneTopicEconomy,
                      height: size.height / 100 * 60),
                ),
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLocalizations.of(context)!.introHeadline1,
                      style: Theme.of(context).primaryTextTheme.displayLarge,
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLocalizations.of(context)!.introHeadline2,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: panelMinHeight + 10),
              child: ElevatedButton(
                  onPressed: () => context.go(login),
                  child: Text(AppLocalizations.of(context)!.loginButtonText,
                      style: const TextStyle(color: Colors.white))),
            ),
          ),
        ),
        SlidingUpPanel(
          minHeight: panelMinHeight,
          maxHeight: size.height,
          parallaxEnabled: true,
          backdropEnabled: true,
          backdropColor: const Color(0xFFFF495D),
          panel: Container(
            color: const Color(0xFFFF495D),
            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 45,
                  height: 5,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.tourSliderIntroText,
                    style: Theme.of(context).textTheme.titleMedium!
                      ..copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        )
      ]),
    ));
  }
}
