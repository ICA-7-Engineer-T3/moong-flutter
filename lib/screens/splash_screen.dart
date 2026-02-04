import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: Stack(
          children: [
            // Background image
            Positioned(
              left: -240,
              top: -28,
              child: Container(
                width: 1920,
                height: 1080,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://www.figma.com/api/mcp/asset/4c23bb9f-7af2-44eb-bd5f-ee78a50dc9fd',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Main content container
            Center(
              child: Container(
                width: 1055,
                height: 681,
                margin: const EdgeInsets.only(top: 172),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 56),
                    // Moong title
                    const Text(
                      'Moong',
                      style: TextStyle(
                        fontFamily: 'Inder',
                        fontSize: 96,
                        color: Color(0xFFFEFEFE),
                      ),
                    ),
                    const SizedBox(height: 98),
                    // Subtitle
                    const Column(
                      children: [
                        Text(
                          '기록하지 않아도',
                          style: TextStyle(
                            fontFamily: 'Inder',
                            fontSize: 50,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '스스로 자라나는 정서 동반자',
                          style: TextStyle(
                            fontFamily: 'Inder',
                            fontSize: 50,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 139),
                    // Button
                    Semantics(
                      label: 'Get Started Button',
                      button: true,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Container(
                          width: 301,
                          height: 83,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC7C6EA),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '함께하기',
                            style: TextStyle(
                              fontFamily: 'Inria Sans',
                              fontSize: 40,
                              color: Color(0xFF0A0909),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Disclaimer text at bottom
            Positioned(
              left: 604,
              bottom: 68,
              child: SizedBox(
                width: 832,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 12, right: 8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            '뭉은 상담이나 치료를 제공하지 않는 정서 동반 서비스입니다.',
                            style: TextStyle(
                              fontFamily: 'Inder',
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 12, right: 8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            '위기 상황에서는 전문가의 도움을 받는 것을 권장합니다.',
                            style: TextStyle(
                              fontFamily: 'Inder',
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
