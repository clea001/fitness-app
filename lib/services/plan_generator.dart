import 'dart:convert';
import 'api_service.dart';
import '../models/fitness_plan.dart';
import '../models/diet_plan.dart';

class PlanGenerator {
  final ApiService api;

  PlanGenerator(this.api);

  Future<FitnessPlan> generateFitnessPlan(String userRequest, {String? userProfile}) async {
    final systemPrompt = '''你是一位专业的健身教练。请根据用户的需求生成一份周健身计划。

你必须以严格的 JSON 格式回复，不要包含任何其他文字。JSON 格式如下：
{
  "goal": "用户的健身目标",
  "summary": "计划概述",
  "days": [
    {
      "day": "周一",
      "focus": "训练重点",
      "exercises": [
        {
          "name": "动作名称",
          "sets": "组数（如3组）",
          "reps": "次数（如12次）",
          "rest": "休息时间",
          "note": "注意事项",
          "calories": 50
        }
      ],
      "tips": "当日小贴士"
    }
  ]
}

注意：
- calories 是该动作的预估消耗卡路里（整数），根据组数、次数、运动强度合理估算
- 包含休息日（exercises 为空数组，calories 不需要）
- 动作要具体可行
- 根据用户水平调整难度
- 中文回复''';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    if (userProfile != null && userProfile.isNotEmpty) {
      messages.add({
        'role': 'user',
        'content': '用户个人信息：\n$userProfile\n\n$userRequest',
      });
    } else {
      messages.add({'role': 'user', 'content': userRequest});
    }

    final response = await api.chat(messages);
    return _parseFitnessPlan(response);
  }

  Future<DietPlan> generateDietPlan(String userRequest, {String? userProfile}) async {
    final systemPrompt = '''你是一位专业的营养师。请根据用户的需求生成一份饮食计划。

你必须以严格的 JSON 格式回复，不要包含任何其他文字。JSON 格式如下：
{
  "goal": "用户的饮食目标",
  "summary": "计划概述",
  "dailyCalories": "每日建议热量",
  "meals": [
    {
      "mealType": "早餐",
      "menu": "菜单名称",
      "calories": "热量",
      "tips": "建议",
      "items": ["食物1", "食物2"]
    }
  ]
}

注意：
- 包含早中晚三餐和加餐
- 食材要常见易得
- 营养搭配均衡
- 如有忌口请严格避免
- 中文回复''';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    if (userProfile != null && userProfile.isNotEmpty) {
      messages.add({
        'role': 'user',
        'content': '用户个人信息：\n$userProfile\n\n$userRequest',
      });
    } else {
      messages.add({'role': 'user', 'content': userRequest});
    }

    final response = await api.chat(messages);
    return _parseDietPlan(response);
  }

  FitnessPlan _parseFitnessPlan(String response) {
    try {
      final jsonStr = _extractJson(response);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return FitnessPlan.fromJson(json);
    } catch (e) {
      return FitnessPlan(goal: '解析失败', summary: response, days: []);
    }
  }

  DietPlan _parseDietPlan(String response) {
    try {
      final jsonStr = _extractJson(response);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return DietPlan.fromJson(json);
    } catch (e) {
      return DietPlan(goal: '解析失败', summary: response, meals: []);
    }
  }

  String _extractJson(String text) {
    final jsonPattern = RegExp(r'\{[\s\S]*\}');
    final match = jsonPattern.firstMatch(text);
    if (match != null) return match.group(0)!;
    return text;
  }
}
