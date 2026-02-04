import 'package:flutter/material.dart';
import 'dart:math' as math;

class CuteMoongScreen extends StatefulWidget {
  const CuteMoongScreen({super.key});

  @override
  State<CuteMoongScreen> createState() => _CuteMoongScreenState();
}

class _CuteMoongScreenState extends State<CuteMoongScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFF9C4),
              const Color(0xFFFFEE58),
              const Color(0xFFFFEB3B),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating hearts
              ...List.generate(10, (index) {
                return _buildFloatingHeart(index);
              }),

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
                        const SizedBox(width: 60),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Cute Moong
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFFD54F),
                                const Color(0xFFFFB300),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFB300)
                                    .withValues(alpha: 0.5),
                                blurRadius: 40,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.pets,
                                size: 150,
                                color: Colors.white,
                              ),
                              // Sparkles
                              Positioned(
                                top: 30,
                                right: 30,
                                child: Icon(
                                  Icons.star,
                                  size: 40,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              Positioned(
                                bottom: 40,
                                left: 40,
                                child: Icon(
                                  Icons.star,
                                  size: 30,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Message
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '뭉이가 행복해해요! ✨',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '오늘도 함께해줘서 고마워요!\n당신 덕분에 뭉이는\n매일 행복합니다 💛',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Action button
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/main');
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFD54F),
                              const Color(0xFFFFB300),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB300)
                                  .withValues(alpha: 0.4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Text(
                          '뭉이와 놀기',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHeart(int index) {
    final random = math.Random(index);
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    final size = 20.0 + random.nextDouble() * 30;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value + index * 0.15) % 1.0;
        return Positioned(
          left: left,
          bottom: -50 + (progress * MediaQuery.of(context).size.height * 1.2),
          child: Opacity(
            opacity: 1.0 - progress,
            child: Icon(
              Icons.favorite,
              size: size,
              color: const Color(0xFFFFD54F).withValues(alpha: 0.6),
            ),
          ),
        );
      },
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
        child: Icon(icon, size: 30, color: const Color(0xFFFFB300)),
      ),
    );
  }
}
