import 'dart:async';

import 'package:flutter/material.dart';

// The code for this class was more or less taken from Gemini after asking: "flutter keyboardlistener autorepeat"
// BTW: Gemini said to this question:
//   Unfortunately, the built-in KeyboardListener in Flutter doesn't directly provide an autorepeat mechanism out of the box.

class AutoRepeater {
  AutoRepeater(this.callback);

  VoidCallback callback;
  // the folowing lines work too:
  //void Function() callback;
  //Function callback;

  Timer? _timer;

  void start() {
    if (_timer != null) {
      return; // Already repeating
    }
    // perform the action once directly
    callback();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      callback();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
