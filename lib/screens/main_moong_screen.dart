import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/moong_provider.dart';
import '../providers/auth_provider.dart';

class MainMoongScreen extends StatefulWidget {
  const MainMoongScreen({super.key});

  @override
  State<MainMoongScreen> createState() => _MainMoongScreenState();
}

class _MainMoongScreenState extends State<MainMoongScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathingAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
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
    final moongProvider = Provider.of<MoongProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final activeMoong = moongProvider.activeMoong;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE8F5E9),
              const Color(0xFFC8E6C9),
              const Color(0xFFA5D6A7),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Top bar
              Positioned(
                top: 6,
                left: 18,
                right: 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildIconButton(
                          Icons.settings_outlined,
                          () => Navigator.pushNamed(context, '/settings'),
                        ),
                        const SizedBox(width: 18),
                        _buildIconButton(
                          Icons.home_outlined,
                          () => Navigator.pushReplacementNamed(context, '/'),
                        ),
                      ],
                    ),
                    Text(
                      '${authProvider.currentUser?.level ?? 1}',
                      style: const TextStyle(
                        fontFamily: 'Inder',
                        fontSize: 45,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Moong Character with Animation
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: Transform.scale(
                            scale: _breathingAnimation.value,
                            child: Hero(
                              tag: 'moong_character',
                              child: Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFFA5D6A7),
                                      const Color(0xFF66BB6A),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withValues(alpha: 0.4),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.pets,
                                    size: 140,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Text(
                        activeMoong != null
                            ? '${activeMoong.name}와 함께한 ${DateTime.now().difference(activeMoong.createdAt).inDays}일'
                            : '뭉과 함께 시작하세요!',
                        style: const TextStyle(
                          fontFamily: 'Inder',
                          fontSize: 28,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Growth Progress
              Positioned(
                right: 18,
                top: 120,
                child: _buildGrowthIndicator(activeMoong?.level ?? 1),
              ),

              // Bottom Navigation
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavButton(
                      Icons.restaurant_outlined,
                      '먹이주기',
                      () => Navigator.pushNamed(context, '/food'),
                    ),
                    _buildNavButton(
                      Icons.chat_bubble_outline,
                      '대화하기',
                      () => Navigator.pushNamed(context, '/chat'),
                    ),
                    _buildNavButton(
                      Icons.fitness_center_outlined,
                      '퀘스트',
                      () => Navigator.pushNamed(context, '/quest'),
                    ),
                  ],
                ),
              ),

              // Back button
              Positioned(
                left: 27,
                bottom: 27,
                child: _buildIconButton(
                  Icons.arrow_back,
                  () => Navigator.pop(context),
                ),
              ),

              // Garden button
              Positioned(
                right: 27,
                bottom: 27,
                child: _buildIconButton(
                  Icons.yard_outlined,
                  () => Navigator.pushNamed(context, '/garden'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthIndicator(int level) {
    return Container(
      width: 70,
      height: 600,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.spa, color: Color(0xFF16623B), size: 32),
          const Spacer(),
          // Progress bar
          Expanded(
            flex: 8,
            child: Stack(
              children: [
                Container(
                  width: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3E5DC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 40,
                    height: 56 + (level * 20).toDouble(),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16623B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$level%',
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF16623B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 83,
        height: 83,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, size: 40, color: const Color(0xFF2E7D32)),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 83,
            height: 83,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF66BB6A),
                  const Color(0xFF43A047),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF43A047).withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
