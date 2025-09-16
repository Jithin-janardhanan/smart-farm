import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/view/profile.dart';

class CurvedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CurvedAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100.0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Stack(
        children: [
          // Main curved container
          ClipPath(
            clipper: CurvedBottomClipper(),
            child: Container(
              height: preferredSize.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green[700]!,
                    Colors.green[500]!,
                    Colors.green[300]!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),

          // Creeper plant decorations
          Positioned(
            left: 10,
            bottom: 0,
            child: CustomPaint(
              size: const Size(60, 40),
              // painter: CreeperPlantPainter(),
            ),
          ),

          Positioned(
            right: 10,
            bottom: 0,
            child: Transform.scale(
              scaleX: -1, // Mirror the creeper for right side
              child: CustomPaint(
                size: const Size(60, 40),
                // painter: CreeperPlantPainter(),
              ),
            ),
          ),

          // Small leaves scattered
          Positioned(
            left: 80,
            bottom: 10,
            child: Transform.rotate(
              angle: 0.5,
              child: Icon(Icons.eco, color: Colors.green[900], size: 16),
            ),
          ),

          Positioned(
            right: 80,
            bottom: 15,
            child: Transform.rotate(
              angle: -0.3,
              child: Icon(Icons.eco, color: Colors.green[900], size: 14),
            ),
          ),

          // AppBar content
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Space for symmetry
                  // Title
                  const Text(
                    'Agrita',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  // Profile button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: () => Get.to(() => ProfileView()),
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      tooltip: 'Profile',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper for curved bottom
class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30);

    // Create curved bottom
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 15,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 30,
      size.width,
      size.height - 10,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom painter for creeper plants
class CreeperPlantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint stemPaint = Paint()
      ..color = Colors.green[800]!
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint leafPaint = Paint()
      ..color = Colors.green[700]!
      ..style = PaintingStyle.fill;

    // Draw main stem
    Path stemPath = Path();
    stemPath.moveTo(10, size.height);
    stemPath.quadraticBezierTo(15, size.height - 15, 25, size.height - 20);
    stemPath.quadraticBezierTo(35, size.height - 25, 45, size.height - 15);
    stemPath.quadraticBezierTo(50, size.height - 10, 55, size.height - 5);

    canvas.drawPath(stemPath, stemPaint);

    // Draw small leaves along the stem
    _drawLeaf(canvas, leafPaint, const Offset(15, 25), 0.3);
    _drawLeaf(canvas, leafPaint, const Offset(30, 15), -0.2);
    _drawLeaf(canvas, leafPaint, const Offset(45, 20), 0.4);
    _drawLeaf(canvas, leafPaint, const Offset(50, 10), -0.1);
  }

  void _drawLeaf(Canvas canvas, Paint paint, Offset position, double rotation) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);

    Path leafPath = Path();
    leafPath.moveTo(0, 0);
    leafPath.quadraticBezierTo(-3, -4, -1, -8);
    leafPath.quadraticBezierTo(1, -6, 3, -4);
    leafPath.quadraticBezierTo(1, -2, 0, 0);

    canvas.drawPath(leafPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
