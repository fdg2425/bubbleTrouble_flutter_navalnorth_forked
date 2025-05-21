import 'package:flutter/material.dart';

class GameOverWidget extends StatelessWidget {
  const GameOverWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: const Alignment(0, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.yellow,
              border: Border.all(color: Colors.red, width: 4), // Grey border
              borderRadius: BorderRadius.circular(15)), // Rounded corners

          child: Text("Game over !",
              style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 28)),
        ));
  }
}
