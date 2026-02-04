import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/quest.dart';

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final quests = [
      Quest(
        id: '1',
        userId: authProvider.currentUser?.id ?? '',
        type: QuestType.walk,
        target: 3000,
        progress: 1200,
        completed: false,
        createdAt: DateTime.now(),
      ),
      Quest(
        id: '2',
        userId: authProvider.currentUser?.id ?? '',
        type: QuestType.walk,
        target: 7000,
        progress: 0,
        completed: false,
        createdAt: DateTime.now(),
      ),
      Quest(
        id: '3',
        userId: authProvider.currentUser?.id ?? '',
        type: QuestType.walk,
        target: 10000,
        progress: 0,
        completed: false,
        createdAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE3F2FD),
              const Color(0xFFBBDEFB),
              const Color(0xFF90CAF9),
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
                          context,
                          Icons.settings_outlined,
                          () {},
                        ),
                        const SizedBox(width: 18),
                        _buildIconButton(
                          context,
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
                        color: Color(0xFF1976D2),
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
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Text(
                  '오늘의 퀘스트 🎯',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),

              // Quest cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  itemCount: quests.length,
                  itemBuilder: (context, index) {
                    return _buildQuestCard(context, quests[index], index);
                  },
                ),
              ),

              // Bottom navigation
              Padding(
                padding: const EdgeInsets.all(27),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconButton(
                      context,
                      Icons.arrow_back,
                      () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        _buildIconButton(context, Icons.restaurant_outlined,
                            () {}),
                        const SizedBox(width: 20),
                        _buildIconButton(context, Icons.fitness_center, () {}),
                        const SizedBox(width: 20),
                        _buildIconButton(
                            context, Icons.chat_bubble_outline, () {}),
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

  Widget _buildQuestCard(BuildContext context, Quest quest, int index) {
    final progress = quest.progress / quest.target;
    final colors = [
      [const Color(0xFFFFCDD2), const Color(0xFFEF5350)],
      [const Color(0xFFC5E1A5), const Color(0xFF66BB6A)],
      [const Color(0xFFCE93D8), const Color(0xFFAB47BC)],
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            colors[index][0],
          ],
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: colors[index][1].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '퀘스트 ${index + 1}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colors[index][1],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: colors[index][1].withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_walk,
                      color: colors[index][1],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${quest.target.toString()}보',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors[index][1],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Moong character placeholder
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Icon(
                Icons.pets,
                size: 120,
                color: colors[index][1].withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${quest.progress} / ${quest.target}',
                style: TextStyle(
                  fontSize: 20,
                  color: colors[index][1],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 18,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(colors[index][1]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
      BuildContext context, IconData icon, VoidCallback onTap) {
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
        child: Icon(icon, size: 40, color: const Color(0xFF1976D2)),
      ),
    );
  }
}
