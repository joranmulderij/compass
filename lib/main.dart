import 'dart:math';
import 'dart:ui';
import 'package:animated_rotation/animated_rotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:sensors/sensors.dart';

void main() {
  runApp(MaterialApp(
    color: Colors.pink,
    theme: ThemeData(primarySwatch: Colors.pink),
    home: Container(
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [Colors.pink, Colors.purple], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Compass()),
      ),
    ),
  ));
}

class Compass extends StatefulWidget {
  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  double angle = 0;
  double lastAngle = 0;
  int angleOffset = 0;
  double bubbleLeft = 0.5;
  double bubbleTop = 0.5;
  double accelerationX = 0;
  double accelerationY = 0;

  setAngle(double? newAngle) {
    if (newAngle == null) return;
    if (lastAngle > 300 && newAngle < 60) angleOffset++;
    if (newAngle > 300 && lastAngle < 60) angleOffset--;
    setState(() {
      angle = newAngle;
    });
    lastAngle = angle;
  }

  @override
  void initState() {
    super.initState();

    FlutterCompass.events!.listen((event) {
      setAngle(event.heading);
    });
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        accelerationX = event.x;
        accelerationY = event.y;
        bubbleTop = 1 - (event.y / 20 + 0.5);
        bubbleLeft = event.x / 20 + 0.5;
        if (bubbleTop > 0.95) bubbleTop = 0.95;
        if (bubbleLeft > 0.95) bubbleLeft = 0.95;
        if (bubbleTop < 0.05) bubbleTop = 0.05;
        if (bubbleLeft < 0.05) bubbleLeft = 0.05;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = min(constraints.maxHeight, constraints.maxWidth);
        return Stack(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: accelerationY),
              duration: Duration(milliseconds: 1000),
              curve: Curves.ease,
              builder: (context, accelerationY, _) => TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: accelerationX),
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.ease,
                  child: AnimatedRotation(
                    angle: -(angle + angleOffset * 360),
                    duration: Duration(milliseconds: 200),
                    child: Image.asset(
                      'assets/compass.png',
                      height: size,
                      width: size,
                    ),
                  ),
                  builder: (context, accelerationX, child) => Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(accelerationX / 20)..rotateX(accelerationY / 20),
                    child: child,
                  )
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.ease,
              top: bubbleTop * size - 15,
              left: bubbleLeft * size - 15,
              child: Container(
                width: 30,
                height: 30,
                child: GlassContainer(
                  width: 30,
                  height: 30,
                  borderWidth: 1,
                  blur: 2,
                  shape: BoxShape.circle,
                  color: Colors.white10,
                  borderColor: Colors.white12,
                  child: Container(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
