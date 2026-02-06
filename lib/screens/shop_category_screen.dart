import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop_item.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';

class ShopCategoryScreen extends StatelessWidget {
  final ShopCategory category;

  const ShopCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getCategoryColors(category),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with currency
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildCurrencyDisplay(
                      Icons.spa_outlined,
                      '${authProvider.currentUser?.sprouts ?? 0}',
                      const Color(0xFF66BB6A),
                    ),
                    const SizedBox(width: 20),
                    _buildCurrencyDisplay(
                      Icons.monetization_on_outlined,
                      '${authProvider.currentUser?.credits ?? 0}',
                      const Color(0xFFFFB74D),
                    ),
                  ],
                ),
              ),

              // Category tabs
              _buildCategoryTabs(context),

              // Items grid
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _getCategoryItems(context, category).length,
                    itemBuilder: (context, index) {
                      return _buildItemCard(
                        context,
                        _getCategoryItems(context, category)[index],
                      );
                    },
                  ),
                ),
              ),

              // Back button
              Padding(
                padding: const EdgeInsets.all(27),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: _buildIconButton(
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getCategoryColors(ShopCategory category) {
    switch (category) {
      case ShopCategory.clothes:
        return [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)];
      case ShopCategory.accessories:
        return [const Color(0xFFFFF9C4), const Color(0xFFFFF59D)];
      case ShopCategory.furniture:
        return [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)];
      case ShopCategory.background:
        return [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)];
      case ShopCategory.season:
        return [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)];
    }
  }

  String _getCategoryName(ShopCategory category) {
    switch (category) {
      case ShopCategory.clothes:
        return '의류';
      case ShopCategory.accessories:
        return '잡화';
      case ShopCategory.furniture:
        return '가구';
      case ShopCategory.background:
        return '배경';
      case ShopCategory.season:
        return '시즌';
    }
  }

  List<ShopItem> _getCategoryItems(BuildContext context, ShopCategory category) {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final items = shopProvider.getItemsByCategory(category);

    // Fall back to empty list if provider has no data yet
    if (items.isEmpty) {
      return [];
    }

    return items;
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ShopCategory.values.map((cat) {
          final isActive = cat == category;
          return GestureDetector(
            onTap: () {
              if (!isActive) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShopCategoryScreen(category: cat),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? _getCategoryColors(cat)[1].withValues(alpha: 0.8)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getCategoryName(cat),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, ShopItem item) {
    return GestureDetector(
      onTap: item.isLocked
          ? null
          : () => _showPurchaseDialog(context, item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.isLocked) ...[
              const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'D-${item.unlockDays ?? 0}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getCategoryColors(category)[1].withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  size: 40,
                  color: _getCategoryColors(category)[1],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.currency == Currency.sprout
                        ? Icons.spa
                        : Icons.monetization_on,
                    size: 20,
                    color: item.currency == Currency.sprout
                        ? const Color(0xFF66BB6A)
                        : const Color(0xFFFFB74D),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ShopCategory category) {
    switch (category) {
      case ShopCategory.clothes:
        return Icons.checkroom;
      case ShopCategory.accessories:
        return Icons.watch;
      case ShopCategory.furniture:
        return Icons.chair;
      case ShopCategory.background:
        return Icons.landscape;
      case ShopCategory.season:
        return Icons.ac_unit;
    }
  }

  Widget _buildCurrencyDisplay(IconData icon, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
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
        child: Icon(icon, size: 40, color: _getCategoryColors(category)[1]),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, ShopItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          item.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 80,
              color: _getCategoryColors(category)[1],
            ),
            const SizedBox(height: 20),
            Text(
              '멋진 ${_getCategoryName(category)} 아이템',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.currency == Currency.sprout
                      ? Icons.spa
                      : Icons.monetization_on,
                  color: item.currency == Currency.sprout
                      ? const Color(0xFF66BB6A)
                      : const Color(0xFFFFB74D),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.price}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
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
                  content: Text('${item.name}을(를) 구매했습니다! 🎉'),
                  backgroundColor: _getCategoryColors(category)[1],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getCategoryColors(category)[1],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('구매', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
