import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netvibe/components/animated_speed_counter.dart';
import 'package:netvibe/core/state-models/net_speed.dart';
import 'package:netvibe/core/state-models/show_speed.dart';
import 'package:netvibe/enums/speed_type.dart';
import 'package:provider/provider.dart';

class Speedometer extends StatefulWidget {
  const Speedometer({super.key});

  @override
  State<Speedometer> createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer> {
  bool isRunning = false;
  SpeedType currentType = SpeedType.DOWNLOAD;
  bool typeHasChanged = true;
  bool _showError = false;
  @override
  void initState() {
    super.initState();
    // context.read<NetSpeedProvider>().startTest(currentType);
  }

  _createCustomButton(BuildContext context, SpeedType type) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final icon = type == SpeedType.DOWNLOAD
        ? Icons.cloud_download_rounded
        : type == SpeedType.UPLOAD
            ? Icons.cloud_upload_rounded
            : Icons.cell_tower_outlined;
    final iconColor = currentType != type ? primaryColor : Colors.white;
    String capitalized = type.name.toString().toLowerCase();
    capitalized = capitalized[0].toUpperCase() + capitalized.substring(1);
    return GestureDetector(
      onTap: () {
        setState(() {
          currentType = type;
          isRunning = false;
          typeHasChanged = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 25,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                capitalized,
                style: TextStyle(
                    fontSize: 20,
                    color: iconColor,
                    height: 1.2,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.read<ShowSpeed>().switchWidget();
        }
      },
      child: Container(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 90,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(10),
                  height: 70,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 42, 42, 42),
                      borderRadius: BorderRadius.circular(40)),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.only(
                            left: currentType == SpeedType.DOWNLOAD
                                ? 0.0
                                : (width - 60) / 2),
                        height: double.infinity,
                        width: (width - 60) / 2,
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(40)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: (width - 60) / 2,
                            child: _createCustomButton(
                                context, SpeedType.DOWNLOAD),
                          ),
                          Container(
                            width: (width - 60) / 2,
                            child:
                                _createCustomButton(context, SpeedType.UPLOAD),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Consumer<NetSpeedProvider>(
                    builder: (context, netSpeedProvider, child) {
                  var netSpeed = netSpeedProvider.netSpeedInfos.speed ?? 0;
                  var err = netSpeedProvider.netSpeedInfos.error;
                  if (err != null) {
                    netSpeedProvider.netSpeedInfos.error = null;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _showError = true;
                        isRunning = false;
                      });

                      Future.delayed(Duration(seconds: 5), () {
                        setState(() {
                          _showError = false;
                        });
                      });
                    });
                  }
                  var percent = netSpeed / 100;
                  if (isRunning) {
                    context.read<NetSpeedProvider>().startTest(currentType);
                  } else {
                    percent = 0;
                  }
                  return AnimatedSpeedCounter(
                    percent: percent,
                  );
                }),
                const Spacer(),
                StatefulBuilder(builder: (context, setInnerState) {
                  return GestureDetector(
                      onTap: () {
                        typeHasChanged = true;
                        if (isRunning) {
                          setInnerState(() {
                            isRunning = false;
                            typeHasChanged = false;
                          });
                        } else {
                          context
                              .read<NetSpeedProvider>()
                              .startTest(currentType);
                          setInnerState(() {
                            isRunning = true;
                          });
                        }
                      },
                      child: Container(
                        width: width,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                            color: isRunning
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(40)),
                        child: Center(
                          child: Text(
                            isRunning
                                ? "Stop"
                                : typeHasChanged
                                    ? "Run"
                                    : "Rerun",
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ));
                }),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
            AnimatedPositioned(
              top: 25,
              left: _showError ? 20 : -width,
              duration: const Duration(seconds: 1),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.8),
                    borderRadius: BorderRadius.circular(15)),
                padding: EdgeInsets.all(10),
                height: 50,
                width: width - 40,
                child: const Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: Colors.white,
                    ),
                    Text(
                      "  Network test failed. Check connection.",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SpeedCounterPainter extends CustomPainter {
  final Color startColor;
  final Color endColor;
  final arcAngle = 3 * pi / 2;
  final double percent;

  SpeedCounterPainter(this.percent,
      {super.repaint, required this.startColor, required this.endColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0;
    paint.shader = SweepGradient(
      colors: [startColor, endColor],
      startAngle: 0.0,
      endAngle: 2 * pi,
      transform: const GradientRotation(pi / 2),
    ).createShader(Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    ));
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const startAngle = 3 * pi / 4;
    const sweepAngle = 3 * pi / 2;

    drawScale(canvas, size, center, radius);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
    drawNeedle(canvas, size, percent);
  }

  void drawScale(Canvas canvas, Size size, Offset center, double radius) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(.2)
      ..strokeWidth = 2.0;

    const divisions = 11;
    final lineRadius = radius + 20;
    radius += 80;

    for (int i = 0; i < divisions; i++) {
      double arcAngle = (5 * pi) / (3 * divisions);
      double angle = arcAngle * i + (4.45 * pi / 6);
      double x = center.dx + radius * 0.8 * cos(angle);
      double y = center.dy + radius * 0.8 * sin(angle);

      double startX = center.dx + lineRadius * 0.9 * cos(angle);
      double startY = center.dy + lineRadius * 0.9 * sin(angle);
      double endX = center.dx + lineRadius * 1.05 * cos(angle);
      double endY = center.dy + lineRadius * 1.05 * sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);

      final newCenter = Offset(x, y);
      drawText(
          canvas,
          TextSpan(
            text: '${i * 10}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          newCenter);
    }
  }

  void drawNeedle(Canvas canvas, Size size, double percent) {
    final center = Offset(size.width / 2, size.height / 2);
    final needleLength = size.width / 2 - 0;
    const startWidth = 6.0;
    const endWidth = 2.0;

    drawText(
        canvas,
        TextSpan(
          text: intl.NumberFormat('00.00').format(percent * 100),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        center,
        offset: const Offset(0, 60));
    final newCenter = Offset(center.dx, center.dy + 25);
    drawText(
        canvas,
        const TextSpan(
          text: 'Mbps',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        newCenter,
        offset: const Offset(0, 60));

    final path = Path()
      ..moveTo(center.dx - startWidth / 2, center.dy)
      ..lineTo(center.dx + startWidth / 2, center.dy)
      ..lineTo(center.dx + endWidth / 2, center.dy - needleLength)
      ..lineTo(center.dx - endWidth / 2, center.dy - needleLength)
      ..close();
    const startAngle = 5 * pi / 4; // Start angle in radians
    final rotationAngle =
        startAngle + (arcAngle * percent); // Calculate current angle

    // Apply rotation to the needle path
    canvas.save(); // Save the current canvas state
    canvas.translate(center.dx, center.dy); // Move to center of the canvas
    canvas.rotate(rotationAngle); // Rotate the canvas
    canvas.translate(-center.dx, -center.dy); // Move back to original position

    final needlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: startWidth,
        height: startWidth,
      ),
      needlePaint,
    );

    canvas.drawPath(path, needlePaint);
    canvas.restore();
  }

  void drawText(Canvas canvas, TextSpan text, Offset center,
      {Offset offset = Offset.zero}) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.text = text;
    textPainter.layout();
    Offset textOffset = Offset(
      center.dx - textPainter.width / 2 + offset.dx,
      center.dy - textPainter.height / 2 + offset.dy,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
