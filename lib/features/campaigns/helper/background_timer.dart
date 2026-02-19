import 'dart:async';

class BackgroundTimer {
  late Timer timer;

  BackgroundTimer({
    Duration runEvery = const Duration(minutes: 5),
    Duration? intialRunDelay = const Duration(seconds: 5),
    required void Function() onTimer,
  }) {
    timer = Timer.periodic(runEvery, (timer) => onTimer());

    // initial flush
    if (intialRunDelay != null) {
      Future.delayed(intialRunDelay, () => Timer.run(onTimer));
    }
  }
}
