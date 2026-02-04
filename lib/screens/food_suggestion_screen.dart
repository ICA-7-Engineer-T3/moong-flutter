import 'package:flutter/material.dart';

class FoodSuggestionScreen extends StatelessWidget {
  const FoodSuggestionScreen({super.key});

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
              const Color(0xFFFFF9C4),
              const Color(0xFFFFEE58),
              const Color(0xFFFFD54F),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background Moong
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: 0.3,
                    child: Icon(
                      Icons.pets,
                      size: 300,
                      color: Colors.white,
                    ),
                  ),
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
                        const SizedBox(width: 60),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Message bubble
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
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
                    child: Column(
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          size: 60,
                          color: Color(0xFFFF9800),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '우울한 날,\n저녁으로 치맥 어때?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9C4),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            '가끔은 맛있는 음식으로\n기분 전환하는 것도 좋아!\n뭉도 같이 먹을래 🍗',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        _buildActionButton(
                          context,
                          '좋아! 같이 먹자',
                          Icons.restaurant,
                          const Color(0xFFFF9800),
                          () {
                            Navigator.pushNamed(context, '/food');
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildActionButton(
                          context,
                          '이미 먹었어',
                          Icons.check_circle,
                          const Color(0xFF66BB6A),
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('맛있었을 것 같아! 😊'),
                                backgroundColor: Color(0xFF66BB6A),
                              ),
                            );
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildActionButton(
                          context,
                          '다음에 먹을게',
                          Icons.schedule,
                          const Color(0xFF90CAF9),
                          () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, size: 30, color: const Color(0xFFFF9800)),
      ),
    );
  }
}
