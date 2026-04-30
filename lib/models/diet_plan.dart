class DietPlan {
  final String goal;
  final String summary;
  final String dailyCalories;
  final List<MealPlan> meals;

  DietPlan({
    required this.goal,
    required this.summary,
    this.dailyCalories = '',
    required this.meals,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    return DietPlan(
      goal: json['goal'] ?? '',
      summary: json['summary'] ?? '',
      dailyCalories: json['dailyCalories'] ?? '',
      meals: (json['meals'] as List<dynamic>?)
              ?.map((e) => MealPlan.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'goal': goal,
        'summary': summary,
        'dailyCalories': dailyCalories,
        'meals': meals.map((e) => e.toJson()).toList(),
      };
}

class MealPlan {
  final String mealType;
  final String menu;
  final String calories;
  final String tips;
  final List<String> items;

  MealPlan({
    required this.mealType,
    required this.menu,
    this.calories = '',
    this.tips = '',
    this.items = const [],
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      mealType: json['mealType'] ?? '',
      menu: json['menu'] ?? '',
      calories: json['calories'] ?? '',
      tips: json['tips'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'mealType': mealType,
        'menu': menu,
        'calories': calories,
        'tips': tips,
        'items': items,
      };
}
