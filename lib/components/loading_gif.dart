import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Loading extends StatefulWidget {
  final Color color;
  final double size;
  final double lineWidth;

  const Loading({
    Key key,
    this.color=Colors.white30,
    this.lineWidth = 3.0,
    this.size = 50.0,
  })  : assert(color != null),
        assert(lineWidth != null),
        assert(size != null),
        super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation1, _animation2, _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1500));
    _animation1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.linear),
      ),
    )..addListener(() => setState(() => <String, void>{}));

    _animation2 = Tween(begin: -2 / 3, end: 1 / 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.linear),
      ),
    )..addListener(() => setState(() => <String, void>{}));

    _animation3 = Tween(begin: 0.25, end: 5 / 6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: _MyCurve()),
      ),
    )..addListener(() => setState(() => <String, void>{}));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Matrix4 transform = Matrix4.identity()..rotateZ((_animation1.value) * 5 * pi / 6);
    return Center(
      child: Stack(
        alignment: const Alignment(0.1, 0.1),
        children: [
          Transform(
            transform: transform,
            alignment: FractionalOffset.center,
            child: Container(
              height: widget.size,
              width: widget.size,
              child: CustomPaint(
                foregroundPainter: RingPainter(
                  paintWidth: widget.lineWidth,
                  trackColor: widget.color,
                  progressPercent: _animation3.value,
                  startAngle: pi * _animation2.value,
                ),
              ),
            ),
          ),
          CircleAvatar(
            backgroundImage: AssetImage('images/logo_b.png'),
            radius: 20.0,
          ),
        ],
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double paintWidth;
  final Paint trackPaint;
  final Color trackColor;
  final double progressPercent;
  final double startAngle;

  RingPainter({
    this.paintWidth,
    this.progressPercent,
    this.startAngle,
    this.trackColor,
  }) : trackPaint = Paint()
    ..color = trackColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = paintWidth
    ..strokeCap = StrokeCap.square;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - paintWidth) / 2;

    final progressAngle = 2 * pi * progressPercent;

    canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        progressAngle,
        false,
        trackPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _MyCurve extends Curve {
  @override
  double transform(double t) {
    if (t <= 0.5) {
      return 2 * t;
    } else {
      return 2 * (1 - t);
    }
  }
}
