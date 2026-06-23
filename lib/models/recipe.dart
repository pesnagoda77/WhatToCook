class Recipe {
  final String id;
  final String name;
  final String description;
  final Map<String, String> ingredients;
  final List<String> steps;
  final int prepTimeMinutes;
  final int servings;
  final String category;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.prepTimeMinutes,
    required this.servings,
    required this.category,
  });

  double matchRate(Set<String> fridgeIds) {
    if (ingredients.isEmpty) return 0.0;
    int have = 0;
    for (final key in ingredients.keys) {
      if (fridgeIds.contains(key)) have++;
    }
    return have / ingredients.length;
  }

  Map<String, String> missingIngredients(Set<String> fridgeIds) {
    final missing = <String, String>{};
    for (final entry in ingredients.entries) {
      if (!fridgeIds.contains(entry.key)) {
        missing[entry.key] = entry.value;
      }
    }
    return missing;
  }
}
