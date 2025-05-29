import 'package:flutter/material.dart';

class StartGameWidget extends StatelessWidget {
  const StartGameWidget(
      {super.key, required this.callback, required this.displayText});

  final VoidCallback callback;
  final String displayText;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: const Alignment(0, 0), // centered in playing area
        child: GestureDetector(
          onTap: callback,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
                color: Colors.yellow,
                border: Border.all(color: Colors.red, width: 4), // Grey border
                borderRadius: BorderRadius.circular(15)), // Rounded corners

            child: Text(displayText,
                style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 28)),
          ),
        ));
  }
}
