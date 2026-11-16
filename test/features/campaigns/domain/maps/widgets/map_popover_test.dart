import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/features/campaigns/domain/maps/widgets/map_popover.dart';

const _anchor = Offset(200, 400);

void main() {
  late int closed;
  late int edited;

  setUp(() {
    closed = 0;
    edited = 0;
  });

  Future<void> pumpPopover(WidgetTester tester, {Size? desiredSize, Widget child = const Text('Inhalt')}) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                MapPopover(
                  anchor: _anchor,
                  desiredSize: desiredSize,
                  onClose: () => closed++,
                  onEdit: () => edited++,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      );

  Rect popoverRect(WidgetTester tester) =>
      tester.getRect(find.descendant(of: find.byType(FractionalTranslation), matching: find.byType(Column)).first);

  testWidgets('with a desired size, it keeps the size and position it had before', (tester) async {
    await pumpPopover(tester, desiredSize: const Size(150, 92));

    // before: left = x - width / 2, top = y - (height - 15) - 20, height = (height - 15) + 5 + arrow 10
    expect(popoverRect(tester), Rect.fromLTWH(_anchor.dx - 75, _anchor.dy - 92 - 5, 150, 92));
    expect(tester.takeException(), isNull);
  });

  testWidgets('without a desired size, it takes the size of its content, centered above the point', (tester) async {
    await pumpPopover(tester, child: const SizedBox(width: 180, height: 50));

    final rect = popoverRect(tester);
    expect(rect.width, 180 + 2 * 6, reason: 'content plus the horizontal padding of the popover');
    expect(rect.center.dx, _anchor.dx);
    expect(rect.bottom, _anchor.dy - 5, reason: 'tip of the arrow 5 px above the point');
  });

  testWidgets('without a desired size, it is at most the screen width minus margins', (tester) async {
    await pumpPopover(tester, child: Text('sehr langer Text, der nie auf eine Zeile passt ' * 5));

    final screenWidth = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(popoverRect(tester).width, screenWidth - 32);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the close button calls onClose, the edit link and the content call onEdit', (tester) async {
    await pumpPopover(tester);

    await tester.tap(find.byIcon(Icons.close_outlined));
    await tester.tap(find.text('Bearbeiten'));
    await tester.tap(find.text('Inhalt'));

    expect(closed, 1);
    expect(edited, 2);
  });
}
