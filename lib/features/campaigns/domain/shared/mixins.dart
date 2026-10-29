// Shared mixins - reusable UI and validation helpers

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/map.dart';
import 'package:gruene_app/app/geo/geo.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/extensions.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/search_bar_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl_platform_interface/maplibre_gl_platform_interface.dart';

part 'mixins/address_extension.dart';
part 'mixins/confirm_delete.dart';
part 'mixins/info_box.dart';
part 'mixins/search_mixin.dart';
