import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/common/utils/image_provider_delegate.dart';
import 'package:gruene_app/constants/theme_data.dart';
import 'package:gruene_app/net/interests/bloc/interests_bloc.dart';
import 'package:gruene_app/net/interests/data/competence.dart';
import 'package:gruene_app/net/interests/data/subject.dart';
import 'package:gruene_app/net/interests/data/topic.dart';
import 'package:gruene_app/net/interests/repository/interests_repository.dart';
import 'package:gruene_app/screens/interests/interest_pages_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gruene_app/widget/topic_card.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

void main() {
  const double PORTRAIT_WIDTH = 1080.0;
  const double PORTRAIT_HEIGHT = 2160.0;
  group('Interests', () {
    tearDown(() async {
      resetMocktailState();
    });
    testWidgets(
        'should_send_all_interessets_And_Subjects_when_check_all_interessets_And_Subjects',
        (tester) async {
      Set<Topic> topics = {
        Topic(
            id: "1",
            name: "Testen macht Spaß",
            imageUrl: 'assets/images/Sonnenblume_rgb_aufTransparent.png'),
        Topic(
            id: "2",
            name: "Testen",
            imageUrl: 'assets/images/Sonnenblume_rgb_aufTransparent.png'),
        Topic(
            id: "3",
            name: "Flutter",
            imageUrl: 'assets/images/Sonnenblume_rgb_aufTransparent.png'),
        Topic(
            id: "4",
            name: "Flutter",
            imageUrl: 'assets/images/Sonnenblume_rgb_aufTransparent.png'),
        Topic(
            id: "5",
            name: "Flutter",
            imageUrl: 'assets/images/Sonnenblume_rgb_aufTransparent.png'),
        Topic(
            id: "6",
            name: "Flutter",
            imageUrl: 'assets/images/Sonnenblume_rgb_aufTransparent.png'),
        Topic(
            id: "7",
            name: "Flutter",
            imageUrl: 'assets/images/Sonnenblume_rgb_aufTransparent.png'),
        Topic(
            id: "8",
            name: "Flutter",
            imageUrl: 'assets/images/Sonnenblume_rgb_aufTransparent.png')
      };
      Set<Subject> subjects = {
        const Subject(id: '1', name: 'Test1'),
        const Subject(id: '2', name: 'Test2'),
        const Subject(id: '3', name: 'Test3')
      };
      Set<Competence> competence = {
        const Competence(id: '1', name: 'testen', checked: false),
        const Competence(id: '2', name: 'flutter', checked: false)
      };

      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();

      await binding.setSurfaceSize(const Size(PORTRAIT_WIDTH, PORTRAIT_HEIGHT));

      MockInterestsRepository interestsRepositoryMock =
          MockInterestsRepository();
      when(() => interestsRepositoryMock.listTopic()).thenReturn(topics);
      when(() => interestsRepositoryMock.listCompetenceAndSubject()).thenAnswer(
          (invocation) =>
              Future.value(InterestsListResult(competence, subjects)));
      when(() => interestsRepositoryMock.interestsSend(any(), any(), any()))
          .thenAnswer(
        (invocation) => Future.value(true),
      );
      final bloc = InterestsBloc(interestsRepositoryMock);

      await tester
          .pumpWidget(makeTestWidget(const InterestPagesScreen(), bloc));
      bloc.add(InterestsLoad());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('ButtonGroupNextIntro')));
      // Because of the PageTransition Animation we need to wait for 1 seconds
      await tester.pumpAndSettle();
      for (var topic in topics) {
        final topicCardKey = Key('TopicCard_${topic.id}');
        await tester.tap(find.byKey(topicCardKey));
        final topicCard =
            tester.state(find.byKey(topicCardKey)) as TopicCardState;

        expect(topicCard.checkedState, true);

        await tester.pump();
        // The grid is 2 x 2 this is the reason that we scroll on every second Card
        if (int.parse(topic.id) % 2 == 0) {
          await tester.drag(find.byKey(const Key('Interests_PageView')),
              const Offset(0.0, -150));
          await tester.pumpAndSettle();
        }
      }
      await tester.tap(find.byKey(const Key('ButtonGroupNextInterests')));
      await tester.pumpAndSettle();

      for (var com in competence) {
        await tester.tap(find.widgetWithText(ListTile, com.name));
      }

      await tester.tap(find.byKey(const Key('ButtonGroupNextCompetence')));
      await tester.pumpAndSettle();

      for (var sub in subjects) {
        await tester.tap(find.widgetWithText(ListTile, sub.name));
      }
      await tester.pump();
      bloc.add(InterestsDone(navigateToNext: false));
      await tester.pump(const Duration(seconds: 2));

      verify(
        () => interestsRepositoryMock.interestsSend(
          any(that: containsAll(topics.map((e) => e.copyWith(checked: true)))),
          any(
              that:
                  containsAll(subjects.map((e) => e.copyWith(checked: true)))),
          any(
              that: containsAll(
                  competence.map((e) => e.copyWith(checked: true)))),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      verify(
        () => interestsRepositoryMock.listTopic(),
      ).called(1);
      verify(
        () => interestsRepositoryMock.listCompetenceAndSubject(),
      ).called(1);

      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets(
        'should_send_first_interessets_And__first_Subjects_when_check_first_interessets_And_Subjects',
        (tester) async {
      Set<Topic> topics = {
        Topic(
            id: "1",
            name: "Testen macht Spaß",
            imageUrl: 'assets/images/Sonnenblume_rgb_aufTransparent.png'),
        Topic(
            id: "2",
            name: "Testen",
            imageUrl: 'assets/images/Sonnenblume_rgb_aufTransparent.png'),
        Topic(
            id: "3",
            name: "Flutter",
            imageUrl: 'assets/images/Sonnenblume_rgb_aufTransparent.png'),
      };
      Set<Subject> subjects = {
        const Subject(id: '1', name: 'Test1'),
        const Subject(id: '2', name: 'Test2'),
        const Subject(id: '3', name: 'Test3')
      };
      Set<Competence> competence = {
        const Competence(id: '1', name: 'a', checked: false),
        const Competence(id: '2', name: 'b', checked: false)
      };
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();

      await binding.setSurfaceSize(const Size(PORTRAIT_WIDTH, PORTRAIT_HEIGHT));
      MockInterestsRepository interestsRepositoryMock =
          MockInterestsRepository();
      when(() => interestsRepositoryMock.listTopic()).thenReturn(topics);
      when(() => interestsRepositoryMock.listCompetenceAndSubject()).thenAnswer(
          (invocation) =>
              Future.value(InterestsListResult(competence, subjects)));
      when(() => interestsRepositoryMock.interestsSend(any(), any(), any()))
          .thenAnswer(
        (invocation) => Future.value(true),
      );
      final bloc = InterestsBloc(interestsRepositoryMock);

      await tester
          .pumpWidget(makeTestWidget(const InterestPagesScreen(), bloc));
      bloc.add(InterestsLoad());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('ButtonGroupNextIntro')));
      // Because of the PageTransition Animation we need to wait for 1 seconds
      await tester.pumpAndSettle(const Duration(seconds: 1));
      final topicCardKey = find.byKey(Key('TopicCard_${topics.first.id}'));
      await tester.tap(topicCardKey);
      await tester.pump();
      var state = tester.state(topicCardKey) as TopicCardState;
      expect(state.checkedState, true);
      await tester.tap(find.byKey(const Key('ButtonGroupNextInterests')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.widgetWithText(ListTile, competence.first.name));
      await tester.tap(find.byKey(const Key('ButtonGroupNextCompetence')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.widgetWithText(ListTile, subjects.first.name));

      await tester.pump();
      bloc.add(InterestsDone(navigateToNext: false));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      verify(
        () => interestsRepositoryMock.interestsSend(
          any(
              that: containsAllInOrder(
                  [topics.first].map((e) => e.copyWith(checked: true)))),
          any(
              that: containsAllInOrder(
                  [subjects.first].map((e) => e.copyWith(checked: true)))),
          any(
              that: containsAllInOrder(
                  [competence.first].map((e) => e.copyWith(checked: true)))),
        ),
      );
      verify(
        () => interestsRepositoryMock.listCompetenceAndSubject(),
      ).called(1);
      verify(
        () => interestsRepositoryMock.listTopic(),
      ).called(1);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });
}

Widget makeTestWidget(Widget child, InterestsBloc bloc) {
  return MaterialApp(
    home: BlocProvider(
      create: (context) => bloc,
      child: Provider(
        create: (_) => const ImageProviderDelegate(typ: ImageProviderTyp.asset),
        child: child,
      ),
    ),
    theme: rootTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

class MockInterestsRepository extends Mock implements InterestsRepository {}
