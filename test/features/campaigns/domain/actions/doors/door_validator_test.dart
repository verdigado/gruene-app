import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/features/campaigns/domain/actions/doors/mixins.dart';

class _Validator with DoorValidator {}

const _noCountsWarning = 'Bitte gib mindestens ein Gespräch oder Material ein.';

void main() {
  final validator = _Validator();

  /// Runs the validator with a real [BuildContext], so the error toast can be checked.
  Future<({int materialOnly, int conversations})?> validate(
    WidgetTester tester,
    String conversations,
    String materialOnly,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    final result = validator.validateDoors(conversations, materialOnly, context);
    await tester.pump();
    return result;
  }

  /// Lets the toast run out, so no timers are pending when the test ends.
  Future<void> dismissToast(WidgetTester tester) => tester.pumpAndSettle(const Duration(seconds: 10));

  group('accepts', () {
    for (final (conversations, materialOnly) in [('1', '0'), ('0', '1'), ('3', '2'), ('12', '40')]) {
      testWidgets('$conversations conversations and $materialOnly material only', (tester) async {
        final result = await validate(tester, conversations, materialOnly);

        expect(result, (conversations: int.parse(conversations), materialOnly: int.parse(materialOnly)));
        expect(find.text(_noCountsWarning), findsNothing);
        await dismissToast(tester);
      });
    }

    testWidgets('a missing count as 0', (tester) async {
      final result = await validate(tester, '2', '');

      expect(result, (conversations: 2, materialOnly: 0));
      await dismissToast(tester);
    });
  });

  group('refuses with the warning', () {
    for (final (description, conversations, materialOnly) in [
      ('both counts 0', '0', '0'),
      ('both counts empty', '', ''),
      ('non-numeric input', 'abc', 'x'),
      ('a negative conversation count', '-1', '3'),
      ('a negative material only count', '3', '-1'),
    ]) {
      testWidgets(description, (tester) async {
        final result = await validate(tester, conversations, materialOnly);

        expect(result, isNull);
        expect(find.text(_noCountsWarning), findsOneWidget);
        await dismissToast(tester);
      });
    }
  });
}
