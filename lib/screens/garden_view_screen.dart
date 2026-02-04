import 'package:flutter/material.dart';

class GardenViewScreen extends StatelessWidget {
  const GardenViewScreen({super.key});

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
              const Color(0xFFE1F5FE),
              const Color(0xFFB3E5FC),
              const Color(0xFF81D4FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Garden elements
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF81C784).withValues(alpha: 0.7),
                        const Color(0xFF66BB6A),
                      ],
                    ),
                  ),
                ),
              ),

              // Moongs
              Positioned(
                bottom: 150,
                left: 50,
                child: _buildMoongIcon(Icons.pets, const Color(0xFFF48FB1)),
              ),
              Positioned(
                bottom: 180,
                right: 80,
                child: _buildMoongIcon(Icons.pets, const Color(0xFF90CAF9)),
              ),
              Positioned(
                bottom: 140,
                left: MediaQuery.of(context).size.width / 2 - 40,
                child: _buildMoongIcon(Icons.pets, const Color(0xFFFFB74D)),
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
                          '뭉들의 정원',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        _buildIconButton(
                          Icons.home,
                          () => Navigator.pushNamed(context, '/garden'),
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
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.park,
                          size: 60,
                          color: Color(0xFF66BB6A),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '평화로운 정원',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          '3마리의 뭉이가\n행복하게 지내고 있어요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            height: 1.5,
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

  Widget _buildMoongIcon(IconData icon, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 50,
        color: Colors.white,
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
        child: Icon(icon, size: 30, color: const Color(0xFF42A5F5)),
      ),
    );
  }
}
