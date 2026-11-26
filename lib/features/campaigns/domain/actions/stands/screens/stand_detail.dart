import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_update_model.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/campaigns/core/cache/campaign_action_cache.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/photo_carousel.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/screens/stand_entry_edit.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/stand_entry_formats.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/widgets/stand_entry_list.dart';
import 'package:gruene_app/features/campaigns/domain/maps/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/sheet_header.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:gruene_app/i18n/translations.g.dart';

/// Adds a Termin to [stand] and returns the stand with it.
typedef OnAddStandEntryCallback = Future<StandDetailModel> Function(
  StandDetailModel stand,
  StandEntryCreateModel entry,
);

/// Saves a change of a Termin of [stand] and returns the stand with the change applied.
typedef OnSaveStandEntryCallback = Future<StandDetailModel> Function(
  StandDetailModel stand,
  StandEntryUpdateModel entry,
);

/// Deletes a Termin of [stand] and returns the stand without it.
typedef OnDeleteStandEntryCallback = Future<StandDetailModel> Function(StandDetailModel stand, String entryId);

/// Detail of a stand, shown in a bottom sheet over the map. Its Termine are managed here, not in the stand edit view.
///
/// Its photos come first, newest first; tapping one opens them full screen. Without photos there is no image area.
///
/// Shows the latest [latestEntryCount] Termine without the year. With more, a line with the date range of all
/// Termine comes first, and `Alle anzeigen (n)` opens the full list (with the year). Both offer `Termin hinzufügen`,
/// and tapping a Termin in either opens it for editing; the detail stays open and shows the change.
class StandDetail extends StatefulWidget {
  static const latestEntryCount = 3;

  /// The detail may take up to this part of the screen, so that its photos and up to 3 Termine fit without scrolling
  /// on a phone like the Galaxy S21. With more Termine, the date range and `Alle anzeigen` may need scrolling.
  static const maxHeightFactor = 0.86;

  static const photoHeight = 120.0;

  final StandDetailModel poi;
  final OnAddStandEntryCallback onAddEntry;
  final OnSaveStandEntryCallback onSaveEntry;
  final OnDeleteStandEntryCallback onDeleteEntry;

  const StandDetail({
    super.key,
    required this.poi,
    required this.onAddEntry,
    required this.onSaveEntry,
    required this.onDeleteEntry,
  });

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
                PhotoCarousel(photos: poi.photosNewestFirst, height: StandDetail.photoHeight),
                _ValueRow(label: t.campaigns.stand.where, value: _address(poi)),
                _ValueRow(label: t.campaigns.stand.flyerCountTotal, value: poi.displayedFlyerTotal.toString()),
                if (description.isNotEmpty) _TextBlock(label: t.campaigns.stand.description, text: description),
                if (comment.isNotEmpty) _TextBlock(label: t.campaigns.stand.comment, text: comment),
                _EntriesHeading(onAddEntry: _addEntry),
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
                    child: TextButton(
                      onPressed: _showAllEntries,
                      child: Text(t.campaigns.stand.showAllEntries(count: entries.length)),
                    ),
                  ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: _AddEntryButton(onPressed: _addEntry),
              ),
            ),
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

  Future<void> _addEntry() {
    final stand = _stand.value;
    return MapConsumer.showModalEditForm(
      context,
      () => StandEntryEdit.add(
        otherEntries: stand.entries,
        standName: stand.name,
        onAdd: (entry) => _changeEntry(() => widget.onAddEntry(stand, entry)),
      ),
    );
  }

  Future<void> _openEntry(StandEntryModel entry) {
    final stand = _stand.value;
    return MapConsumer.showModalEditForm(
      context,
      () => StandEntryEdit(
        entry: entry,
        otherEntries: stand.entries.where((e) => e.id != entry.id).toList(),
        standName: stand.name,
        onSave: (update) => _changeEntry(() => widget.onSaveEntry(stand, update)),
        // the last Termin cannot be deleted, only the whole stand (decision in #1260)
        onDelete: stand.entries.length > 1
            ? (entryId) => _changeEntry(() => widget.onDeleteEntry(stand, entryId))
            : null,
      ),
    );
  }

  /// Applies a Termin change. If the stand was synced since it was opened and the change cannot be matched to it,
  /// nothing is saved and the person is asked to open the stand again.
  Future<void> _changeEntry(Future<StandDetailModel> Function() change) async {
    try {
      final stand = await change();
      if (mounted) _stand.value = stand;
    } on OutdatedStandException {
      if (mounted) showSnackBar(context: context, text: t.campaigns.stand.outdated);
    }
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

/// The title of the Termin list with `Termin hinzufügen` on its right; at large font sizes the button moves below.
class _EntriesHeading extends StatelessWidget {
  final VoidCallback onAddEntry;

  const _EntriesHeading({required this.onAddEntry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        children: [
          Text(t.campaigns.stand.entries, style: theme.textTheme.titleSmall?.apply(color: ThemeColors.text)),
          _AddEntryButton(onPressed: onAddEntry),
        ],
      ),
    );
  }
}

class _AddEntryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddEntryButton({required this.onPressed});

  @override
  Widget build(BuildContext context) =>
      TextButton.icon(onPressed: onPressed, icon: const Icon(Icons.add), label: Text(t.campaigns.stand.entryAdd.title));
}
