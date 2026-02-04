import 'package:flutter/material.dart';

class ArchiveMainScreen extends StatelessWidget {
  const ArchiveMainScreen({super.key});

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
              const Color(0xFFFFE0B2),
              const Color(0xFFFFCC80),
              const Color(0xFFFFB74D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
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
                    _buildIconButton(
                      Icons.settings,
                      () => Navigator.pushNamed(context, '/settings'),
                    ),
                    _buildIconButton(
                      Icons.home,
                      () => Navigator.pushNamed(context, '/main'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                '추억의 정원',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                '졸업한 뭉들과의 소중한 기억',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 40),

              // Archive grid
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return _buildArchiveCard(
                        context,
                        index: index,
                        name: ['사랑 뭉', '평화 뭉', '기쁨 뭉', '희망 뭉', '행복 뭉', '새 뭉 추가'][index],
                        date: ['25.12.28', '26.01.15', '26.01.28', '26.02.03', '26.02.10', ''][index],
                        isAddNew: index == 5,
                      );
                    },
                  ),
                ),
              ),

              // Bottom navigation
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavButton(
                      '돌아가기',
                      Icons.arrow_back,
                      () => Navigator.pop(context),
                    ),
                    _buildNavButton(
                      '아카이브',
                      Icons.archive,
                      () {},
                      isActive: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchiveCard(
    BuildContext context, {
    required int index,
    required String name,
    required String date,
    bool isAddNew = false,
  }) {
    if (isAddNew) {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/moong-select');
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFE0B2).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xFFFFB74D),
              width: 3,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 80,
                color: Color(0xFFFFB74D),
              ),
              SizedBox(height: 15),
              Text(
                '새 뭉\n만들기',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFB74D),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final colors = [
      [const Color(0xFFF48FB1), const Color(0xFFEC407A)],
      [const Color(0xFF81C784), const Color(0xFF66BB6A)],
      [const Color(0xFFFFB74D), const Color(0xFFFF9800)],
      [const Color(0xFF90CAF9), const Color(0xFF42A5F5)],
      [const Color(0xFFCE93D8), const Color(0xFFAB47BC)],
    ];

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/archive');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors[index % 5],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: colors[index % 5][1].withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative element
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Moong icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.pets,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Date
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
        child: Icon(icon, size: 30, color: const Color(0xFFFFB74D)),
      ),
    );
  }

  Widget _buildNavButton(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFFF9800)
                  : Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isActive ? const Color(0xFFFF9800) : Colors.black)
                      .withValues(alpha: 0.2),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 35,
              color: isActive ? Colors.white : const Color(0xFFFFB74D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
