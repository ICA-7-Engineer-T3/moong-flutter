import 'package:flutter/material.dart';
import 'dart:math' as math;

class SakuraBackgroundScreen extends StatelessWidget {
  const SakuraBackgroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFCE4EC),
              const Color(0xFFF8BBD0),
              const Color(0xFFF48FB1),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Cherry blossoms falling
              ...List.generate(30, (index) {
                return _buildFallingPetal(context, index);
              }),

              // Cherry tree silhouette
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height * 0.5,
                  ),
                  painter: TreePainter(),
                ),
              ),

              Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildIconButton(
                          Icons.arrow_back,
                          () => Navigator.pop(context),
                        ),
                        const Text(
                          '벚꽃 동산',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        _buildIconButton(
                          Icons.check,
                          () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('배경이 적용되었습니다!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Info card
                  Container(
                    margin: const EdgeInsets.all(30),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.local_florist,
                          size: 80,
                          color: Color(0xFFEC407A),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '벚꽃 동산 배경',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          '봄날 벚꽃이 흩날리는\n아름다운 동산에서\n뭉이와 함께 힐링하세요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC407A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.monetization_on,
                                size: 20,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '180 Credits',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallingPetal(BuildContext context, int index) {
    final random = math.Random(index);
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    final top = (index * 97.0) % (MediaQuery.of(context).size.height * 0.7);
    final size = 15.0 + random.nextDouble() * 20;
    
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: random.nextDouble() * math.pi * 2,
        child: Icon(
          Icons.local_florist,
          size: size,
          color: const Color(0xFFF8BBD0).withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 30, color: const Color(0xFFEC407A)),
      ),
    );
  }
}

class TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8D6E63).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Tree trunk
    final trunkPath = Path();
    trunkPath.moveTo(size.width * 0.45, size.height);
    trunkPath.lineTo(size.width * 0.45, size.height * 0.6);
    trunkPath.lineTo(size.width * 0.55, size.height * 0.6);
    trunkPath.lineTo(size.width * 0.55, size.height);
    trunkPath.close();
    canvas.drawPath(trunkPath, paint);

    // Branches
    final branchPaint = Paint()
      ..color = const Color(0xFFF48FB1).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.4),
      size.width * 0.15,
      branchPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.3),
      size.width * 0.2,
      branchPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.4),
      size.width * 0.15,
      branchPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
