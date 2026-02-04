import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/moong_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moongProvider = Provider.of<MoongProvider>(context);
    final activeMoong = moongProvider.activeMoong;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE0F2F1),
              const Color(0xFFB2DFDB),
              const Color(0xFF80CBC4),
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
                    const Text(
                      '성장 통계',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00695C),
                      ),
                    ),
                    _buildIconButton(
                      Icons.info_outline,
                      () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Main stats
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Level card
                      _buildStatCard(
                        icon: Icons.star,
                        title: '현재 레벨',
                        value: 'Lv. ${activeMoong?.level ?? 1}',
                        color: const Color(0xFFFFB74D),
                        gradient: [
                          const Color(0xFFFFE082),
                          const Color(0xFFFFB74D),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Days together
                      _buildStatCard(
                        icon: Icons.calendar_today,
                        title: '함께한 날',
                        value: activeMoong != null
                            ? '${DateTime.now().difference(activeMoong.createdAt).inDays}일'
                            : '0일',
                        color: const Color(0xFF66BB6A),
                        gradient: [
                          const Color(0xFF81C784),
                          const Color(0xFF66BB6A),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Intimacy
                      _buildStatCard(
                        icon: Icons.favorite,
                        title: '친밀도',
                        value: '${activeMoong?.intimacy ?? 0}%',
                        color: const Color(0xFFEC407A),
                        gradient: [
                          const Color(0xFFF48FB1),
                          const Color(0xFFEC407A),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Activity stats
                      Container(
                        padding: const EdgeInsets.all(30),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '활동 기록',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00695C),
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildActivityRow(
                              '대화 횟수',
                              '247회',
                              Icons.chat_bubble_outline,
                              const Color(0xFF42A5F5),
                            ),
                            const SizedBox(height: 20),
                            _buildActivityRow(
                              '완료한 퀘스트',
                              '18개',
                              Icons.check_circle_outline,
                              const Color(0xFF66BB6A),
                            ),
                            const SizedBox(height: 20),
                            _buildActivityRow(
                              '준 음식',
                              '52회',
                              Icons.restaurant_outlined,
                              const Color(0xFFFFB74D),
                            ),
                            const SizedBox(height: 20),
                            _buildActivityRow(
                              '구매한 아이템',
                              '12개',
                              Icons.shopping_bag_outlined,
                              const Color(0xFFAB47BC),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Growth chart placeholder
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(30),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '성장 그래프',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00695C),
                              ),
                            ),
                            const Spacer(),
                            Center(
                              child: Icon(
                                Icons.show_chart,
                                size: 80,
                                color: const Color(0xFF00695C)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 50, color: Colors.white),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(
      String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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
        child: Icon(icon, size: 30, color: const Color(0xFF00695C)),
      ),
    );
  }
}
