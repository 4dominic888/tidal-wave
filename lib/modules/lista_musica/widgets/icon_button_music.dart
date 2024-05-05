import 'package:flutter/material.dart';

class IconButtonUIMusic extends StatelessWidget {

  final Color borderColor;
  final Color fillColor;
  final Icon icon;
  final double borderSize;
  final void Function() onTap;

  const IconButtonUIMusic({
    super.key,
    required this.borderColor,
    required this.fillColor,
    required this.icon,
    required this.borderSize,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderSize),
        color: fillColor,
        shape: BoxShape.circle
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(1000.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: icon,
        )
      )
    );
  }
}