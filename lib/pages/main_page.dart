import 'package:flutter/material.dart';
import 'package:netvibe/components/speedometer.dart';
import 'package:netvibe/components/start.dart';
import 'package:netvibe/core/state-models/show_speed.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // First color
                    bgColor,
                    const Color(0xff075274).withOpacity(.3) // Second color
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  const Column(
                    children: [
                      SizedBox(
                        height: 60,
                      ),
                      Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            "Internet Speed Test",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Consumer<ShowSpeed>(
                    builder: (context, showSpeed, child) {
                      final double leftPosition =
                          showSpeed.isOpen ? 0 : -size.width;
                      return AnimatedPositioned(
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOut,
                          left: leftPosition,
                          top: 90,
                          child: SizedBox(
                              width: size.width,
                              height: size.height - 110,
                              child: Speedometer()));
                    },
                  ),
                  Consumer<ShowSpeed>(
                    builder: (context, showSpeed, child) {
                      final double leftPosition =
                          showSpeed.isOpen ? -size.width : 0;
                      return AnimatedPositioned(
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOut,
                          left: leftPosition,
                          child: SizedBox(
                              width: size.width,
                              height: size.height,
                              child: Center(
                                  child: GradientCircularButton(
                                      shouldAnimate: !showSpeed.isOpen))));
                    },
                  ),
                ],
              ),
            ),
            Consumer<ShowSpeed>(builder: (context, showSpeed, child) {
              final double leftPosition = showSpeed.isOpen ? 10 : -100;
              return AnimatedPositioned(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                left: leftPosition,
                top: 54,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    context.read<ShowSpeed>().switchWidget();
                  },
                  shape: const CircleBorder(),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
