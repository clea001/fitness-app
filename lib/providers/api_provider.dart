import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';
import '../services/plan_generator.dart';

class ApiProvider extends ChangeNotifier {
  ApiConfig _config = ApiConfig();
  ApiService? _apiService;
  PlanGenerator? _planGenerator;
  bool _isLoading = false;
  String? _error;

  ApiConfig get config => _config;
  ApiService? get apiService => _apiService;
  PlanGenerator? get planGenerator => _planGenerator;
  bool get isLoading => _isLoading;
  bool get isConfigured => _config.isConfigured;
  String? get error => _error;

  Future<void> loadConfig() async {
    _config = await ApiConfig.load();
    if (_config.isConfigured) {
      _initServices();
    }
    notifyListeners();
  }

  Future<void> updateConfig(ApiConfig newConfig) async {
    _config = newConfig;
    try {
      await _config.save();
    } catch (_) {}
    _initServices();
    notifyListeners();
  }

  void _initServices() {
    _apiService = ApiService(_config);
    _planGenerator = PlanGenerator(_apiService!);
  }

  Future<bool> testConnection() async {
    if (_apiService == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService!.testConnection();
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
