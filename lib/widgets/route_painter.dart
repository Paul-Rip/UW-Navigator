import 'package:flutter/material.dart';

//CustomPainter that draws the walking route on the map screen using Canvas Path API
//Takes a list of screen coordinate offsets converted from GPS coordinates
//and draws an orange line connecting them with start and destination circles
class RoutePainter extends CustomPainter {
  final List<Offset> routePoints;

  RoutePainter({required this.routePoints});

  //Draws the route path and endpoint circles onto the canvas
  //Uses Path moveTo and lineTo to draw the route segment by segment
  //Parameters:
  //  - canvas: First Variable Canvas to draw on
  //  - size: Second Variable Size of the canvas area
  //No Returns
  @override
  void paint(Canvas canvas, Size size) {
    if (routePoints.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFFFF6F00)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(routePoints.first.dx, routePoints.first.dy);
    for (int i = 1; i < routePoints.length; i++) {
      path.lineTo(routePoints[i].dx, routePoints[i].dy);
    }
    canvas.drawPath(path, paint);

    // Start circle
    canvas.drawCircle(routePoints.first, 8,
        Paint()..color = const Color(0xFFFF6F00)..style = PaintingStyle.fill);
    canvas.drawCircle(routePoints.first, 4,
        Paint()..color = Colors.white..style = PaintingStyle.fill);

    // Destination circle
    canvas.drawCircle(routePoints.last, 12,
        Paint()..color = const Color(0xFFFF6F00)..style = PaintingStyle.fill);
    canvas.drawCircle(routePoints.last, 6,
        Paint()..color = Colors.white..style = PaintingStyle.fill);
  }

  //Returns true if the route points have changed requiring a redraw
  //Called by Flutter to determine if the canvas needs to be repainted
  //Parameters:
  //  - oldDelegate: First Variable RoutePainter previous painter instance
  //Returns bool true if routePoints changed, false if unchanged
  @override
  bool shouldRepaint(RoutePainter oldDelegate) =>
      routePoints != oldDelegate.routePoints;
}