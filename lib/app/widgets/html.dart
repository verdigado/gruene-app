import 'dart:math';

import 'package:flutter/material.dart' hide Element;
import 'package:flutter_html/flutter_html.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/widgets/expansion_list_tile.dart';

final TagExtension accordionTagExtension = TagExtension(
  tagsToExtend: {'dl'},
  builder: (extensionContext) {
    final theme = Theme.of(extensionContext.buildContext!);
    final children = extensionContext.elementChildren;
    final titles = children.where((child) => child.localName == 'dt');
    final contents = children.where((child) => child.localName == 'dd');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: List<Widget>.generate(
          min(titles.length, contents.length),
          (index) => ExpansionListTile(
            titleText: titles.elementAt(index).text,
            backgroundColor: ThemeColors.textLight,
            titlePadding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: ThemeColors.textLight),
                  color: theme.colorScheme.surface,
                ),
                child: CustomHtml(data: contents.elementAt(index).innerHtml),
              ),
            ],
          ),
        ),
      ),
    );
  },
);

class CustomHtml extends StatelessWidget {
  final String data;

  const CustomHtml({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: data,
      extensions: [accordionTagExtension],
      onLinkTap: (url, _, _) => url != null ? openUrl(url, context) : null,
      style: {'body': Style(margin: Margins.zero)},
    );
  }
}
