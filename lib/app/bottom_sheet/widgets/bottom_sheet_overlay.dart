import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:gruene_app/app/bottom_sheet/bloc/bottom_sheet_cubit.dart';
import 'package:gruene_app/app/bottom_sheet/bloc/bottom_sheet_state.dart';

class BottomSheetOverlay extends StatelessWidget {
  final Widget child;

  const BottomSheetOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Portal(
      child: BlocBuilder<BottomSheetCubit, BottomSheetState>(
        builder: (context, sheetState) {
          return PortalTarget(
            visible: sheetState.isVisible,
            anchor: const Filled(),
            portalFollower: Builder(
              builder: (portalContext) {
                return Theme(
                  data: theme,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Directionality(
                      textDirection: Directionality.of(context),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () => context.read<BottomSheetCubit>().hide(),
                            child: AnimatedOpacity(
                              opacity: sheetState.isVisible ? 0.4 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: Container(color: Colors.black),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedSlide(
                              offset: sheetState.isVisible ? Offset.zero : const Offset(0, 1),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              child: sheetState.content ?? const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            child: SizedBox.expand(child: child),
          );
        },
      ),
    );
  }
}
