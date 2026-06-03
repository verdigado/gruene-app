part of '../converters.dart';

extension ProfileExtension on Profile {
  bool isVisibleInKV() {
    switch (privacy.overall) {
      case Visibility.private:
      case Visibility.ovWide:
        return false;
      case Visibility.kvWide:
      case Visibility.public:
      case Visibility.lvWide:
      case Visibility.bvWide:
        return true;
      case Visibility.swaggerGeneratedUnknown:
        throw UnimplementedError();
    }
  }

  Future<Division?> getOwnKV() async {
    final division = memberships
        .firstWhereOrNull((d) => [DivisionLevel.kv, DivisionLevel.ov].contains(d.division.level))
        ?.division;

    switch (division?.level) {
      case DivisionLevel.kv:
        return division;
      case DivisionLevel.ov:
        final parentKey = division!.parentDivisionKey(DivisionLevel.kv);
        final parentDivisions = await GetIt.I<GrueneApiDivisionsService>().searchDivision(
          divisionKeys: [parentKey],
          level: DivisionLevel.kv,
        );
        return parentDivisions.firstOrNull;
      default:
        return null;
    }
  }
}
