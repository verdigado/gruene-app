import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class Attachments extends StatelessWidget {
  final List<NewsAttachment> attachments;

  const Attachments({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return SizedBox.shrink();
    }
    return ExpansionTile(
      title: Row(spacing: 8, children: [Icon(Icons.attachment), Text(t.news.attachments)]),
      tilePadding: EdgeInsets.zero,
      shape: const Border(),
      dense: true,
      children: attachments.map((attachment) => _AttachmentTile(attachment: attachment)).toList(),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final NewsAttachment attachment;

  const _AttachmentTile({required this.attachment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: () => openUrl(attachment.url, context),
      leading: Icon(Icons.file_download),
      title: Text(attachment.name),
      iconColor: theme.colorScheme.primary,
      textColor: theme.colorScheme.primary,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
