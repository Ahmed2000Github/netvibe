import 'package:flutter/material.dart';
import 'package:netvibe/components/speedometer.dart';

class AnimatedSpeedCounter extends StatefulWidget {
  final double percent;

  const AnimatedSpeedCounter({super.key, required this.percent});

  @override
  _AnimatedSpeedCounterState createState() => _AnimatedSpeedCounterState();
}

class _AnimatedSpeedCounterState extends State<AnimatedSpeedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousPercent = 0.0;

  @override
  void initState() {
    super.initState();

    // Initialize the controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start animation from 0 to the initial percent
    _animation = Tween<double>(begin: _previousPercent, end: widget.percent)
        .animate(_controller)
      ..addListener(() {
        setState(() {}); // Rebuilds the widget on animation progress
      });

    _controller.forward(); // Starts the animation
  }

  @override
  void didUpdateWidget(AnimatedSpeedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation if percent changes
    if (oldWidget.percent != widget.percent) {
      _previousPercent = oldWidget.percent;
      _animation = Tween<double>(begin: _previousPercent, end: widget.percent)
          .animate(_controller);

      _controller.forward(from: 0); // Restart the animation
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final rectSize = MediaQuery.of(context).size.width * .5;
    return CustomPaint(
      size: Size(rectSize, rectSize),
      painter: SpeedCounterPainter(_animation.value,
          startColor: secondaryColor, endColor: primaryColor),
    );
  }
}
