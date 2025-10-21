import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/urls.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_experience_area_service.dart';
import 'package:gruene_app/app/services/gruene_api_route_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/map_helper.dart';
import 'package:gruene_app/features/campaigns/widgets/close_edit_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/map_container.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:turf/turf.dart' as turf;

part 'mixins/map_container_experience_area_mixin.dart';
part 'mixins/map_container_route_mixin.dart';
part 'mixins/map_container_polling_station_mixin.dart';
