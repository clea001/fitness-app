import 'package:flutter/material.dart';
import '../models/fitness_plan.dart';
import '../models/diet_plan.dart';
import '../services/plan_generator.dart';

class PlanProvider extends ChangeNotifier {
  FitnessPlan? _fitnessPlan;
  DietPlan? _dietPlan;
  bool _isGenerating = false;
  String? _error;

  FitnessPlan? get fitnessPlan => _fitnessPlan;
  DietPlan? get dietPlan => _dietPlan;
  bool get isGenerating => _isGenerating;
  String? get error => _error;

  Future<void> generateFitnessPlan(PlanGenerator generator, String request, {String? userProfile}) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      _fitnessPlan = await generator.generateFitnessPlan(request, userProfile: userProfile);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> generateDietPlan(PlanGenerator generator, String request, {String? userProfile}) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      _dietPlan = await generator.generateDietPlan(request, userProfile: userProfile);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void clearFitnessPlan() {
    _fitnessPlan = null;
    notifyListeners();
  }

  void clearDietPlan() {
    _dietPlan = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
