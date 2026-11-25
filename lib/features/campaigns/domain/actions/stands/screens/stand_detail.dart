import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_update_model.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/screens/stand_entry_edit.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/stand_entry_formats.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/widgets/stand_entry_list.dart';
import 'package:gruene_app/features/campaigns/domain/maps/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/sheet_header.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:gruene_app/i18n/translations.g.dart';

/// Saves a change of a Termin of [stand] and returns the stand with the change applied.
typedef OnSaveStandEntryCallback = Future<StandDetailModel> Function(
  StandDetailModel stand,
  StandEntryUpdateModel entry,
);

/// Deletes a Termin of [stand] and returns the stand without it.
typedef OnDeleteStandEntryCallback = Future<StandDetailModel> Function(StandDetailModel stand, String entryId);

/// Detail of a stand, shown in a bottom sheet over the map. Its Termine are managed here, not in the stand edit view.
///
/// Shows the latest [latestEntryCount] Termine without the year. With more, a line with the date range of all
/// Termine comes first, and `Alle anzeigen` opens the full list (with the year). Tapping a Termin in either opens
/// it for editing; the detail stays open and shows the change.
class StandDetail extends StatefulWidget {
  static const latestEntryCount = 3;

  final StandDetailModel poi;
  final OnSaveStandEntryCallback onSaveEntry;
  final OnDeleteStandEntryCallback onDeleteEntry;

  const StandDetail({super.key, required this.poi, required this.onSaveEntry, required this.onDeleteEntry});

  @override
  State<StandDetail> createState() => _StandDetailState();
}

class _StandDetailState extends State<StandDetail> {
  /// The stand with the Termin changes made in the detail; the full Termin list follows it as well.
  late final _stand = ValueNotifier(widget.poi);

  @override
  void dispose() {
    _stand.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(valueListenable: _stand, builder: _buildDetail);

  Widget _buildDetail(BuildContext context, StandDetailModel poi, Widget? _) {
    final theme = Theme.of(context);
    final entries = StandEntryFormats.newestFirst(poi.entries);
    final hasMoreEntries = entries.length > StandDetail.latestEntryCount;
    final description = poi.description?.trim() ?? '';
    final comment = poi.comment?.trim() ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetHeader(title: poi.name, subtitle: t.campaigns.stand.type),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ValueRow(label: t.campaigns.stand.where, value: _address(poi)),
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
                  StandEntryList(
                    entries: entries.take(StandDetail.latestEntryCount).toList(),
                    withYear: false,
                    onEntryTap: _openEntry,
                  ),
                  if (hasMoreEntries)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(onPressed: _showAllEntries, child: Text(t.campaigns.stand.showAllEntries)),
                    ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: ElevatedButton(
            onPressed: () => Navigator.maybePop(context, ModalDetailResult.edit),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primary,
              foregroundColor: ThemeColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Text(t.common.actions.edit),
          ),
        ),
      ],
    );
  }

  String _address(StandDetailModel poi) {
    final address = poi.address;
    final street = '${address.street} ${address.houseNumber}'.trim();
    return [street, address.city.trim()].where((part) => part.isNotEmpty).join(', ');
  }

  Future<void> _showAllEntries() => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
    builder: (context) => SafeArea(
      child: ValueListenableBuilder(
        valueListenable: _stand,
        builder: (context, poi, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(title: t.campaigns.stand.entries, subtitle: poi.name),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: StandEntryList(entries: poi.entries, withYear: true, onEntryTap: _openEntry),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _openEntry(StandEntryModel entry) {
    final stand = _stand.value;
    return MapConsumer.showModalEditForm(
      context,
      () => StandEntryEdit(
        entry: entry,
        otherEntries: stand.entries.where((e) => e.id != entry.id).toList(),
        standName: stand.name,
        onSave: (update) async => _applyEntryChange(await widget.onSaveEntry(stand, update)),
        // the last Termin cannot be deleted, only the whole stand (decision in #1260)
        onDelete: stand.entries.length > 1
            ? (entryId) async => _applyEntryChange(await widget.onDeleteEntry(stand, entryId))
            : null,
      ),
    );
  }

  void _applyEntryChange(StandDetailModel stand) {
    if (mounted) _stand.value = stand;
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
