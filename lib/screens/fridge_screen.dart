import 'package:flutter/material.dart';
import '../services/fridge_service.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  final FridgeService _fridge = FridgeService();
  Set<String> _fridgeIds = {};
  bool _isLoading = true;
  String _activeFilter = 'Все';

  final List<Map<String, dynamic>> _allProducts = [
    {'id': 'milk', 'name': 'Молоко', 'category': 'Молочные', 'icon': Icons.local_drink},
    {'id': 'butter', 'name': 'Сливочное масло', 'category': 'Молочные', 'icon': Icons.brightness_5},
    {'id': 'cheese', 'name': 'Сыр', 'category': 'Молочные', 'icon': Icons.circle},
    {'id': 'yogurt', 'name': 'Йогурт', 'category': 'Молочные', 'icon': Icons.coffee},
    {'id': 'cream', 'name': 'Сметана', 'category': 'Молочные', 'icon': Icons.water_drop},
    {'id': 'chicken_breast', 'name': 'Куриное филе', 'category': 'Мясо и птица', 'icon': Icons.restaurant},
    {'id': 'minced_meat', 'name': 'Фарш', 'category': 'Мясо и птица', 'icon': Icons.circle},
    {'id': 'sausage', 'name': 'Сосиски', 'category': 'Мясо и птица', 'icon': Icons.lunch_dining},
    {'id': 'tuna', 'name': 'Тунец консервированный', 'category': 'Мясо и птица', 'icon': Icons.set_meal},
    {'id': 'potato', 'name': 'Картофель', 'category': 'Овощи', 'icon': Icons.spa},
    {'id': 'tomato', 'name': 'Помидоры', 'category': 'Овощи', 'icon': Icons.circle},
    {'id': 'cabbage', 'name': 'Капуста', 'category': 'Овощи', 'icon': Icons.eco},
    {'id': 'carrot', 'name': 'Морковь', 'category': 'Овощи', 'icon': Icons.linear_scale},
    {'id': 'onion', 'name': 'Лук', 'category': 'Овощи', 'icon': Icons.circle},
    {'id': 'pepper', 'name': 'Перец болгарский', 'category': 'Овощи', 'icon': Icons.circle},
    {'id': 'spinach', 'name': 'Шпинат', 'category': 'Овощи', 'icon': Icons.grass},
    {'id': 'greens', 'name': 'Зелень', 'category': 'Овощи', 'icon': Icons.forest},
    {'id': 'pasta', 'name': 'Макароны', 'category': 'Крупы и макароны', 'icon': Icons.line_weight},
    {'id': 'rice', 'name': 'Рис', 'category': 'Крупы и макароны', 'icon': Icons.grain},
    {'id': 'buckwheat', 'name': 'Гречка', 'category': 'Крупы и макароны', 'icon': Icons.circle},
    {'id': 'cereal', 'name': 'Крупа', 'category': 'Крупы и макароны', 'icon': Icons.breakfast_dining},
    {'id': 'flour', 'name': 'Мука', 'category': 'Крупы и макароны', 'icon': Icons.circle},
    {'id': 'eggs', 'name': 'Яйца', 'category': 'Яйца', 'icon': Icons.egg},
    {'id': 'bread', 'name': 'Хлеб', 'category': 'Выпечка', 'icon': Icons.bakery_dining},
    {'id': 'banana', 'name': 'Банан', 'category': 'Фрукты', 'icon': Icons.circle},
    {'id': 'berries', 'name': 'Ягоды', 'category': 'Фрукты', 'icon': Icons.circle},
    {'id': 'garlic', 'name': 'Чеснок', 'category': 'Другое', 'icon': Icons.circle},
    {'id': 'oil', 'name': 'Растительное масло', 'category': 'Другое', 'icon': Icons.opacity},
    {'id': 'salt', 'name': 'Соль', 'category': 'Другое', 'icon': Icons.circle},
    {'id': 'sugar', 'name': 'Сахар', 'category': 'Другое', 'icon': Icons.circle},
    {'id': 'honey', 'name': 'Мёд', 'category': 'Другое', 'icon': Icons.circle},
    {'id': 'soy_sauce', 'name': 'Соевый соус', 'category': 'Другое', 'icon': Icons.circle},
    {'id': 'mayonnaise', 'name': 'Майонез', 'category': 'Другое', 'icon': Icons.circle},
  ];

  final Map<String, Color> _categoryColors = {
    'Молочные': const Color(0xFF81B29A),
    'Мясо и птица': const Color(0xFFE07A5F),
    'Овощи': const Color(0xFF8FCB9B),
    'Крупы и макароны': const Color(0xFFF2CC8F),
    'Яйца': const Color(0xFFF4F1DE),
    'Выпечка': const Color(0xFFD4A373),
    'Фрукты': const Color(0xFFF08080),
    'Другое': const Color(0xFF9CA3AF),
  };

  List<String> get _filters {
    final cats = _allProducts.map((p) => p['category'] as String).toSet().toList();
    return ['Все', ...cats];
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_activeFilter == 'Все') return _allProducts;
    return _allProducts.where((p) => p['category'] == _activeFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _fridge.init();
    setState(() {
      _fridgeIds = _fridge.getFridgeIds();
      _isLoading = false;
    });
  }

  Future<void> _toggle(String id) async {
    await _fridge.toggle(id);
    setState(() => _fridgeIds = _fridge.getFridgeIds());
  }

  Future<void> _clearAll() async {
    await _fridge.clearAll();
    setState(() => _fridgeIds = {});
  }

  void _showClearConfirmation() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, size: 48, color: Color(0xFFE07A5F)),
            const SizedBox(height: 16),
            const Text(
              'Очистить холодильник?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF3D405B)),
            ),
            const SizedBox(height: 8),
            Text(
              'Все выбранные продукты будут удалены',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3D405B),
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _clearAll();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE07A5F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Очистить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _fridgeIds.length;
    final totalCount = _allProducts.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Мой холодильник',
          style: TextStyle(
            color: Color(0xFF3D405B),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF3D405B)),
            onPressed: _showClearConfirmation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE07A5F)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE07A5F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$selectedCount продуктов',
                          style: const TextStyle(
                            color: Color(0xFFE07A5F),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        'Всего: $totalCount',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isActive = _activeFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _activeFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFFE07A5F) : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isActive ? const Color(0xFFE07A5F) : Colors.grey.shade300,
                                width: 1,
                              ),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE07A5F).withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isActive ? Colors.white : const Color(0xFF3D405B),
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final isSelected = _fridgeIds.contains(product['id']);
                      final categoryColor = _categoryColors[product['category']] ?? Colors.grey;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              product['icon'] as IconData,
                              color: categoryColor,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            product['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF3D405B),
                            ),
                          ),
                          subtitle: Text(
                            product['category'] as String,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Switch(
                            value: isSelected,
                            onChanged: (_) => _toggle(product['id'] as String),
                            activeColor: const Color(0xFFE07A5F),
                            activeTrackColor: const Color(0xFFE07A5F).withOpacity(0.3),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.shade300,
                          ),
                          onTap: () => _toggle(product['id'] as String),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
