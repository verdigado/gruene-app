import 'package:gruene_app/app/services/nominatim_service.dart';

class PosterListItemModel {
  final String id;
  final String? thumbnailUrl;
  final String? imageUrl;
  final AddressModel address;
  final String status;
  final String lastChangeStatus;
  final String lastChangeDateTime;
  final DateTime createdAt;
  final bool isCached;

  const PosterListItemModel({
    required this.id,
    required this.thumbnailUrl,
    required this.imageUrl,
    required this.address,
    required this.status,
    required this.lastChangeStatus,
    required this.lastChangeDateTime,
    required this.createdAt,
    this.isCached = false,
  });
}
