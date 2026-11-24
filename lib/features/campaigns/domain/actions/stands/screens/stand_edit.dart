import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_update_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_update_model.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/text_input_field.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/create_address_widget.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/delete_and_save_widget.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/screens/stand_entry_edit.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/stand_form_rules.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/widgets/stand_entry_list.dart';
import 'package:gruene_app/features/campaigns/domain/maps/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/domain/shared/mixins.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/multiline_text_input_field.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/sheet_header.dart';
import 'package:gruene_app/i18n/translations.g.dart';

typedef OnSaveStandCallback = Future<void> Function(StandUpdateModel standUpdate);

/// Saves a change of a Termin of [stand] and returns the stand with the change applied.
typedef OnSaveStandEntryCallback = Future<StandDetailModel> Function(
  StandDetailModel stand,
  StandEntryUpdateModel entry,
);

/// Deletes a Termin of [stand] and returns the stand without it.
typedef OnDeleteStandEntryCallback = Future<StandDetailModel> Function(StandDetailModel stand, String entryId);

/// Edits a stand in a bottom sheet over the map: its fields, its address and, with all its Termine,
/// deleting it. `Ort` cannot be changed (decision in #1260); the address can be corrected.
class StandEdit extends StatefulWidget {
  final StandDetailModel stand;
  final OnSaveStandCallback onSave;
  final OnDeletePoiCallback onDelete;
  final OnSaveStandEntryCallback onSaveEntry;
  final OnDeleteStandEntryCallback onDeleteEntry;

  const StandEdit({
    super.key,
    required this.stand,
    required this.onSave,
    required this.onDelete,
    required this.onSaveEntry,
    required this.onDeleteEntry,
  });

  @override
  State<StandEdit> createState() => _StandEditState();
}

class _StandEditState extends State<StandEdit> with AddressExtension, ConfirmDelete {
  @override
  TextEditingController streetTextController = TextEditingController();
  @override
  TextEditingController houseNumberTextController = TextEditingController();
  @override
  TextEditingController zipCodeTextController = TextEditingController();
  @override
  TextEditingController cityTextController = TextEditingController();

  final _nameTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _commentTextController = TextEditingController();

  /// The stand with the Termin changes made in this view, so the list shows them
  /// and saving the stand does not bring back a changed or deleted Termin.
  late StandDetailModel _stand = widget.stand;

  /// Errors are shown after the first attempt to save and then kept up to date.
  bool _showErrors = false;
  ({String? name, String? description, String? comment}) _errors = (name: null, description: null, comment: null);

  @override
  void initState() {
    super.initState();
    setAddress(widget.stand.address);
    _nameTextController.text = widget.stand.name;
    _descriptionTextController.text = widget.stand.description ?? '';
    _commentTextController.text = widget.stand.comment ?? '';
    for (final controller in [_nameTextController, _descriptionTextController, _commentTextController]) {
      controller.addListener(_onInputChanged);
    }
  }

  @override
  void dispose() {
    disposeAddressTextControllers();
    _nameTextController.dispose();
    _descriptionTextController.dispose();
    _commentTextController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (_showErrors) setState(_validate);
  }

  bool _validate() {
    _errors = (
      name: StandFormRules.validateName(_nameTextController.text),
      description: StandFormRules.validateDescription(_descriptionTextController.text),
      comment: StandFormRules.validateComment(_commentTextController.text),
    );
    return [_errors.name, _errors.description, _errors.comment].every((e) => e == null);
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = ThemeColors.textLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetHeader(title: t.campaigns.stand.edit.title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                TextInputField(
                  labelText: t.campaigns.stand.name,
                  textController: _nameTextController,
                  borderColor: borderColor,
                ),
                error: _errors.name,
              ),
              _field(
                MultiLineTextInputField(
                  labelText: t.campaigns.stand.description,
                  hint: '',
                  textController: _descriptionTextController,
                  maxLength: StandFormRules.descriptionMaxLength,
                  borderColor: borderColor,
                ),
                error: _errors.description,
              ),
              _sectionLabel(t.campaigns.stand.location),
              CreateAddressWidget(
                streetTextController: streetTextController,
                houseNumberTextController: houseNumberTextController,
                zipCodeTextController: zipCodeTextController,
                cityTextController: cityTextController,
                inputBorderColor: borderColor,
              ),
              _field(
                MultiLineTextInputField(
                  labelText: t.campaigns.stand.comment,
                  hint: '',
                  textController: _commentTextController,
                  maxLength: StandFormRules.commentMaxLength,
                  borderColor: borderColor,
                ),
                error: _errors.comment,
              ),
              if (_stand.entries.isNotEmpty) ...[
                _sectionLabel(t.campaigns.stand.entries),
                StandEntryList(entries: _stand.entries, withYear: true, onEntryTap: _openEntry),
              ],
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                child: DeleteAndSaveWidget(onDelete: _onDeletePressed, onSave: _onSavePressed),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(text, style: theme.textTheme.titleSmall?.apply(color: ThemeColors.text)),
    );
  }

  Widget _field(Widget child, {String? error}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          child,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(error, style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textWarning)),
            ),
        ],
      ),
    );
  }

  Future<void> _openEntry(StandEntryModel entry) => MapConsumer.showModalEditForm(
    context,
    () => StandEntryEdit(
      entry: entry,
      otherEntries: _stand.entries.where((e) => e.id != entry.id).toList(),
      standName: _stand.name,
      onSave: (update) async => _applyEntryChange(await widget.onSaveEntry(_stand, update)),
      // the last Termin cannot be deleted, only the whole stand (decision in #1260)
      onDelete: _stand.entries.length > 1
          ? (entryId) async => _applyEntryChange(await widget.onDeleteEntry(_stand, entryId))
          : null,
    ),
  );

  void _applyEntryChange(StandDetailModel stand) {
    if (mounted) setState(() => _stand = stand);
  }

  void _onDeletePressed() => confirmDelete(
    context,
    confirmationDialogText: t.campaigns.stand.deleteConfirmation(count: _stand.entries.length),
    onDeletePressed: () async {
      await widget.onDelete(widget.stand.id);
      if (mounted) Navigator.maybePop(context);
    },
  );

  Future<void> _onSavePressed() async {
    setState(() => _showErrors = true);
    if (!_validate()) return;

    String? emptyToNull(String value) => value.trim().isEmpty ? null : value.trim();

    await widget.onSave(
      StandUpdateModel(
        id: widget.stand.id,
        address: getAddress(),
        location: widget.stand.location,
        name: _nameTextController.text.trim(),
        description: emptyToNull(_descriptionTextController.text),
        comment: emptyToNull(_commentTextController.text),
        oldStandDetail: _stand,
      ),
    );
    if (mounted) Navigator.maybePop(context);
  }
}
