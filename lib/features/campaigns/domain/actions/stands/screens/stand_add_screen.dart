import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_create_model.dart';
import 'package:gruene_app/app/services/api/campaign_api_service.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/campaign.dart';
import 'package:gruene_app/app/widgets/picker_field.dart';
import 'package:gruene_app/app/widgets/text_input_field.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/photo_edit_controller.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/create_address_widget.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/photo_carousel.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/save_cancel_on_create_widget.dart';
import 'package:gruene_app/features/campaigns/domain/actions/stands/stand_form_rules.dart';
import 'package:gruene_app/features/campaigns/domain/shared/mixins.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/multiline_text_input_field.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Creates a stand together with its first Termin and its photos. Its title and buttons stay in place while the
/// fields scroll (the title scrolls along when a large font makes it fill the screen), so it needs a page that does
/// not scroll itself (`scrollAddScreen: false`).
class StandAddScreen extends StatefulWidget {
  final LatLng location;
  final AddressModel address;

  /// Only for tests; defaults to the current time.
  final DateTime Function() now;

  const StandAddScreen({super.key, required this.location, required this.address, this.now = DateTime.now});

  @override
  State<StatefulWidget> createState() => StandAddScreenState();
}

class StandAddScreenState extends State<StandAddScreen> with AddressExtension {
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
  final _flyerCountTextController = TextEditingController();
  final _photos = PhotoEditController();

  late DateTime _date;
  late TimeOfDay _from;
  late TimeOfDay _to;

  /// The name follows the address until it is changed by hand.
  bool _nameFollowsAddress = true;

  /// Errors are shown after the first attempt to save and then kept up to date.
  bool _showErrors = false;
  ({String? name, String? description, String? comment, String? to, String? flyerCount}) _errors = (
    name: null,
    description: null,
    comment: null,
    to: null,
    flyerCount: null,
  );

  late final String _initialValues;
  final _appSettings = GetIt.I<AppSettings>();
  String _campaignName = '';

  @override
  void initState() {
    super.initState();
    setAddress(widget.address);
    _nameTextController.text = _nameFromAddress();
    final defaults = StandFormRules.defaultEntryTimes(widget.now());
    _date = defaults.date;
    _from = defaults.from;
    _to = defaults.to;
    _initialValues = _currentValues();

    streetTextController.addListener(_onAddressChanged);
    houseNumberTextController.addListener(_onAddressChanged);
    _nameTextController.addListener(_onNameChanged);
    for (final controller in [_descriptionTextController, _commentTextController, _flyerCountTextController]) {
      controller.addListener(_onInputChanged);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCampaignName());
  }

  @override
  void dispose() {
    disposeAddressTextControllers();
    _nameTextController.dispose();
    _descriptionTextController.dispose();
    _commentTextController.dispose();
    _flyerCountTextController.dispose();
    _photos.dispose();
    super.dispose();
  }

  Future<void> _loadCampaignName() async {
    final activeCampaign = _appSettings.campaign.activeCampaign.recentSelectedCampaignId;
    if (activeCampaign == null) return;
    final campaign = await GetIt.I<CampaignApiService>().getCampaign(activeCampaign);
    if (!mounted) return;
    setState(() => _campaignName = campaign.name);
  }

  bool get _isAfterToday => StandFormRules.isAfterToday(_date, widget.now());

  String _nameFromAddress() => '${streetTextController.text} ${houseNumberTextController.text}'.trim();

  void _onAddressChanged() {
    if (_nameFollowsAddress) _nameTextController.text = _nameFromAddress();
  }

  void _onNameChanged() {
    if (_nameTextController.text != _nameFromAddress()) {
      _nameFollowsAddress = false;
    }
    _onInputChanged();
  }

  void _onInputChanged() {
    if (_showErrors) setState(_validate);
  }

  String _currentValues() => [
    _nameTextController.text,
    _descriptionTextController.text,
    _commentTextController.text,
    _flyerCountTextController.text,
    ...getAddress().toJson().values,
    _date.toIso8601String(),
    _from.toString(),
    _to.toString(),
  ].join('\u0000');

  bool get _hasChanges => _currentValues() != _initialValues || _photos.hasChanges;

  bool _isSaving = false;

