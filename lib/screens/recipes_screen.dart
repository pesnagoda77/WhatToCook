import 'package:flutter/material.dart';
import '../data/recipes.dart';
import '../models/recipe.dart';
import '../services/fridge_service.dart';
import '../services/favorite_service.dart';
import 'recipe_detail_screen.dart';

final Map<String, (Color, IconData)> _recipeStyles = {
  'scrambled_eggs':     (const Color(0xFFFFE4B5), Icons.egg_alt_outlined),
  'pasta_tomato':       (const Color(0xFFFFD4C7), Icons.dinner_dining_outlined),
  'omelette':           (const Color(0xFFFFF8DC), Icons.egg_outlined),
  'buckwheat_chicken':  (const Color(0xFFD4C5B5), Icons.rice_bowl_outlined),
  'fried_eggs_potato':  (const Color(0xFFF5DEB3), Icons.local_dining_outlined),
  'milk_porridge':      (const Color(0xFFFFF0F0), Icons.breakfast_dining_outlined),
  'pancakes':           (const Color(0xFFFFFACD), Icons.bakery_dining_outlined),
  'cabbage_salad':      (const Color(0xFFE0F0E0), Icons.eco_outlined),
  'egg_salad':          (const Color(0xFFFFF8F0), Icons.egg_alt_outlined),
  'pasta_minced':       (const Color(0xFFFFE0D0), Icons.set_meal_outlined),
  'potato_puree_chicken': (const Color(0xFFF5E6D3), Icons.restaurant_outlined),
  'rice_egg':           (const Color(0xFFFFF8DC), Icons.rice_bowl_outlined),
  'tuna_pasta':         (const Color(0xFFFFE8E0), Icons.outdoor_grill_outlined),
  'soup_puree':         (const Color(0xFFFFE4C4), Icons.soup_kitchen_outlined),
  'stuffed_pepper':     (const Color(0xFFFFE0B5), Icons.pest_control_rodent_outlined),
  'banana_pancake':     (const Color(0xFFFFF8DC), Icons.bakery_dining_outlined),
  'cheese_toast':       (const Color(0xFFFFF5E0), Icons.breakfast_dining_outlined),
  'yogurt_berry':       (const Color(0xFFFFF0F5), Icons.icecream_outlined),
  'omelette_spinach':   (const Color(0xFFE0F0E0), Icons.grass_outlined),
  'fried_sausages_potato': (const Color(0xFFF5DEB3), Icons.local_dining_outlined),
};

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final FridgeService _fridge = FridgeService();
  final FavoriteService _favorites = FavoriteService();
  Set<String> _fridgeIds = {};
  Set<String> _favoriteIds = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _activeCategory = 'Все';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _fridge.init();
    await _favorites.init();
    setState(() {
      _fridgeIds = _fridge.getFridgeIds();
      _favoriteIds = _favorites.getFavorites();
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(String recipeId) async {
    await _favorites.toggleFavorite(recipeId);
    setState(() => _favoriteIds = _favorites.getFavorites());
  }

  List<String> get _categories {
    final cats = allRecipes.map((r) => r.category).toSet().toList();
    cats.sort();
    return ['Все', ...cats];
  }

  List<Recipe> _getFilteredRecipes() {
    var all = allRecipes;

    if (_activeCategory != 'Все') {
      all = all.where((r) => r.category == _activeCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      all = all.where((r) {
        return r.name.toLowerCase().contains(query) ||
            r.description.toLowerCase().contains(query);
      }).toList();
    }

    return all;
  }

  Color _matchColor(double rate) {
    if (rate >= 1.0) return const Color(0xFF81B29A);
    if (rate >= 0.7) return const Color(0xFFF2CC8F);
    if (rate >= 0.5) return const Color(0xFFE07A5F);
    return const Color(0xFFF4A261);
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _getFilteredRecipes();
    recipes.sort((a, b) => b.matchRate(_fridgeIds).compareTo(a.matchRate(_fridgeIds)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Рецепты'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE07A5F)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Поиск по рецептам...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey.shade400),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: recipes.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: recipes.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildCategoryFilters();
                            }
                            final recipe = recipes[index - 1];
                            final rate = recipe.matchRate(_fridgeIds);
                            return _buildRecipeCard(recipe, rate);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.isNotEmpty;
    final isFiltering = _activeCategory != 'Все';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF2CC8F).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? Icons.search_off : Icons.no_meals,
              size: 48,
              color: const Color(0xFFF2CC8F),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isSearching
                ? 'По запросу "$_searchQuery" ничего не найдено'
                : isFiltering
                    ? 'Нет рецептов в категории "$_activeCategory"'
                    : 'Нет рецептов',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF3D405B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Попробуйте другие слова'
                : isFiltering
                    ? 'Выберите другую категорию'
                    : 'Добавьте продукты в холодильник',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isActive = _activeCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeCategory = category),
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
                  category,
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
    );
  }

  Widget _buildRecipeCard(Recipe recipe, double rate) {
    final color = _matchColor(rate);
    final missing = recipe.missingIngredients(_fridgeIds);
    final isFavorite = _favoriteIds.contains(recipe.id);
    final (cardColor, icon) = _recipeStyles[recipe.id] ?? (const Color(0xFFFDF8F3), Icons.restaurant_menu_outlined);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
          );
          _loadData();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: const Color(0xFF3D405B).withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3D405B),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _toggleFavorite(recipe.id),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isFavorite
                                  ? const Color(0xFFE07A5F).withOpacity(0.1)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 20,
                              color: isFavorite ? const Color(0xFFE07A5F) : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${(rate * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipe.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildInfoChip(Icons.timer_outlined, '${recipe.prepTimeMinutes} мин'),
                        const SizedBox(width: 12),
                        _buildInfoChip(Icons.people_outline, '${recipe.servings} порц.'),
                      ],
                    ),
                    if (missing.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ...missing.entries.take(2).map((entry) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF8F3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            );
                          }),
                          if (missing.length > 2)
                            Text(
                              'ещё ${missing.length - 2}...',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
