import 'dart:async';
import 'dart:math';

class AnimationProvider {
  AnimationProvider({required this.duration, required this.callback});

  Duration duration;
  Function() callback;
  Timer? _timer;
  double _value = 0;
  DateTime _startTime = DateTime.now();

  // next line is a getter in arrow-syntax. If you do not like this, put the cursor
  // on the arrow symbol and in the yellow light bulb select "convert to block body"
  double get value => _value;

  void startAnimation() {
    // do not run 2 timers
    if (_timer != null) {
      return;
    }
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      var goneMilliSeconds =
          DateTime.now().difference(_startTime).inMilliseconds;
      double x = goneMilliSeconds / duration.inMilliseconds;
      // formula for easeOutCubic was taken from Gemini
      _value = 1.0 - pow(1 - x, 3);
      callback();
      if (x > 1) {
        timer.cancel();
        _timer = null;
      }
    });
  }

  void stopAnimation() {
    _timer?.cancel();
  }
}
