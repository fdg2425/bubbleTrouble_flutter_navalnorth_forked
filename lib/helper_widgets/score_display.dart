import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({
    super.key,
    required this.score,
  });

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: const Alignment(0, -0.70),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
              //color: Colors.white,
              border: Border.all(color: Colors.grey, width: 4), // Grey border
              borderRadius: BorderRadius.circular(15)), // Rounded corners

          child: Text("Your score: $score",
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
        ));
  }
}
