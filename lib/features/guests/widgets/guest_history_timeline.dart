import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/horizontal_divider.dart';
import 'package:gruene_app/features/guests/utils/guests.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

const double _iconSize = 32;
const double _lineHeight = 12;

class GuestHistoryTimeline extends StatelessWidget {
  final List<GuestHistoryEntry> entries;
  final String guestName;

  const GuestHistoryTimeline({super.key, required this.entries, required this.guestName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries.indexed
          .map(
            (entry) => _TimelineEntry(
              entry: entry.$2,
              guestName: guestName,
              isFirst: entry.$1 == 0,
              isLast: entry.$1 == entries.length - 1,
            ),
          )
          .toList(),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final GuestHistoryEntry entry;
  final String guestName;
  final bool isFirst;
  final bool isLast;

  const _TimelineEntry({required this.entry, required this.guestName, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = entry.type.color(theme);
    final name = entry.type == GuestHistoryType.accepted ? guestName : entry.by?.name;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Column(
            spacing: 4,
            children: [
              _Line(visible: !isFirst),
              CircleAvatar(
                radius: _iconSize / 2,
                backgroundColor: isFirst ? color : color.withAlpha(ThemeColors.tintedBackgroundAlpha),
                child: Icon(entry.type.icon, size: 16, color: isFirst ? theme.colorScheme.surface : color),
              ),
              isFirst ? ArrowHead() : _Line(visible: !isLast),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.type.label),
              Row(
                children: [
                  Text(entry.at.formattedDate),
                  name != null ? Text(name) : null,
                ].nonNulls.withDividers(HorizontalDivider()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final bool visible;

  const _Line({required this.visible});

  @override
  Widget build(BuildContext context) =>
      Container(height: _lineHeight, width: 2, color: visible ? ThemeColors.grey200 : null);
}

class ArrowHead extends StatelessWidget {
  const ArrowHead({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(12, _lineHeight), painter: _ArrowPainter(ThemeColors.grey200));
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;

  const _ArrowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    canvas.drawRect(Rect.fromLTRB(centerX - 1, 1, centerX + 1, size.height), Paint()..color = color);
    canvas.drawPath(
      Path()
        ..moveTo(centerX - 5, 6)
        ..lineTo(centerX, 1)
        ..lineTo(centerX + 5, 6),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => oldDelegate.color != color;
}
