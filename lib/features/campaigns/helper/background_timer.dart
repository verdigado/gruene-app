import 'dart:async';

class BackgroundTimer {
  late Timer timer;

  BackgroundTimer({
    Duration runEvery = const Duration(minutes: 5),
    Duration? initialRunDelay = const Duration(seconds: 5),
    required void Function() onTimer,
  }) {
    timer = Timer.periodic(runEvery, (timer) => onTimer());

    // initial flush
    if (initialRunDelay != null) {
      Future.delayed(initialRunDelay, () => Timer.run(onTimer));
    }
  }
}
