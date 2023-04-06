import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gruene_app/constants/layout.dart';
import 'package:gruene_app/constants/theme_data.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:gruene_app/gen/assets.gen.dart';
import 'package:gruene_app/screens/intro/intro_content_below.dart';
import 'package:gruene_app/widget/modal_top_line.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  final snappingPositions = const [
    SnappingPosition.factor(
      positionFactor: 0.0,
      snappingCurve: Curves.easeOutExpo,
      snappingDuration: Duration(milliseconds: 500),
      grabbingContentOffset: GrabbingContentOffset.top,
    ),
    SnappingPosition.factor(
      positionFactor: 1.0,
      snappingCurve: Curves.bounceOut,
      snappingDuration: Duration(seconds: 1),
      grabbingContentOffset: GrabbingContentOffset.bottom,
    ),
  ];

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late SnappingSheetController snappingSheetController;
  final totalSteps = 5;
  bool first = true;
  bool snapIsTop = false;
  int currentStep = 1;

  @override
  void initState() {
    super.initState();
    snappingSheetController = SnappingSheetController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firstSnap();
      // executes after build
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: SnappingSheet(
            lockOverflowDrag: true,
            onSheetMoved: (positionData) {
              setState(() {
                // Some Space betwin
                if (positionData.relativeToSheetHeight >= 0.9251) {
                  snapIsTop = true;
                }
                if (positionData.relativeToSheetHeight <= 0.88) {
                  snapIsTop = false;
                }
              });
            },
            snappingPositions: widget.snappingPositions,
            grabbingHeight: 100,
            controller: snappingSheetController,
            onSnapStart: (positionData, snappingPosition) {
              setState(() {
                first = false;
              });
            },
            grabbing: GrabbingContent(snapIsTop: snapIsTop),
            sheetBelow: SnappingSheetContent(
              draggable: true,
              sizeBehavior: SheetSizeStatic(size: 100),
              child: LayoutBuilder(builder: (ctx, con) {
                return Container(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Stack(
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.topCenter,
                    fit: StackFit.expand,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: SvgPicture(
                          AssetBytesLoader(Assets.images.womanSofa),
                        ),
                      ),
                      Positioned(
                        top: con.maxHeight / 100 * 50,
                        width: con.maxWidth / 2,
                        right: con.maxWidth / 100 * 45,
                        child: Visibility(
                          maintainAnimation: true,
                          maintainInteractivity: true,
                          maintainSemantics: true,
                          maintainSize: true,
                          maintainState: true,
                          visible: snapIsTop,
                          child: AnimatedOpacity(
                            opacity: snapIsTop ? 1 : 0,
                            duration: const Duration(seconds: 1),
                            curve: Curves.fastOutSlowIn,
                            child: StepProgressIndicator(
                              totalSteps: totalSteps,
                              selectedColor: Colors.white,
                              currentStep: currentStep,
                              onTap: (i) {
                                return () {
                                  setState(() {
                                    currentStep = i + 1;
                                  });
                                };
                              },
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: con.maxHeight / 100 * 50,
                        width: con.maxWidth,
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(medium1),
                            child: Text('Deine Lieblingsnews immer dabei',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .displayLarge
                                    ?.copyWith(color: Colors.white)),
                          ),
                        ),
                      ),
                      Positioned(
                        top: con.maxHeight / 100 * 68,
                        width: con.maxWidth,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                              padding: const EdgeInsets.all(medium1),
                              child: Visibility.maintain(
                                visible: snapIsTop,
                                child: AnimatedOpacity(
                                  opacity: snapIsTop ? 1 : 0,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.fastOutSlowIn,
                                  child: Text(
                                    'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy ut labore hjkwsadf.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            child: const IntroContentBelow(),
          ),
        ),
      ),
    );
  }

  Future<void> firstSnap() async {
    if (snappingSheetController.isAttached && first) {
      var down = false;
      await Future.delayed(
        const Duration(seconds: 3),
        () {
          if (first) {
            snappingSheetController
                .snapToPosition(const SnappingPosition.factor(
              positionFactor: 0.03,
              snappingCurve: Curves.easeOutExpo,
              snappingDuration: Duration(seconds: 1),
              grabbingContentOffset: GrabbingContentOffset.top,
            ));
            down = true;
          }
        },
      );
      if (down) {
        Future.delayed(
          const Duration(milliseconds: 800),
          () {
            snappingSheetController.snapToPosition(widget.snappingPositions[0]);
          },
        );
      }
    }
  }
}

class GrabbingContent extends StatefulWidget {
  bool snapIsTop;
  GrabbingContent({super.key, this.snapIsTop = false});

  @override
  State<GrabbingContent> createState() => _GrabbingContentState();
}

class _GrabbingContentState extends State<GrabbingContent> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: widget.snapIsTop
            ? BorderRadius.zero
            : const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(medium1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
                alignment: Alignment.topCenter,
                child: ModalTopLine(color: Colors.white)),
            Text(
              'App erkunden',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Erfahre hier, was Dich erwartet.',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white, fontSize: 14),
            )
          ],
        ),
      ),
    );
  }
}
