import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/moong_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_nicknameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임과 비밀번호를 입력해주세요')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final moongProvider = Provider.of<MoongProvider>(context, listen: false);
    
    final success = await authProvider.login(
      _nicknameController.text,
      _passwordController.text,
    );

    if (!success) return;
    
    if (!mounted) return;
    
    // Initialize MoongProvider with user ID
    if (authProvider.currentUser != null) {
      await moongProvider.initialize(authProvider.currentUser!.id);
    }
    
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/moong-select');
  }

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
                      'https://www.figma.com/api/mcp/asset/f5e4447d-251a-4a44-bbcc-a61c34b3ed35',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            Center(
              child: Column(
                children: [
                  const SizedBox(height: 67),
                  // Moong title
                  const Text(
                    'Moong',
                    style: TextStyle(
                      fontFamily: 'Inder',
                      fontSize: 96,
                      color: Color(0xFFFEFEFE),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login form container
                  Container(
                    width: 1055,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Nickname field
                        const Text(
                          '닉네임',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Semantics(
                          label: 'Nickname Input',
                          textField: true,
                          child: Container(
                            height: 84,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB5B3D5).withValues(alpha: 1.0),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextField(
                              controller: _nicknameController,
                              style: const TextStyle(
                                fontSize: 32,
                                color: Color(0xFF241C1C),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),

                        // Password field
                        const Text(
                          'pW',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Semantics(
                          label: 'Password Input',
                          textField: true,
                          obscured: true,
                          child: Container(
                            height: 84,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB5B3D5).withValues(alpha: 1.0),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(
                                fontSize: 32,
                                color: Color(0xFF0D0C0C),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Sign up button
                            Semantics(
                              label: 'Sign Up Button',
                              button: true,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                child: Container(
                                  width: 279,
                                  height: 86,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB5B3D5),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '회원가입',
                                    style: TextStyle(
                                      fontFamily: 'Inria Sans',
                                      fontSize: 40,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 139),

                            // Login button
                            Semantics(
                              label: 'Login Button',
                              button: true,
                              child: GestureDetector(
                                onTap: _handleLogin,
                                child: Container(
                                  width: 279,
                                  height: 86,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB5B3D5),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '로그인',
                                    style: TextStyle(
                                      fontFamily: 'Inria Sans',
                                      fontSize: 40,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
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

            // Terms text
            Positioned(
              bottom: 81,
              left: 0,
              right: 0,
              child: Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Inder',
                      fontSize: 30,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: '서비스 이용 시 '),
                      TextSpan(
                        text: '서비스이용약관',
                        style: TextStyle(color: Color(0xFFEAFF00)),
                      ),
                      TextSpan(text: ' 및 '),
                      TextSpan(
                        text: '개인정보처리방침',
                        style: TextStyle(color: Color(0xFFEAFF00)),
                      ),
                      TextSpan(text: '에 동의하게 됩니다.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
