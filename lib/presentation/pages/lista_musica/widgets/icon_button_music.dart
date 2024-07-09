import 'package:flutter/material.dart';
import 'dart:math' as math;


class IconButtonUIMusic extends StatelessWidget {

  final Color borderColor;
  final Color fillColor;
  final Icon icon;
  final double borderSize;
  final double? progress;
  final void Function() onTap;

  const IconButtonUIMusic({
    super.key,
    required this.borderColor,
    required this.fillColor,
    required this.icon,
    required this.borderSize,
    required this.onTap,
    this.progress = 0.0
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: ProgressPainter(
              progress: progress!,
              strokeWidth: borderSize,
              color: Colors.green,
            ),
          ),
        ), 
        Ink(
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
        ),
      ],
    );
  }
}

//* Para el efecto de barra de progreso circular
class ProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  ProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    //* Simplemente matematicas
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = math.min(size.width / 2, size.height / 2);

    //* Dibuja un arco de progreso
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, //* Inicio desde arriba
      2 * math.pi * progress, //* Ángulo de progreso
      false,
      paint,
    );
  }

  //* Lean la documentacion de esto
  //* Se devuelve siempre true porque no se tiene pensado optimizar esto, ya que es una barra de progreso simple de unico proposito
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}