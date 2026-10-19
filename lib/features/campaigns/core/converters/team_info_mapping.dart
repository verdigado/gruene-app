part of '../converters.dart';

extension TeamInfoMapping on Team {
  TeamInfo toTeamInfo() {
    return TeamInfo(id: id, divisionKey: division?.divisionKey ?? '', name: name);
  }
}

extension FindTeamsItemInfoMapping on FindTeamsItem {
  TeamInfo toTeamInfo() {
    return TeamInfo(id: id, divisionKey: '', name: name);
  }
}
