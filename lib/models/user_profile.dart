import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String nickname;
  String gender;
  int age;
  double height;
  double weight;
  String fitnessLevel;
  List<String> goals;
  List<String> allergies;
  List<String> equipment;
  List<String> courses;
  String healthNotes;

  UserProfile({
    this.nickname = '',
    this.gender = '女',
    this.age = 25,
    this.height = 160,
    this.weight = 55,
    this.fitnessLevel = '初学者',
    List<String>? goals,
    List<String>? allergies,
    List<String>? equipment,
    List<String>? courses,
    this.healthNotes = '',
  })  : goals = goals ?? [],
        allergies = allergies ?? [],
        equipment = equipment ?? [],
        courses = courses ?? [];

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
      nickname: json['nickname']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '女',
      age: _parseInt(json['age'], 25),
      height: _parseDouble(json['height'], 160),
      weight: _parseDouble(json['weight'], 55),
      fitnessLevel: json['fitnessLevel']?.toString() ?? '初学者',
      goals: _parseStringList(json['goals']),
      allergies: _parseStringList(json['allergies']),
      equipment: _parseStringList(json['equipment']),
      courses: _parseStringList(json['courses']),
      healthNotes: json['healthNotes']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic v, int def) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? def;
    return def;
  }

  static double _parseDouble(dynamic v, double def) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? def;
    return def;
  }

  static List<String> _parseStringList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(toJson());
    await prefs.setString('user_profile', jsonStr);
  }

  static Future<UserProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('user_profile');
    if (jsonStr == null || jsonStr.isEmpty) return UserProfile();
    try {
      final Map<String, dynamic> json = jsonDecode(jsonStr);
      return UserProfile.fromJson(json);
    } catch (_) {
      return UserProfile();
    }
  }
}
