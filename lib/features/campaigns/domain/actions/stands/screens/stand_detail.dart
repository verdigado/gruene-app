import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/stand_entry_formats.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/widgets/stand_entry_list.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:gruene_app/i18n/translations.g.dart';

/// Detail of a stand, shown in a bottom sheet over the map.
///
/// Shows the latest [latestEntryCount] Termine without the year. With more, a line with the date range of all
/// Termine comes first, and `Alle anzeigen` opens the full list (read-only, with the year).
class StandDetail extends StatelessWidget {
  static const latestEntryCount = 3;

  final StandDetailModel poi;

  const StandDetail({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = StandEntryFormats.newestFirst(poi.entries);
    final hasMoreEntries = entries.length > latestEntryCount;
    final description = poi.description?.trim() ?? '';
    final comment = poi.comment?.trim() ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(title: poi.name, subtitle: t.campaigns.stand.type),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ValueRow(label: t.campaigns.stand.where, value: _address()),
                _ValueRow(label: t.campaigns.stand.flyerCountTotal, value: poi.displayedFlyerTotal.toString()),
                if (description.isNotEmpty) _TextBlock(label: t.campaigns.stand.description, text: description),
                if (comment.isNotEmpty) _TextBlock(label: t.campaigns.stand.comment, text: comment),
                if (entries.isNotEmpty) ...[
                  _SectionLabel(t.campaigns.stand.entries),
                  if (hasMoreEntries)
                    Text(
                      StandEntryFormats.dateRange(entries),
                      style: theme.textTheme.bodySmall?.apply(color: ThemeColors.textDisabled),
                    ),
                  StandEntryList(entries: entries.take(latestEntryCount).toList(), withYear: false),
                  if (hasMoreEntries)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => _showAllEntries(context, entries),
                        child: Text(t.campaigns.stand.showAllEntries),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _address() {
    final address = poi.address;
    final street = '${address.street} ${address.houseNumber}'.trim();
    return [street, address.city.trim()].where((part) => part.isNotEmpty).join(', ');
  }

  Future<void> _showAllEntries(BuildContext context, List<StandEntryModel> entries) => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHeader(title: t.campaigns.stand.entries, subtitle: poi.name),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: StandEntryList(entries: entries, withYear: true),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SheetHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // the close button is centered on the title line; its 48 px tap target adds the space above the title
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.apply(color: ThemeColors.text, fontWeightDelta: 2),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.maybePop(context, ModalDetailResult.close),
              ),
            ],
          ),
          Text(subtitle, style: theme.textTheme.bodySmall?.apply(color: ThemeColors.textDisabled)),
        ],
      ),
    );
  }
}

/// Label on the left, value on the right; at large font sizes the value moves below the label.
class _ValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _ValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.apply(color: ThemeColors.text);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 16,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String label;
  final String text;

  const _TextBlock({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.apply(color: ThemeColors.textDisabled)),
          Text(text, style: theme.textTheme.bodyMedium?.apply(color: ThemeColors.text)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(text, style: theme.textTheme.titleSmall?.apply(color: ThemeColors.text)),
    );
  }
}
