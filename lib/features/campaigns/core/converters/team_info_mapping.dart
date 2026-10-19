part of '../converters.dart';

extension TeamInfoMapping on Team {
  TeamInfo asTeamInfo() {
    return TeamInfo(id: id, divisionKey: division?.divisionKey ?? '', name: name);
  }
}

extension FindTeamsItemInfoMapping on FindTeamsItem {
  TeamInfo asTeamInfo() {
    return TeamInfo(id: id, divisionKey: '', name: name);
  }
}
