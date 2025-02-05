import 'package:flutter/material.dart';

class MyMissile extends StatelessWidget {
  final double missileX;
  final double height;


  const MyMissile({
    super.key,
    required this.height,
    required this.missileX
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(missileX, 1),
      child: Container(
        width: 2,
        height: height,
        color: Colors.grey,
      ),
    );
  }
}