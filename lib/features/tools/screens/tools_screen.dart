import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/screens/tab_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/tab_bar.dart';
import 'package:gruene_app/features/tools/domain/tools_api_service.dart';
import 'package:gruene_app/features/tools/widgets/tools_list.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureLoadingScreen(
      load: fetchTools,
      loadingLayoutBuilder: (Widget child) => Scaffold(appBar: MainAppBar(title: t.tools.tools)),
      buildChild: (List<GnetzApplication> data, _) {
        final tabs = getToolCategories(data)
            .map(
              (category) => TabModel(
                label: category.title,
                view: ToolsList(tools: data.where((tool) => tool.categories.contains(category)).toList()),
              ),
            )
            .toList();

        return TabScreen(
          appBarBuilder: (PreferredSizeWidget tabBar) => MainAppBar(title: t.tools.tools, tabBar: tabBar),
          tabs: tabs,
        );
      },
    );
  }
}
