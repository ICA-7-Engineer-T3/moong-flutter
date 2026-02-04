import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class FoodItem {
  final String name;
  final IconData icon;
  final int growthBonus;
  final Color color;

  FoodItem({
    required this.name,
    required this.icon,
    required this.growthBonus,
    required this.color,
  });
}

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  int? selectedIndex;

  final List<FoodItem> foods = [
    FoodItem(
      name: '사과',
      icon: Icons.apple_outlined,
      growthBonus: 1,
      color: const Color(0xFFEF5350),
    ),
    FoodItem(
      name: '고기',
      icon: Icons.restaurant_outlined,
      growthBonus: 1,
      color: const Color(0xFF8D6E63),
    ),
    FoodItem(
      name: '사탕',
      icon: Icons.cake_outlined,
      growthBonus: 2,
      color: const Color(0xFFEC407A),
    ),
    FoodItem(
      name: '케이크',
      icon: Icons.bakery_dining_outlined,
      growthBonus: 2,
      color: const Color(0xFFFF9800),
    ),
    FoodItem(
      name: '특별식',
      icon: Icons.star_outline,
      growthBonus: 3,
      color: const Color(0xFFFDD835),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
              const Color(0xFFFFF59D),
              const Color(0xFFFFEE58),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildIconButton(
                          Icons.settings_outlined,
                          () {},
                        ),
                        const SizedBox(width: 18),
                        _buildIconButton(
                          Icons.home_outlined,
                          () {},
                        ),
                      ],
                    ),
                    Text(
                      '${authProvider.currentUser?.level ?? 1}',
                      style: const TextStyle(
                        fontFamily: 'Inder',
                        fontSize: 45,
                        color: Color(0xFFF57C00),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Title
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
                child: const Text(
                  '뭉에게 먹이를 주세요 🍎',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF57C00),
                  ),
                ),
              ),

              // Food grid
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(40),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF809E8E),
                        const Color(0xFF2D3832),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 30,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      if (index == foods.length) {
                        return _buildMysteryBox();
                      }
                      return _buildFoodCard(index);
                    },
                  ),
                ),
              ),

              // Bottom navigation
              Padding(
                padding: const EdgeInsets.all(27),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconButton(
                      Icons.arrow_back,
                      () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        _buildIconButton(Icons.restaurant_outlined, () {}),
                        const SizedBox(width: 20),
                        _buildIconButton(Icons.fitness_center, () {}),
                        const SizedBox(width: 20),
                        _buildIconButton(Icons.chat_bubble_outline, () {}),
                      ],
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

  Widget _buildFoodCard(int index) {
    final food = foods[index];
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        _showFeedDialog(food);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..scale(isSelected ? 1.1 : 1.0)
          ..rotateZ(isSelected ? 0.05 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? food.color.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.15),
              blurRadius: isSelected ? 25 : 15,
              spreadRadius: isSelected ? 5 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: food.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                food.icon,
                size: 50,
                color: food.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              food.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: food.color,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: food.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '성장 +${food.growthBonus}',
                style: TextStyle(
                  fontSize: 16,
                  color: food.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMysteryBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.help_outline,
            size: 80,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            '???',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
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
        child: Icon(icon, size: 40, color: const Color(0xFFF57C00)),
      ),
    );
  }

  void _showFeedDialog(FoodItem food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Row(
          children: [
            Icon(food.icon, color: food.color, size: 32),
            const SizedBox(width: 12),
            Text(
              '${food.name}를 주시겠어요?',
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
        content: Text(
          '뭉의 성장도가 ${food.growthBonus} 증가합니다!',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('뭉이 ${food.name}를 맛있게 먹었어요! 🎉'),
                  backgroundColor: food.color,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: food.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('주기', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
