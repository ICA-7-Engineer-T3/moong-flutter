import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/moong_provider.dart';
import '../providers/auth_provider.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final moongProvider = Provider.of<MoongProvider>(context);

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
                      'https://www.figma.com/api/mcp/asset/8de7dbef-135e-419b-ac31-1d62c679a66e',
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
                        Text(
                          '${authProvider.currentUser?.level ?? 1}',
                          style: const TextStyle(
                            fontFamily: 'Inder',
                            fontSize: 45,
                            color: Color(0xFFFEFEFE),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.network(
                          'https://www.figma.com/api/mcp/asset/bb19979a-4269-4180-bab3-aeaca3d942eb',
                          width: 62,
                          height: 62,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Moong cards grid
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // First Moong (existing)
                    if (moongProvider.moongs.isNotEmpty)
                      _buildMoongCard(
                        context,
                        moongProvider.moongs.first,
                      ),
                    const SizedBox(width: 30),

                    // Add new Moong button
                    _buildAddMoongButton(context),
                    const SizedBox(width: 30),

                    // Third slot
                    _buildAddMoongButton(context),
                  ],
                ),
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
                            'https://www.figma.com/api/mcp/asset/48108391-ad21-4da5-99d4-59f1f9688e3b',
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
                            'https://www.figma.com/api/mcp/asset/4a624df8-58bd-4e05-9229-a41549a19971',
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
                              'https://www.figma.com/api/mcp/asset/54a9753e-4084-4848-bc93-bc66af244e90',
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

  Widget _buildMoongCard(BuildContext context, moong) {
    return Container(
      width: 358,
      height: 428,
      decoration: BoxDecoration(
        color: const Color(0xFFEFE9E9).withValues(alpha: 0.79),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // Moong image placeholder
          Container(
            width: 196,
            height: 242,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: Icon(Icons.pets, size: 100, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'lv. ${moong.level.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontFamily: 'Inder',
              fontSize: 33,
              color: Color(0xFF16623B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            moong.createdAt.toString().substring(0, 10),
            style: const TextStyle(
              fontFamily: 'Inder',
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          // Progress bar
          Container(
            width: 320,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFBDC9B4).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Stack(
              children: [
                Container(
                  width: 116,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16623B).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoongButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/moong-select');
      },
      child: Container(
        width: 358,
        height: 428,
        decoration: BoxDecoration(
          color: const Color(0xFFEFE9E9).withValues(alpha: 0.79),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: Image.network(
            'https://www.figma.com/api/mcp/asset/201f6060-b3b8-4f5e-a3bf-3666c8200dd9',
            width: 185,
            height: 185,
          ),
        ),
      ),
    );
  }
}
