import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String nickname;
  String gender;       // 男 / 女 / 不限
  int age;
  double height;       // cm
  double weight;       // kg
  String fitnessLevel; // 初学者 / 有基础 / 进阶
  List<String> goals;  // 减脂 / 增肌 / 塑形 / 健康
  List<String> allergies;     // 忌口
  List<String> equipment;     // 身边器材
  List<String> courses;       // 已报课程
  String healthNotes;         // 健康备注（伤病等）

  UserProfile({
    this.nickname = '',
    this.gender = '女',
    this.age = 25,
    this.height = 160,
    this.weight = 55,
    this.fitnessLevel = '初学者',
    this.goals = const [],
    this.allergies = const [],
    this.equipment = const [],
    this.courses = const [],
    this.healthNotes = '',
  });

  double get bmi => height > 0 ? weight / ((height / 100) * (height / 100)) : 0;

  String get bmiLevel {
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '正常';
    if (bmi < 28) return '偏胖';
    return '肥胖';
  }

  String toPromptString() {
    final parts = <String>[];
    if (nickname.isNotEmpty) parts.add('昵称：$nickname');
    parts.add('性别：$gender');
    parts.add('年龄：$age岁');
    parts.add('身高：${height.toInt()}cm');
    parts.add('体重：${weight.toInt()}kg（BMI: ${bmi.toStringAsFixed(1)}，$bmiLevel）');
    parts.add('训练水平：$fitnessLevel');
    if (goals.isNotEmpty) parts.add('健身目标：${goals.join('、')}');
    if (allergies.isNotEmpty) parts.add('饮食忌口/过敏：${allergies.join('、')}');
    if (equipment.isNotEmpty) parts.add('可用器材：${equipment.join('、')}');
    if (courses.isNotEmpty) parts.add('已报课程：${courses.join('、')}');
    if (healthNotes.isNotEmpty) parts.add('健康备注：$healthNotes');
    return parts.join('\n');
  }

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'gender': gender,
    'age': age,
    'height': height,
    'weight': weight,
    'fitnessLevel': fitnessLevel,
    'goals': goals,
    'allergies': allergies,
    'equipment': equipment,
    'courses': courses,
    'healthNotes': healthNotes,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] ?? '',
      gender: json['gender'] ?? '女',
      age: json['age'] ?? 25,
      height: (json['height'] ?? 160).toDouble(),
      weight: (json['weight'] ?? 55).toDouble(),
      fitnessLevel: json['fitnessLevel'] ?? '初学者',
      goals: List<String>.from(json['goals'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      equipment: List<String>.from(json['equipment'] ?? []),
      courses: List<String>.from(json['courses'] ?? []),
      healthNotes: json['healthNotes'] ?? '',
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = _encodeJson(toJson());
    await prefs.setString('user_profile', jsonStr);
  }

  static Future<UserProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('user_profile');
    if (jsonStr == null || jsonStr.isEmpty) return UserProfile();
    try {
      final Map<String, dynamic> json = _decodeJson(jsonStr);
      return UserProfile.fromJson(json);
    } catch (_) {
      return UserProfile();
    }
  }

  // 简单的 JSON 编码（避免引入 dart:convert）
  static String _encodeJson(Map<String, dynamic> map) {
    final entries = map.entries.map((e) {
      final key = '"${e.key}"';
      final value = _encodeValue(e.value);
      return '$key:$value';
    }).join(',');
    return '{$entries}';
  }

  static String _encodeValue(dynamic value) {
    if (value is String) return '"${value.replaceAll('"', '\\"')}"';
    if (value is int || value is double) return '$value';
    if (value is bool) return '$value';
    if (value is List) {
      final items = value.map((e) => _encodeValue(e)).join(',');
      return '[$items]';
    }
    if (value is Map) {
      final entries = value.entries.map((e) {
        return '"${e.key}":${_encodeValue(e.value)}';
      }).join(',');
      return '{$entries}';
    }
    return '"$value"';
  }

  static Map<String, dynamic> _decodeJson(String str) {
    // 使用 dart:convert 解析
    return Map<String, dynamic>.from(
      _parseJson(str),
    );
  }

  static dynamic _parseJson(String str) {
    // 简单的 JSON 解析
    str = str.trim();
    if (str.startsWith('{')) {
      final map = <String, dynamic>{};
      str = str.substring(1, str.length - 1);
      final pairs = _splitPairs(str);
      for (final pair in pairs) {
        final colonIdx = pair.indexOf(':');
        final key = pair.substring(0, colonIdx).trim().replaceAll('"', '');
        final value = _parseJson(pair.substring(colonIdx + 1).trim());
        map[key] = value;
      }
      return map;
    }
    if (str.startsWith('[')) {
      str = str.substring(1, str.length - 1);
      if (str.trim().isEmpty) return <dynamic>[];
      final items = _splitPairs(str);
      return items.map((e) => _parseJson(e.trim())).toList();
    }
    if (str.startsWith('"') && str.endsWith('"')) {
      return str.substring(1, str.length - 1).replaceAll('\\"', '"');
    }
    if (str == 'true') return true;
    if (str == 'false') return false;
    if (str.contains('.')) return double.tryParse(str) ?? 0;
    return int.tryParse(str) ?? 0;
  }

  static List<String> _splitPairs(String str) {
    final parts = <String>[];
    int depth = 0;
    bool inString = false;
    int start = 0;
    for (int i = 0; i < str.length; i++) {
      final c = str[i];
      if (c == '"' && (i == 0 || str[i - 1] != '\\')) inString = !inString;
      if (!inString) {
        if (c == '{' || c == '[') depth++;
        if (c == '}' || c == ']') depth--;
        if (c == ',' && depth == 0) {
          parts.add(str.substring(start, i));
          start = i + 1;
        }
      }
    }
    parts.add(str.substring(start));
    return parts;
  }
}
