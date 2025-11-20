import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(
                size: const Size(120, 120),
                painter: SunburstPainter(),
              ),
              const SizedBox(height: 32),
              const Text(
                'Tulish.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Every Word, a Step Forward.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFB3D9)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw center circle
    canvas.drawCircle(center, radius, paint);

    // Draw sunburst rays
    const rayCount = 24;
    for (var i = 0; i < rayCount; i++) {
      final angle = (i * 360 / rayCount) * (3.14159 / 180);
      final startX = center.dx + (radius * 1.1) * cos(angle);
      final startY = center.dy + (radius * 1.1) * sin(angle);
      final endX = center.dx + (radius * 1.8) * cos(angle);
      final endY = center.dy + (radius * 1.8) * sin(angle);

      final path = Path();
      path.moveTo(startX, startY);
      path.lineTo(endX, endY);
      
      final rayPaint = Paint()
        ..color = const Color(0xFFFFB3D9)
        ..strokeWidth = i.isEven ? 8 : 4
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

double cos(double radians) => radians.cos();
double sin(double radians) => radians.sin();

extension on double {
  double cos() {
    return (this * 180 / 3.14159).cosRadians();
  }
  
  double sin() {
    return (this * 180 / 3.14159).sinRadians();
  }
  
  double cosRadians() {
    final x = this;
    return 1 - (x * x) / 2 + (x * x * x * x) / 24 - (x * x * x * x * x * x) / 720;
  }
  
  double sinRadians() {
    final x = this;
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120 - (x * x * x * x * x * x * x) / 5040;
  }
}
