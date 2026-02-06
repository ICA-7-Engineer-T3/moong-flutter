import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quest_provider.dart';
import '../models/quest.dart';
import '../widgets/top_bar.dart';
import '../widgets/bottom_navigation.dart';

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

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
              TopBar(
                iconColor: const Color(0xFF1976D2),
                levelTextStyle: const TextStyle(
                  fontFamily: 'Inder',
                  fontSize: 45,
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
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

              // Quest cards from provider
              Expanded(
                child: Consumer<QuestProvider>(
                  builder: (context, questProvider, child) {
                    if (questProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1976D2),
                        ),
                      );
                    }

                    final quests = questProvider.quests;

                    if (quests.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 80,
                              color: const Color(0xFF1976D2)
                                  .withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '아직 퀘스트가 없어요',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1976D2)
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      itemCount: quests.length,
                      itemBuilder: (context, index) {
                        return _buildQuestCard(context, quests[index], index);
                      },
                    );
                  },
                ),
              ),

              // Bottom navigation
              BottomNavigation(
                layout: 'icons-only',
                showBackButton: true,
                items: [
                  NavItem(icon: Icons.restaurant_outlined, label: '', onTap: () {}),
                  NavItem(icon: Icons.fitness_center, label: '', onTap: () {}),
                  NavItem(icon: Icons.chat_bubble_outline, label: '', onTap: () {}),
                ],
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

    final colorIndex = index % colors.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            colors[colorIndex][0],
          ],
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: colors[colorIndex][1].withValues(alpha: 0.3),
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
                quest.getQuestName(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colors[colorIndex][1],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: colors[colorIndex][1].withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_walk,
                      color: colors[colorIndex][1],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      quest.getTargetText(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors[colorIndex][1],
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
                color: colors[colorIndex][1].withValues(alpha: 0.7),
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
                  color: colors[colorIndex][1],
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
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colors[colorIndex][1]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
