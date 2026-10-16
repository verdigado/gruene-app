import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/design_constants.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/campaigns/core/services/team_creation_service.dart';
import 'package:gruene_app/features/campaigns/domain/teams/widgets/new_team_basic_info_widget.dart';
import 'package:gruene_app/features/campaigns/domain/teams/widgets/new_team_select_division_widget.dart';
import 'package:gruene_app/features/campaigns/domain/teams/widgets/new_team_select_team_lead_widget.dart';
import 'package:gruene_app/features/campaigns/domain/teams/widgets/new_team_select_team_member_widget.dart';
import 'package:gruene_app/features/campaigns/helper/team_helper.dart';
import 'package:gruene_app/features/campaigns/models/team/new_team_details.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

part 'mixins/new_team_flow_mixin.dart';
