import "package:flutter/material.dart";

class CurvedShape extends StatelessWidget {
  const CurvedShape({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: double.infinity,
      height: 150.0,
      child: CustomPaint(painter: _MyPainter(color: color)),
    );
  }
}

class _MyPainter extends CustomPainter {
  _MyPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = color;

    Offset circleCenter = Offset(size.width / 2, size.height);

    Offset topLeft = Offset(0, 0);
    Offset bottomLeft = Offset(0, size.height / 2);
    Offset topRight = Offset(size.width, 0);
    Offset bottomRight = Offset(size.width, size.height / 2);
    Offset bottomCenter = Offset(size.width / 2, size.height);

    Offset leftCurveControlPoint = Offset(circleCenter.dx * 0.5, size.height);
    Offset rightCurveControlPoint = Offset(circleCenter.dx * 1.5, size.height);

    Path path = Path()
      ..moveTo(
        topLeft.dx,
        topLeft.dy,
      ) // this move isn't required since the start point is (0,0)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..quadraticBezierTo(
        leftCurveControlPoint.dx,
        leftCurveControlPoint.dy,
        bottomCenter.dx,
        bottomCenter.dy,
      )
      ..quadraticBezierTo(
        rightCurveControlPoint.dx,
        rightCurveControlPoint.dy,
        bottomRight.dx,
        bottomRight.dy,
      )
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
