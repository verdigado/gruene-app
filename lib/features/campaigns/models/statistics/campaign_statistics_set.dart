class CampaignStatisticsSet {
  final double own, division, state, germany;
  final double? subDivision;

  const CampaignStatisticsSet({
    required this.own,
    required this.division,
    required this.state,
    required this.germany,
    this.subDivision,
  });
}
