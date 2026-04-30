class FitnessPlan {
  final String goal;
  final String summary;
  final List<DayPlan> days;

  FitnessPlan({required this.goal, required this.summary, required this.days});

  factory FitnessPlan.fromJson(Map<String, dynamic> json) {
    return FitnessPlan(
      goal: json['goal'] ?? '',
      summary: json['summary'] ?? '',
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => DayPlan.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'goal': goal,
        'summary': summary,
        'days': days.map((e) => e.toJson()).toList(),
      };
}

class DayPlan {
  final String day;
  final String focus;
  final List<Exercise> exercises;
  final String tips;

  DayPlan({
    required this.day,
    required this.focus,
    required this.exercises,
    this.tips = '',
  });

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      day: json['day'] ?? '',
      focus: json['focus'] ?? '',
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromJson(e))
              .toList() ??
          [],
      tips: json['tips'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'focus': focus,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'tips': tips,
      };
}

class Exercise {
  final String name;
  final String sets;
  final String reps;
  final String rest;
  final String? note;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.rest = '60秒',
    this.note,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      sets: json['sets'] ?? '',
      reps: json['reps'] ?? '',
      rest: json['rest'] ?? '60秒',
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets,
        'reps': reps,
        'rest': rest,
        if (note != null) 'note': note,
      };
}
