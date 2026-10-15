import 'dart:math';

import 'package:flutter/material.dart' hide Element;
import 'package:flutter_html/flutter_html.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/widgets/expansion_list_tile.dart';
import 'package:gruene_app/app/widgets/full_width_image.dart';

final fitImageWidthExtension = TagWrapExtension(
  tagsToWrap: {'img'},
  builder: (child) => FittedBox(fit: BoxFit.scaleDown, child: child),
);

OnImageTapExtension imageTapExtension(BuildContext context) => OnImageTapExtension(
  onImageTap: (String? src, _, element) {
    // Linked images open the link instead
    for (var ancestor = element?.parent; ancestor != null; ancestor = ancestor.parent) {
      if (ancestor.localName == 'a' && ancestor.attributes.containsKey('href')) return;
    }
    if (src != null && src.startsWith('http')) showImageDialog(context, src);
  },
);

final accordionTagExtension = TagExtension(
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

/// Renders tables as stacked blocks as flutter_html has no built-in table support and just drops the content silently
/// flutter_html_table crashes on block elements inside cells
/// (https://github.com/Sub6Resources/flutter_html/issues/1188)
class BlockTableExtension extends HtmlExtension {
  const BlockTableExtension();

  @override
  Set<String> get supportedTags => {'table', 'caption', 'thead', 'tbody', 'tfoot', 'tr', 'th', 'td'};

  @override
  StyledElement prepare(ExtensionContext context, List<StyledElement> children) {
    return StyledElement(
      name: context.elementName,
      elementId: context.id,
      elementClasses: context.classes.toList(),
      node: context.node,
      children: children,
      style: Style(display: Display.block, fontWeight: context.elementName == 'th' ? FontWeight.bold : null),
    );
  }

  @override
  InlineSpan build(ExtensionContext context) {
    return WidgetSpan(
      child: CssBoxWidget.withInlineSpanChildren(style: context.style!, children: context.inlineSpanChildren!),
    );
  }
}

class CustomHtml extends StatelessWidget {
  final String data;

  const CustomHtml({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Html(
      data: data,
      extensions: [
        fitImageWidthExtension,
        imageTapExtension(context),
        accordionTagExtension,
        const BlockTableExtension(),
      ],
      onLinkTap: (url, _, _) => url != null ? openUrl(url, context) : null,
      style: {
        'body': Style(margin: Margins.zero),
        'a': Style(color: theme.primaryColor, textDecorationColor: theme.primaryColor),
      },
    );
  }
}
