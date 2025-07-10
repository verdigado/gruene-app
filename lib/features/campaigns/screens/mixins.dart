import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/app_settings.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl_platform_interface/maplibre_gl_platform_interface.dart';
import 'package:motion_toast/motion_toast.dart';

part 'mixins/address_extension.dart';
part 'mixins/confirm_delete.dart';
part 'mixins/door_validator.dart';
part 'mixins/flyer_validator.dart';
part 'mixins/info_box.dart';
part 'mixins/search_mixin.dart';
