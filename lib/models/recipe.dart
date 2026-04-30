class Recipe {
  final String name;
  final String mealType;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final String totalTime;
  final String difficulty;
  final String? tips;

  Recipe({
    required this.name,
    required this.mealType,
    required this.ingredients,
    required this.steps,
    this.totalTime = '',
    this.difficulty = '',
    this.tips,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] ?? '',
      mealType: json['mealType'] ?? '',
      ingredients: (json['ingredients'] as List?)
              ?.map((e) => RecipeIngredient.fromJson(e))
              .toList() ?? [],
      steps: (json['steps'] as List?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      totalTime: json['totalTime'] ?? '',
      difficulty: json['difficulty'] ?? '',
      tips: json['tips'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'mealType': mealType,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'steps': steps,
        'totalTime': totalTime,
        'difficulty': difficulty,
        'tips': tips,
      };
}

class RecipeIngredient {
  final String name;
  final String amount;

  RecipeIngredient({required this.name, required this.amount});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] ?? '',
      amount: json['amount'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
      };
}
