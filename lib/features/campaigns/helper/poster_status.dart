import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class PosterStatusHelper {
  static List<(PosterStatus, String)> getPosterStatusList = <(PosterStatus status, String label)>[
    (PosterStatus.ok, t.campaigns.poster.status.ok.label),
    (PosterStatus.damaged, t.campaigns.poster.status.damaged.label),
    (PosterStatus.missing, t.campaigns.poster.status.missing.label),
    (PosterStatus.toBeMoved, t.campaigns.poster.status.to_be_moved.label),
    (PosterStatus.removed, t.campaigns.poster.status.removed.label),
  ];
}
