// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../helper_classes/auto_repeater.dart';

class MyButton extends StatelessWidget {
  final double width;
  final bool isActive;
  final IconData icon;
  final VoidCallback? function;
  final AutoRepeater? repeater;

  static const double padding = 10;

  const MyButton(
      {super.key,
      required this.width,
      this.isActive = true,
      required this.icon,
      this.function,
      this.repeater});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        if (repeater != null) {
          // although we asked if repeater is != null, Flutter does not allow to use it in next line.
          // This is because theoretically execution might be interrupted directly before next line
          // and during this interruption "someone else" (e.g. another thread) might set repeater to null.
          // Because in our simple app this is not the case, we enforce using repeater with an "!"
          repeater!.start();
        } else if (function != null) {
          function!();
        }
      },
      onTapUp: (details) {
        print(">>> tapUp");
        if (repeater != null) {
          repeater!.stop();
        }
      },
      // Before we did not react on TapCancel. This had the effect that when the user tapped on a button
      // and then moved his finger outside the button and then moved the finger up, we did not receive the onTapUp.
      // But we receive a onTapCancel in this case.
      onTapCancel: () {
        print(">>> tapCancel");
        if (repeater != null) {
          repeater!.stop();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: isActive ? Colors.grey[100] : Colors.grey[400],
            width: width,
            child: Center(
              child: Icon(icon),
            ),
          ),
        ),
      ),
    );
  }
}
