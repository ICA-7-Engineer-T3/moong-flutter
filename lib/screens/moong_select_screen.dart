import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/moong.dart';
import '../providers/moong_provider.dart';
import '../providers/auth_provider.dart';

class MoongSelectScreen extends StatelessWidget {
  const MoongSelectScreen({super.key});

  Future<void> _selectMoongType(
    BuildContext context,
    MoongType type,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final moongProvider = Provider.of<MoongProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await moongProvider.createMoong(
        authProvider.currentUser!.id,
        '뭉',
        type,
      );
      
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/garden');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: Stack(
          children: [
            // Background
            Positioned(
              left: -240,
              top: -28,
              child: Container(
                width: 1920,
                height: 1080,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://www.figma.com/api/mcp/asset/340b3080-e0d2-4239-82c1-b9f3e13505c4',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Top bar
            Positioned(
              left: 0,
              top: 28,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 76),
                    child: Text(
                      'Hi ${authProvider.currentUser?.nickname ?? ""}',
                      style: const TextStyle(
                        fontFamily: 'Inder',
                        fontSize: 36,
                        color: Color(0xFFFEFEFE),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 70),
                    child: Row(
                      children: [
                        const Text(
                          '1',
                          style: TextStyle(
                            fontFamily: 'Inder',
                            fontSize: 45,
                            color: Color(0xFFFEFEFE),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.network(
                          'https://www.figma.com/api/mcp/asset/be94de7e-a32e-42a7-9b81-f4e729961d0f',
                          width: 62,
                          height: 62,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    '뭉이 어떤 존재였으면 좋겠나요?',
                    style: TextStyle(
                      fontFamily: 'Inder',
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Moong type cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMoongCard(
                        context,
                        '펫 뭉',
                        '공감 100%',
                        '"00 말에 100% 공감해!',
                        MoongType.pet,
                      ),
                      const SizedBox(width: 30),
                      _buildMoongCard(
                        context,
                        '메이트 뭉',
                        '공감 80% 이성 20%',
                        '"00감정 충분히 이해해"',
                        MoongType.mate,
                      ),
                      const SizedBox(width: 30),
                      _buildMoongCard(
                        context,
                        '가이드 뭉',
                        '공감 50% 이성 50%',
                        '"00한 감정을 느꼈구나!\n00방향으로 해볼까?"',
                        MoongType.guide,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom navigation
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 17),
                      child: Column(
                        children: [
                          Image.network(
                            'https://www.figma.com/api/mcp/asset/3d9effd8-eab3-4f9b-8b75-0ef71dd53d5e',
                            width: 83,
                            height: 83,
                          ),
                          const Text(
                            '돌아가기',
                            style: TextStyle(
                              fontFamily: 'Inder',
                              fontSize: 36,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          Image.network(
                            'https://www.figma.com/api/mcp/asset/c6bd937c-5537-4d48-8625-1e025cc65334',
                            width: 83,
                            height: 73,
                          ),
                          const Text(
                            '정원',
                            style: TextStyle(
                              fontFamily: 'Inder',
                              fontSize: 36,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 60),
                      Padding(
                        padding: const EdgeInsets.only(right: 70),
                        child: Column(
                          children: [
                            Image.network(
                              'https://www.figma.com/api/mcp/asset/ade3d063-14de-41ec-80eb-e074f047f021',
                              width: 83,
                              height: 83,
                            ),
                            const Text(
                              '설정',
                              style: TextStyle(
                                fontFamily: 'Inder',
                                fontSize: 36,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoongCard(
    BuildContext context,
    String title,
    String subtitle,
    String description,
    MoongType type,
  ) {
    return GestureDetector(
      onTap: () => _selectMoongType(context, type),
      child: Container(
        width: 358,
        height: 315,
        decoration: BoxDecoration(
          color: const Color(0xFFEFE9E9).withValues(alpha: 0.79),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inder',
                fontSize: 48,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Inder',
                fontSize: 33,
                color: Color(0xFF16623B),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inder',
                fontSize: 28,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
