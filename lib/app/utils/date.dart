import 'dart:io';

import 'package:intl/intl.dart';

final dateFormatter = DateFormat.yMd(Platform.localeName);

DateTime dateInfinity() => DateTime(DateTime.now().year + 100);

DateTime startOfDay() => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
