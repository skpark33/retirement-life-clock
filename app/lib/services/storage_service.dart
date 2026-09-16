import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/retirement_plan.dart';

class StorageService {
  static const String _planKey = 'retirement_plan';
  static const String _languageKey = 'app_language';

  Future<void> savePlan(RetirementPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_planKey, jsonEncode(plan.toJson()));
  }

  Future<RetirementPlan?> loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final planJson = prefs.getString(_planKey);
    if (planJson != null) {
      return RetirementPlan.fromJson(jsonDecode(planJson));
    }
    return null;
  }

  Future<void> clearPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_planKey);
  }

  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  Future<String> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'ko';
  }
}
