import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class PosterStatusHelper {
  static List<(PosterModelStatus, String)> getPosterStatusList = <(PosterModelStatus status, String label)>[
    (PosterModelStatus.ok, t.campaigns.poster.status.ok.label),
    (PosterModelStatus.damaged, t.campaigns.poster.status.damaged.label),
    (PosterModelStatus.missing, t.campaigns.poster.status.missing.label),
    (PosterModelStatus.toBeMoved, t.campaigns.poster.status.to_be_moved.label),
    (PosterModelStatus.removed, t.campaigns.poster.status.removed.label),
  ];
}
