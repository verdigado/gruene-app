part of '../converters.dart';

extension ProfileExtension on Profile {
  bool isVisibleInKV() {
    switch (privacy.overall) {
      case ProfilePrivacySettingsOverall.private:
      case ProfilePrivacySettingsOverall.ovWide:
        return false;
      case ProfilePrivacySettingsOverall.kvWide:
      case ProfilePrivacySettingsOverall.public:
      case ProfilePrivacySettingsOverall.lvWide:
      case ProfilePrivacySettingsOverall.bvWide:
        return true;
      case ProfilePrivacySettingsOverall.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }

  Future<Division?> getOwnKV() async {
    var division = memberships
        ?.firstWhereOrNull((d) => [DivisionLevel.kv, DivisionLevel.ov].contains(d.division.level))
        ?.division;

    switch (division?.level) {
      case DivisionLevel.kv:
        return division;
      case DivisionLevel.ov:
        var parentKey = DivisionKey(division!.divisionKey).getParentKey(DivisionLevel.kv);
        var parentDivisions = await GetIt.I<GrueneApiDivisionsService>().searchDivision(
          divisionKeys: [parentKey],
          level: DivisionLevel.kv,
        );
        return parentDivisions.firstOrNull;
      case DivisionLevel.lv:
      case DivisionLevel.bv:
      case null:
      case DivisionLevel.swaggerGeneratedUnknown:
        return null;
    }
  }
}
