import 'dart:math';

import 'package:flutter/material.dart';
import 'package:netvibe/core/state-models/show_speed.dart';
import 'package:provider/provider.dart';

class GradientCircularButton extends StatelessWidget {
  final bool shouldAnimate;
  bool addSecond = false;

  GradientCircularButton({super.key, this.shouldAnimate = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        context.read<ShowSpeed>().switchWidget();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          StatefulBuilder(builder: (context, setInnerState) {
            if (!addSecond) {
              Future.delayed(const Duration(seconds: 2), () {
                setInnerState(() {
                  addSecond = true;
                });
              });
            }
            return addSecond && shouldAnimate
                ? const GradientStrokeCircle()
                : const SizedBox.shrink();
          }),
          Builder(builder: (context) {
            return shouldAnimate
                ? const GradientStrokeCircle()
                : const SizedBox.shrink();
          }),
          const Center(
            child: Text(
              'Start',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Color startColor;
  final Color endColor;

  CirclePainter(
      {super.repaint, required this.startColor, required this.endColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Create a Paint object for the circle outline
    final paint = Paint()
      ..color = Colors.blue // Outline color
      ..style = PaintingStyle.stroke // Set style to stroke
      ..strokeWidth = 10.0; // Set the stroke width
    paint.shader = LinearGradient(
      colors: [startColor, endColor], // Gradient colors
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    ));
    // Calculate the center and radius of the circle
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2; // Radius is half of the width

    // Draw the circular outline
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Return true if the painter needs to repaint
    return false;
  }
}

class GradientStrokeCircle extends StatefulWidget {
  const GradientStrokeCircle({super.key});

  @override
  _GradientStrokeCircleState createState() => _GradientStrokeCircleState();
}

class _GradientStrokeCircleState extends State<GradientStrokeCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<SmallCircle> smallCircles = [];
  final Random random = Random();
  final int maxCircles = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: false);
    _controller.addListener(() {
      if (smallCircles.length < maxCircles) {
        addNewCircle();
      }

      smallCircles.removeWhere((circle) => circle.opacity <= 0.1);
    });
  }

  void addNewCircle() {
    setState(() {
      smallCircles.add(SmallCircle());
    });
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: GradientStrokeCirclePainter(
              smallCircles: smallCircles,
              progress: _controller.value,
              startColor: secondaryColor,
              endColor: primaryColor),
          child: const SizedBox(
            width: 200,
            height: 200,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SmallCircle {
  final double angle;
  final double size;
  final double initialRadius;
  double radius;
  double opacity;

  SmallCircle()
      : angle = Random().nextDouble() * 2 * pi,
        size = Random().nextDouble() * 15 + 5,
        initialRadius = Random().nextDouble() * 80,
        radius = 0,
        opacity = 1.0;

  void update(double progress) {
    radius = initialRadius + progress * 160;
    opacity = 1 - 1 * progress;
    if (opacity < 0) {
      opacity = 0;
    }
  }
}

class GradientStrokeCirclePainter extends CustomPainter {
  final List<SmallCircle> smallCircles;
  final double progress;
  final Color startColor;
  final Color endColor;

  GradientStrokeCirclePainter(
      {required this.smallCircles,
      required this.progress,
      required this.startColor,
      required this.endColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint small circles that animate and fade out
    final smallCirclePaint = Paint();

    for (SmallCircle circle in smallCircles) {
      circle.update(progress);

      // Draw each small circle
      smallCirclePaint.color = Colors.cyan.withOpacity(circle.opacity);
      double dx = size.width / 2 + circle.radius * cos(circle.angle);
      double dy = size.height / 2 + circle.radius * sin(circle.angle);

      canvas.drawCircle(Offset(dx, dy), circle.size, smallCirclePaint);
    }

    // Draw the main circle with gradient stroke
    Paint strokePaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 10
      ..color = const Color(0xff075274).withOpacity(.9);

    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        size.width / 2 - 5, strokePaint);
    final paint = Paint()
      ..color = Colors.blue // Outline color
      ..style = PaintingStyle.stroke // Set style to stroke
      ..strokeWidth = 10.0; // Set the stroke width
    paint.shader = LinearGradient(
      colors: [startColor, endColor], // Gradient colors
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    ));
    // Calculate the center and radius of the circle
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2; // Radius is half of the width

    // Draw the circular outline
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Repaint when animation value or progress changes
  }
}
