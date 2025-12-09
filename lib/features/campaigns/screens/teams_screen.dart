import 'package:flutter/material.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/auth/repository/user_info.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/features/campaigns/screens/teams/new_team_mixin.dart';
import 'package:gruene_app/features/campaigns/screens/teams/team_home.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> with NewTeamMixin {
  bool _loading = true;
  late UserInfo _currentUserInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    setState(() => _loading = true);

    var userInfo = await AuthRepository().getUserInfo();

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
