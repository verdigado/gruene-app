import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/features/settings/widgets/settings_card.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ToolsList extends StatelessWidget {
  final List<GnetzApplication> tools;

  const ToolsList({super.key, required this.tools});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: tools.map(
        (tool) {
          final icon = tool.icon;
          final url = tool.url;
          return SettingsCard(
            title: tool.title,
            subtitle: tool.shortDescription[Config.defaultLocale] as String? ?? '',
            onPress: url != null ? () => openUrl(url, context) : null,
            isExternal: true,
            icon: icon != null ? SvgPicture.string(icon, width: 48, height: 48) : SizedBox(width: 48, height: 48),
          );
        },
      ).toList(),
    );
  }
}