  bool _validate() {
    _errors = (
      name: StandFormRules.validateName(_nameTextController.text),
      description: StandFormRules.validateDescription(_descriptionTextController.text),
      comment: StandFormRules.validateComment(_commentTextController.text),
      to: StandFormRules.validateTimes(_from, _to),
      flyerCount: _isAfterToday ? null : StandFormRules.validateFlyerCount(_flyerCountTextController.text),
    );
    return [_errors.name, _errors.description, _errors.comment, _errors.to, _errors.flyerCount].every((e) => e == null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final header = [
              Text(t.campaigns.stand.add.title, style: _titleStyle(theme)),
              Text(
                _campaignName,
                style: theme.textTheme.bodyMedium!.apply(color: ThemeColors.grey200),
                overflow: TextOverflow.ellipsis,
              ),
            ];
            // only the fields scroll; the title stays in place unless a large font makes it fill the screen
            final headerIsFixed = _titleHeight(theme, constraints.maxWidth) <= constraints.maxHeight / 4;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (headerIsFixed) ...header,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!headerIsFixed) ...header,
                        Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: PhotoCarouselEditor(
                            controller: _photos,
                            deleteConfirmationText: t.campaigns.stand.photoDeleteConfirmation,
                            downloadFileNamePrefix: 'stand',
                          ),
                        ),
                        _field(
                          TextInputField(labelText: t.campaigns.stand.name, textController: _nameTextController),
                          error: _errors.name,
                        ),
                        _field(
                          MultiLineTextInputField(
                            labelText: t.campaigns.stand.description,
                            hint: '',
                            textController: _descriptionTextController,
                            maxLength: StandFormRules.descriptionMaxLength,
                          ),
                          error: _errors.description,
                        ),
                        _sectionLabel(t.campaigns.stand.location),
                        CreateAddressWidget(
                          streetTextController: streetTextController,
                          houseNumberTextController: houseNumberTextController,
                          zipCodeTextController: zipCodeTextController,
                          cityTextController: cityTextController,
                        ),
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
                        _field(
                          MultiLineTextInputField(
                            labelText: t.campaigns.stand.comment,
                            hint: '',
                            textController: _commentTextController,
                            maxLength: StandFormRules.commentMaxLength,
                          ),
                          error: _errors.comment,
                        ),
                      ],
                    ),
                  ),
                ),
                SaveCancelOnCreateWidget(onSave: _onSavePressed),
              ],
            );
          },
        ),
      ),
    );
  }

  TextStyle _titleStyle(ThemeData theme) => theme.textTheme.displayMedium!.apply(color: theme.colorScheme.surface);

  double _titleHeight(ThemeData theme, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: t.campaigns.stand.add.title, style: _titleStyle(theme)),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    final height = painter.height;
    painter.dispose();
    return height;
  }

  Widget _sectionLabel(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Text(text, style: theme.textTheme.labelMedium?.apply(color: theme.colorScheme.surface)),
    );
  }

  Widget _field(Widget child, {String? error, String? hint}) {
    final theme = Theme.of(context);
    final message = error ?? hint;
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          child,
          if (message != null)
            Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text(
                message,
                style: theme.textTheme.labelMedium?.apply(
                  color: error != null ? ThemeColors.sun : theme.colorScheme.surface,
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

  Future<void> _onSavePressed(BuildContext localContext) async {
    if (_isSaving) return;
    setState(() => _showErrors = true);
    if (!_validate()) return;

    String? emptyToNull(String value) => value.trim().isEmpty ? null : value.trim();

    _isSaving = true;
    final newPhotos = await _photos.prepareNewPhotos();
    if (!mounted) return;
    Navigator.of(context).pop(
      StandCreateModel(
        location: widget.location,
        address: getAddress(),
        name: _nameTextController.text.trim(),
        description: emptyToNull(_descriptionTextController.text),
        comment: emptyToNull(_commentTextController.text),
        firstEntry: StandEntryCreateModel(
          startAt: StandFormRules.combine(_date, _from),
          endAt: StandFormRules.combine(_date, _to),
          flyerCount: StandFormRules.flyerCountToSave(_flyerCountTextController.text, isAfterToday: _isAfterToday),
        ),
        imageFileLocations: newPhotos.map((photo) => photo.imageUrl).toList(),
        campaignId: getCurrentCampaignId()!,
      ),
    );
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    if (_hasChanges &&
        !await _confirm(
          message: t.campaigns.stand.discardChanges.message,
          confirm: t.campaigns.stand.discardChanges.confirm,
          decline: t.campaigns.stand.discardChanges.decline,
        )) {
      return;
    }
    if (mounted) Navigator.of(context).pop();
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
}
