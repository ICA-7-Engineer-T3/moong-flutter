import 'package:flutter/material.dart';

class ForestBackgroundScreen extends StatelessWidget {
  const ForestBackgroundScreen({super.key});

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
              const Color(0xFF1B5E20),
              const Color(0xFF2E7D32),
              const Color(0xFF43A047),
              const Color(0xFF66BB6A),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Tree silhouettes
              Positioned(
                bottom: 100,
                left: 30,
                child: _buildTree(120, 200),
              ),
              Positioned(
                bottom: 80,
                right: 50,
                child: _buildTree(150, 250),
              ),
              Positioned(
                bottom: 120,
                left: MediaQuery.of(context).size.width / 2 - 50,
                child: _buildTree(100, 180),
              ),

              // Leaves falling
              ...List.generate(15, (index) {
                return _buildFallingLeaf(context, index);
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
                        const Text(
                          '신비한 숲',
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
                          Icons.forest,
                          size: 80,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '신비한 숲 배경',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          '깊은 숲 속에서\n뭉이와 함께 평화로운 시간을\n보내세요',
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
                            color: const Color(0xFF66BB6A),
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
                                '150 Credits',
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

  Widget _buildTree(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(width / 2),
          topRight: Radius.circular(width / 2),
        ),
      ),
    );
  }

  Widget _buildFallingLeaf(BuildContext context, int index) {
    final double left = (index * 73.0) % MediaQuery.of(context).size.width;
    final double top = (index * 127.0) % (MediaQuery.of(context).size.height * 0.6);
    
    return Positioned(
      left: left,
      top: top,
      child: Icon(
        Icons.eco,
        size: 25 + (index % 3) * 10,
        color: const Color(0xFF81C784).withValues(alpha: 0.7),
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
        child: Icon(icon, size: 30, color: const Color(0xFF2E7D32)),
      ),
    );
  }
}
