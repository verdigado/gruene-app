import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_user_service.dart';
import 'package:gruene_app/features/campaigns/screens/teams/new_team_mixin.dart';
import 'package:gruene_app/features/campaigns/screens/teams/team_home.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> with NewTeamMixin {
  bool _loading = true;
  late UserRbacStructure _currentUserInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    setState(() => _loading = true);

    var userInfo = await GetIt.I<GrueneApiUserService>().getOwnRbac();

    setState(() {
      _loading = false;
      _currentUserInfo = userInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(alignment: Alignment.center, child: CircularProgressIndicator());
    }
    var rows = <Widget>[];
    rows.add(TeamHome(currentUser: _currentUserInfo));
    rows.add(_currentUserInfo.isCampaignManager() ? getNewTeamButton(context) : SizedBox.shrink());

    return SingleChildScrollView(child: Column(children: rows));
  }

  @override
  void reload() {
    _loadData();
  }
}
