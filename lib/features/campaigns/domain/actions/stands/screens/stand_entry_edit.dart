import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_update_model.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/picker_field.dart';
import 'package:gruene_app/app/widgets/text_input_field.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/delete_and_save_widget.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/stand_entry_formats.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/stand_form_rules.dart';
import 'package:gruene_app/features/campaigns/domain/shared/mixins.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/sheet_header.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:intl/intl.dart';

/// Edits one Termin of a stand, or adds one ([StandEntryEdit.add]), in a bottom sheet over the stand detail:
/// `Datum`, `Von`, `Bis` and `Verteilte Flyer`, with the same rules as when creating the stand (#1268), and without
/// overlapping [otherEntries]. When editing without [onDelete] (the last Termin of a stand), a hint replaces
/// `Termin löschen`.
class StandEntryEdit extends StatefulWidget {
  /// The Termin being edited; null when adding one.
  final StandEntryModel? entry;
  final List<StandEntryModel> otherEntries;
  final String standName;
  final Future<void> Function(StandEntryUpdateModel entry)? onSave;
  final Future<void> Function(StandEntryCreateModel entry)? onAdd;
  final Future<void> Function(String entryId)? onDelete;
  final DateTime Function() now;

  const StandEntryEdit({
    super.key,
    required StandEntryModel this.entry,
    required this.otherEntries,
    required this.standName,
    required Future<void> Function(StandEntryUpdateModel entry) this.onSave,
    required this.onDelete,
    this.now = DateTime.now,
  }) : onAdd = null;

  /// Adds a Termin, prefilled like the first Termin of a new stand (#1268): today, ending now.
  const StandEntryEdit.add({
    super.key,
    required this.otherEntries,
    required this.standName,
    required Future<void> Function(StandEntryCreateModel entry) this.onAdd,
    this.now = DateTime.now,
  }) : entry = null,
       onSave = null,
       onDelete = null;

  @override
  State<StandEntryEdit> createState() => _StandEntryEditState();
}

class _StandEntryEditState extends State<StandEntryEdit> with ConfirmDelete {
  final _flyerCountTextController = TextEditingController();

  late DateTime _date;
  late TimeOfDay _from;
  late TimeOfDay _to;

