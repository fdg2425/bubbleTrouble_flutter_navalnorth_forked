import 'package:flutter/material.dart';
import 'auto_repeater.dart';

class MyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? function;
  final AutoRepeater? repeater;

  const MyButton({super.key, required this.icon, this.function, this.repeater});

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
        if (repeater != null) {
          repeater!.stop();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.grey[100],
            width: 100,
            // height: 50,
            child: Center(
              child: Icon(icon),
            ),
          ),
        ),
      ),
    );
  }
}
