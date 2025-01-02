import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/persistent_bottom_sheet.dart';
import 'package:gruene_app/features/login/widgets/support_button.dart';
import 'package:gruene_app/features/login/widgets/welcome_view.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: theme.colorScheme.surface, toolbarHeight: 0),
      body: Container(
        color: theme.colorScheme.surface,
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  padding: EdgeInsets.only(bottom: defaultBottomSheetSize * constraints.maxHeight),
                  child: WelcomeView(),
                );
              },
            ),
            SupportButton(),
            // #457: disable intro slides for now
            // PersistentBottomSheet(
            //   child: IntroSlides(),
            // ),
          ],
        ),
      ),
    );
  }
}
