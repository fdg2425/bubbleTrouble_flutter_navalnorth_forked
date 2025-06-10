class CycleCounter {
  DateTime? _startTime;
  int _counter = 0;

  int get counter => _counter;

  void increase() {
    // memorize the time when the counter was first "used"
    // ignore: prefer_conditional_assignment
    if (_startTime == null) {
      _startTime = DateTime.now();
    }
    _counter++;
  }

  void reset() {
    _counter = 0;
    _startTime = null;
  }

  double getCountsPerSecond() {
    if (_startTime == null) return 0;

    return _counter *
        1000 /
        DateTime.now().difference(_startTime!).inMilliseconds;
  }
}
