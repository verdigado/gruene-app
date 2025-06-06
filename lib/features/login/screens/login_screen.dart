import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/clean_layout.dart';
import 'package:gruene_app/features/login/widgets/support_button.dart';
import 'package:gruene_app/features/login/widgets/welcome_view.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureLoadingScreen(
      load: hasInternetAccess,
      loadingLayoutBuilder: (Widget child) => CleanLayout(child: child),
      buildChild: (bool hasInternetAccess, _) {
        if (!hasInternetAccess) {
          return CleanLayout(
            showAppBar: false,
            child: ErrorScreen(
              errorMessage: t.error.offlineError,
              retry: () => context.read<AuthBloc>().add(CheckTokenRequested()),
            ),
          );
        }

        return CleanLayout(
          showAppBar: false,
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  // #457: disable intro slides for now
                  // return Container(
                  //   padding: EdgeInsets.only(bottom: defaultBottomSheetSize * constraints.maxHeight),
                  //   child: WelcomeView(),
                  // );
                  return WelcomeView();
                },
              ),
              SupportButton(),
              // #457: disable intro slides for now
              // PersistentBottomSheet(
              //   child: IntroSlides(),
              // ),
            ],
          ),
        );
      },
    );
  }
}
