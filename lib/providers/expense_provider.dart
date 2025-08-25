import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';

class ExpenseProvider with ChangeNotifier {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _income = [];
  List<Map<String, dynamic>> _bills = [];
  List<Map<String, dynamic>> _savings = [];
  List<Map<String, dynamic>> _goals = [];

  // ===== Getters =====
  List<Map<String, dynamic>> get expenses => _expenses;
  List<Map<String, dynamic>> get income => _income;
  List<Map<String, dynamic>> get bills => _bills;
  List<Map<String, dynamic>> get savings => _savings;
  List<Map<String, dynamic>> get goals => _goals;

  double get savingGoal =>
      _goals.isNotEmpty ? (_goals.first['targetAmount'] as num).toDouble() : 0.0;

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, item) => sum + (item['amount'] as num));

  double get totalIncome =>
      _income.fold(0.0, (sum, item) => sum + (item['amount'] as num));

  double get totalSavings =>
      _savings.fold(0.0, (sum, item) => sum + (item['amount'] as num));

  // Balance now deducts savings too
  double get totalBalance => totalIncome - totalExpenses - totalSavings;

  // ===== Fetch All Data =====
  Future<void> fetchAllData() async {
    _expenses = await DBHelper.fetchExpenses();
    _income = await DBHelper.fetchIncome();
    _bills = await DBHelper.fetchBills();
    _savings = await DBHelper.fetchSavings();
    _goals = await DBHelper.fetchGoals();
    notifyListeners();
  }

  // ===== Goals =====
  Future<void> addGoal(Map<String, dynamic> goal) async {
    await DBHelper.insertGoal(goal);
    await fetchAllData();
  }

  Future<void> updateGoal(String id, Map<String, dynamic> updatedGoal) async {
    await DBHelper.updateGoal(id, updatedGoal);
    await fetchAllData();
  }

  Future<void> deleteGoal(String id) async {
    await DBHelper.deleteGoal(id);
    await fetchAllData();
  }

  // ===== Expenses =====
  Future<void> addExpense(Map<String, dynamic> expense) async {
    await DBHelper.insertExpense(expense);
    await fetchAllData();
  }

  Future<void> updateExpense(String id, Map<String, dynamic> updatedExpense) async {
    await DBHelper.updateExpense(id, updatedExpense);
    await fetchAllData();
  }

  Future<void> deleteExpense(String id) async {
    await DBHelper.deleteExpense(id);
    await fetchAllData();
  }

  // ===== Income =====
  Future<void> addIncome(Map<String, dynamic> income) async {
    await DBHelper.insertIncome(income);
    await fetchAllData();
  }

  Future<void> deleteIncome(String id) async {
    await DBHelper.deleteIncome(id);
    await fetchAllData();
  }

  // ===== Bills =====
  Future<void> addBill(Map<String, dynamic> bill) async {
    await DBHelper.insertBill(bill);
    await fetchAllData();
  }

  Future<void> deleteBill(String id) async {
    await DBHelper.deleteBill(id);
    await fetchAllData();
  }

  // ===== Savings =====
  Future<void> addSaving(Map<String, dynamic> saving) async {
    await DBHelper.insertSaving(saving);
    await fetchAllData();
  }

  Future<void> updateSaving(String id, double newAmount) async {
    await DBHelper.updateSaving(id, newAmount);
    await fetchAllData();
  }

  Future<void> deleteSaving(String id) async {
    await DBHelper.deleteSaving(id);
    await fetchAllData();
  }
}
