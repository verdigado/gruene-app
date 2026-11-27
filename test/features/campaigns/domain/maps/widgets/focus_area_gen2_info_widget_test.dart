import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/api/campaign_api_service.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/features/campaigns/domain/maps/widgets/focus_area_gen2_info_widget.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:mocktail/mocktail.dart';

const _box = 'Intensitätsempfehlung';
const _door = 'Haustür-Wahlkampf';
const _doorRecommendation = 'Empfehlungen für den Haustürwahlkampf';
const _poster = 'Plakatieren';
const _posterRecommendation = 'Empfehlungen für die Plakatauswahl';
const _flyer = 'Flyer';
const _flyerRecommendation = 'Empfehlungen fürs Flyern';

class _MockCampaignApiService extends Mock implements CampaignApiService {}

final _campaign = Campaign(
  scope: CampaignScope.federal,
  type: CampaignType.election,
  status: CampaignStatus.active,
  id: 'campaign-1',
  name: 'BTW',
  divisionKey: '10000000000000',
  electionDate: DateTime(2029, 9, 23),
);

/// Activity keys as delivered by Atlas: 1 = door, 2 = poster, 3 = flyer.
FocusArea _focusArea({
  String? door,
  String? doorRecommendation,
  String? poster,
  String? posterRecommendation,
  String? flyer,
  String? flyerRecommendation,
}) => FocusArea(
  id: 'fa-1',
  key: '4711',
  campaignId: 'campaign-1',
  createdAt: DateTime(2026, 11, 1),
  description: 'Schöneweide',
  attributes: <String, dynamic>{
    'activity1': ?door,
    'activity_recommendation_1_label': ?doorRecommendation,
    'activity2': ?poster,
    'activity_recommendation_2_label': ?posterRecommendation,
    'activity3': ?flyer,
    'activity_recommendation_3_label': ?flyerRecommendation,
  },
  score: 1,
  polygon: Polygon(coordinates: [], type: 'Polygon'),
);

void main() {
  setUp(() {
    // answers the campaign lookup of the meta info line without a backend
    final campaignService = _MockCampaignApiService();
    when(() => campaignService.getCampaign(any())).thenAnswer((_) async => _campaign);
    GetIt.I.registerSingleton<CampaignApiService>(campaignService);
  });
  tearDown(() => GetIt.I.reset());

  Future<void> pumpInfo(WidgetTester tester, FocusArea focusArea, PoiServiceType poiType) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FocusAreaGen2InfoWidget(focusArea: focusArea, poiType: poiType),
        ),
      ),
    );
    await tester.pump(); // campaign of the meta info line
  }

  group('door tab', () {
    testWidgets('an older focus area shows the door part and the flyer part below', (tester) async {
      await pumpInfo(
        tester,
        _focusArea(
          door: '3',
          doorRecommendation: 'Viele Gespräche',
          flyer: '2',
          flyerRecommendation: 'Briefkästen in Hochhäusern',
        ),
        PoiServiceType.door,
      );

      expect(find.text(_box), findsOneWidget);
      for (final text in [_door, _doorRecommendation, 'Viele Gespräche']) {
        expect(find.text(text), findsOneWidget);
      }
      for (final text in [_flyer, _flyerRecommendation, 'Briefkästen in Hochhäusern']) {
        expect(find.text(text), findsOneWidget);
      }
      expect(find.byType(Divider), findsOneWidget);
      expect(tester.getTopLeft(find.text(_door)).dy, lessThan(tester.getTopLeft(find.text(_flyer)).dy));
      expect(tester.getTopLeft(find.byType(Divider)).dy, lessThan(tester.getTopLeft(find.text(_flyer)).dy));
    });

    testWidgets('a focus area without flyer values shows only the door part', (tester) async {
      await pumpInfo(tester, _focusArea(door: '2', doorRecommendation: 'Viele Gespräche'), PoiServiceType.door);

      expect(find.text(_door), findsOneWidget);
      expect(find.text('Viele Gespräche'), findsOneWidget);
      expect(find.text(_flyer), findsNothing);
      expect(find.text(_flyerRecommendation), findsNothing);
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('a focus area with only flyer values still shows its flyer advice', (tester) async {
      await pumpInfo(tester, _focusArea(flyerRecommendation: 'Briefkästen in Hochhäusern'), PoiServiceType.door);

      expect(find.text(_box), findsOneWidget);
      expect(find.text(_flyerRecommendation), findsOneWidget);
      expect(find.text('Briefkästen in Hochhäusern'), findsOneWidget);
      expect(find.text(_door), findsNothing);
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('a focus area without door and flyer values shows no intensity box', (tester) async {
      await pumpInfo(tester, _focusArea(poster: '3'), PoiServiceType.door);

      expect(find.text(_box), findsNothing);
    });
  });

  testWidgets('the poster tab shows only the poster part', (tester) async {
    await pumpInfo(
      tester,
      _focusArea(
        door: '3',
        poster: '1',
        posterRecommendation: 'Wenige Plakate',
        flyer: '2',
        flyerRecommendation: 'Briefkästen in Hochhäusern',
      ),
      PoiServiceType.poster,
    );

    expect(find.text(_poster), findsOneWidget);
    expect(find.text(_posterRecommendation), findsOneWidget);
    expect(find.text('Wenige Plakate'), findsOneWidget);
    expect(find.text(_door), findsNothing);
    expect(find.text(_flyer), findsNothing);
  });
}