  /// Errors are shown after the first attempt to save and then kept up to date.
  bool _showErrors = false;
  ({String? to, String? flyerCount}) _errors = (to: null, flyerCount: null);

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    if (entry == null) {
      final defaults = StandFormRules.defaultEntryTimes(widget.now());
      _date = defaults.date;
      _from = defaults.from;
      _to = defaults.to;
    } else {
      final startAt = entry.startAt.toLocal();
      _date = DateUtils.dateOnly(startAt);
      _from = TimeOfDay.fromDateTime(startAt);
      _to = TimeOfDay.fromDateTime(entry.endAt.toLocal());
      if (!_isAfterToday) _flyerCountTextController.text = entry.flyerCount.toString();
    }
    _flyerCountTextController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _flyerCountTextController.dispose();
    super.dispose();
  }

  bool get _isAfterToday => StandFormRules.isAfterToday(_date, widget.now());

  void _onInputChanged() {
    if (_showErrors) setState(_validate);
  }

  bool _validate() {
    String? timesError = StandFormRules.validateTimes(_from, _to);
    if (timesError == null) {
      final overlapping = StandFormRules.findOverlap(
        StandFormRules.combine(_date, _from),
        StandFormRules.combine(_date, _to),
        widget.otherEntries,
      );
      if (overlapping != null) timesError = StandFormRules.overlapMessage(overlapping);
    }
    _errors = (
      to: timesError,
      flyerCount: _isAfterToday ? null : StandFormRules.validateFlyerCount(_flyerCountTextController.text),
    );
    return _errors.to == null && _errors.flyerCount == null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetHeader(
          title: widget.entry == null ? t.campaigns.stand.entryAdd.title : t.campaigns.stand.entryEdit.title,
          subtitle: widget.standName,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                PickerField(
                  label: t.campaigns.stand.date,
                  value: DateFormat(t.campaigns.stand.dateFormat).format(_date),
                  onTap: _pickDate,
                ),
              ),
              _field(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Expanded(
                      child: PickerField(
                        label: t.campaigns.stand.from,
                        value: _from.format(context),
                        onTap: () => _pickTime(_from, (time) => _from = time),
                      ),
                    ),
                    Expanded(
                      child: PickerField(
                        label: t.campaigns.stand.to,
                        value: _to.format(context),
                        onTap: () => _pickTime(_to, (time) => _to = time),
                      ),
                    ),
                  ],
                ),
                error: _errors.to,
              ),
              _field(
                TextInputField(
                  labelText: t.campaigns.stand.flyerCount,
                  textController: _flyerCountTextController,
                  inputType: InputFieldType.numbers,
                  enabled: !_isAfterToday,
                ),
                error: _errors.flyerCount,
                hint: _isAfterToday ? t.campaigns.stand.flyerCountFutureHint : null,
              ),
              if (widget.entry != null && widget.onDelete == null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    t.campaigns.stand.entryEdit.lastEntryHint,
                    style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                child: DeleteAndSaveWidget(
                  onDelete: widget.onDelete == null ? null : _onDeletePressed,
                  deleteLabel: t.campaigns.stand.entryEdit.delete,
                  onSave: _onSavePressed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(Widget child, {String? error, String? hint}) {
    final theme = Theme.of(context);
    final message = error ?? hint;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          child,
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                message,
                style: theme.textTheme.labelMedium?.apply(
                  color: error != null ? ThemeColors.textWarning : ThemeColors.textDisabled,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 5),
      lastDate: DateTime(widget.now().year + 5),
    );
    if (picked == null || !mounted) return;

    final pickedIsAfterToday = StandFormRules.isAfterToday(picked, widget.now());
    if (pickedIsAfterToday && _flyerCountTextController.text.trim().isNotEmpty) {
      if (!await _confirm(
        message: t.campaigns.stand.futureDateWithFlyers.message,
        confirm: t.campaigns.stand.futureDateWithFlyers.confirm,
        decline: t.campaigns.stand.futureDateWithFlyers.decline,
      )) {
        return;
      }
      _flyerCountTextController.clear();
    }
    setState(() {
      _date = picked;
      if (_showErrors) _validate();
    });
  }

  Future<void> _pickTime(TimeOfDay current, void Function(TimeOfDay) apply) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null || !mounted) return;
    setState(() {
      apply(picked);
      if (_showErrors) _validate();
    });
  }

  Future<bool> _confirm({required String message, required String confirm, required String decline}) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message, style: theme.textTheme.labelMedium?.apply(fontSizeDelta: 1)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(decline, style: theme.textTheme.labelLarge?.apply(color: theme.colorScheme.secondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirm, style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textWarning)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _onDeletePressed() {
    final (:date, :from, :to) = StandEntryFormats.parts(widget.entry!);
    confirmDelete(
      context,
      title: t.campaigns.stand.entryEdit.delete,
      confirmationDialogText: t.campaigns.stand.entryEdit.deleteConfirmation(date: date, from: from, to: to),
      onDeletePressed: () async {
        await widget.onDelete!(widget.entry!.id);
        if (mounted) Navigator.maybePop(context);
      },
    );
  }

  Future<void> _onSavePressed() async {
    setState(() => _showErrors = true);
    if (!_validate()) return;

    final startAt = StandFormRules.combine(_date, _from);
    final endAt = StandFormRules.combine(_date, _to);
    final flyerCount = StandFormRules.flyerCountToSave(_flyerCountTextController.text, isAfterToday: _isAfterToday);
    final entry = widget.entry;
    if (entry == null) {
      await widget.onAdd!(StandEntryCreateModel(startAt: startAt, endAt: endAt, flyerCount: flyerCount));
    } else {
      await widget.onSave!(
        StandEntryUpdateModel(entryId: entry.id, startAt: startAt, endAt: endAt, flyerCount: flyerCount),
      );
    }
    if (mounted) Navigator.maybePop(context);
  }
}
