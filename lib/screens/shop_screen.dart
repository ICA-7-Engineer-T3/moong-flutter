import 'package:flutter/material.dart';
import '../models/shop_item.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int selectedCategory = 0;
  final List<String> categories = ['의류', '잡화', '가구', '배경', '시즌'];
  final List<Color> categoryColors = [
    const Color(0xFFC76F69),
    const Color(0xFFBFC769),
    const Color(0xFF7AB388),
    const Color(0xFFB37A8A),
    const Color(0xFF8F7AB3),
  ];

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
              Colors.brown.shade100,
              Colors.brown.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top credits row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildCreditContainer(
                        icon: Icons.eco,
                        value: '250',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _buildCreditContainer(
                        icon: Icons.monetization_on,
                        value: '250',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Category buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(5, (index) {
                        bool isSelected = selectedCategory == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              final categoryMap = {
                                0: ShopCategory.clothes,
                                1: ShopCategory.accessories,
                                2: ShopCategory.furniture,
                                3: ShopCategory.background,
                                4: ShopCategory.season,
                              };
                              Navigator.pushNamed(
                                context,
                                '/shop-category/${categoryMap[index].toString().split('.').last}',
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColors[index]
                                    .withValues(alpha: isSelected ? 0.9 : 0.5),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                categories[index],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF01020B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main content container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC7AFA1).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        // Available items
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.8,
                          children: [
                            _buildItemCard(
                              imageUrl:
                                  'https://www.figma.com/api/mcp/asset/d4f85599-1abf-4da6-a1e0-aa3a6fc39a03',
                              price: '50',
                              currency: 'sprout',
                            ),
                            _buildItemCard(
                              imageUrl:
                                  'https://www.figma.com/api/mcp/asset/ce7987af-627b-452b-ae14-245bd4e667d0',
                              price: '100',
                              currency: 'sprout',
                            ),
                            _buildItemCard(
                              imageUrl:
                                  'https://www.figma.com/api/mcp/asset/860edf32-9663-4ae1-af1b-b2a045f23415',
                              price: '500',
                              currency: 'coin',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Locked items
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.0,
                          children: [
                            _buildLockedCard('D-08'),
                            _buildLockedCard('D-08'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Back button
                  Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 48,
                        color: Colors.brown,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditContainer({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF01020B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required String imageUrl,
    required String price,
    required String currency,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  currency == 'sprout' ? Icons.eco : Icons.monetization_on,
                  color: currency == 'sprout' ? Colors.green : Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
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

  Widget _buildLockedCard(String daysLeft) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '?',
            style: TextStyle(
              fontSize: 64,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            daysLeft,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
