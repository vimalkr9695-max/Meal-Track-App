import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'meal.dart';

class Storage {
  static const _mealsKey = 'meals';
  static const _budgetKey = 'budget';
  static const _userNameKey = 'userName';
  static const _remindersKey = 'reminders';

  // Save all meals
  static Future<void> saveMeals(List<Meal> meals) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = meals.map((m) => jsonEncode(m.toMap())).toList();
    await prefs.setStringList(_mealsKey, encoded);
  }

  // Load all meals
  static Future<List<Meal>> loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_mealsKey) ?? [];
    return encoded.map((e) => Meal.fromMap(jsonDecode(e))).toList();
  }

  // Save budget
  static Future<void> saveBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, budget);
  }

  // Load budget (default $400)
  static Future<double> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_budgetKey) ?? 400.0;
  }

  // Save user name
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  // Load user name
  static Future<String> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Alex Johnson';
  }

  // Save reminders toggle
  static Future<void> saveReminders(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersKey, enabled);
  }

  // Load reminders toggle
  static Future<bool> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_remindersKey) ?? false;
  }

  // Delete all data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mealsKey);
  }
}