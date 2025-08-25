import 'package:localstorage/localstorage.dart';

class DBHelper {
  static final LocalStorage _expensesStorage = LocalStorage('expenses_data');
  static final LocalStorage _billsStorage = LocalStorage('bills_data');
  static final LocalStorage _incomeStorage = LocalStorage('income_data');
  static final LocalStorage _savingsStorage = LocalStorage('savings_data');
  static final LocalStorage _goalsStorage = LocalStorage('goals_data');

  static Future<LocalStorage> getExpensesStorage() async {
    await _expensesStorage.ready;
    return _expensesStorage;
  }

  static Future<LocalStorage> getBillsStorage() async {
    await _billsStorage.ready;
    return _billsStorage;
  }

  static Future<LocalStorage> getIncomeStorage() async {
    await _incomeStorage.ready;
    return _incomeStorage;
  }

  static Future<LocalStorage> getSavingsStorage() async {
    await _savingsStorage.ready;
    return _savingsStorage;
  }
  
  static Future<LocalStorage> getGoalsStorage() async {
    await _goalsStorage.ready;
    return _goalsStorage;
  }
  
  // --- Expense Methods ---
  static Future<void> insertExpense(Map<String, dynamic> expense) async {
    final storage = await getExpensesStorage();
    List<dynamic> existingExpenses = storage.getItem('expenses') ?? [];
    existingExpenses.add(expense);
    await storage.setItem('expenses', existingExpenses);
  }

  static Future<void> updateExpense(String id, Map<String, dynamic> updatedExpense) async {
    final storage = await getExpensesStorage();
    List<dynamic> existingExpenses = storage.getItem('expenses') ?? [];
    final index = existingExpenses.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      existingExpenses[index] = updatedExpense;
      await storage.setItem('expenses', existingExpenses);
    }
  }

  static Future<List<Map<String, dynamic>>> fetchExpenses() async {
    final storage = await getExpensesStorage();
    List<dynamic> expenses = storage.getItem('expenses') ?? [];
    return expenses.map((e) => Map<String, dynamic>.from(e)).toList();
  }
  
  // FIX: This method now deletes by a String ID.
  static Future<void> deleteExpense(String id) async {
    final storage = await getExpensesStorage();
    List<dynamic> existingExpenses = storage.getItem('expenses') ?? [];
    existingExpenses.removeWhere((expense) => expense['id'] == id);
    await storage.setItem('expenses', existingExpenses);
  }

  // --- Income Methods ---
  static Future<void> insertIncome(Map<String, dynamic> income) async {
    final storage = await getIncomeStorage();
    List<dynamic> existingIncome = storage.getItem('income') ?? [];
    existingIncome.add(income);
    await storage.setItem('income', existingIncome);
  }

  static Future<void> deleteIncome(String id) async {
    final storage = await getIncomeStorage();
    List<dynamic> existingIncome = storage.getItem('income') ?? [];
    existingIncome.removeWhere((item) => item['id'] == id);
    await storage.setItem('income', existingIncome);
  }

  static Future<List<Map<String, dynamic>>> fetchIncome() async {
    final storage = await getIncomeStorage();
    List<dynamic> income = storage.getItem('income') ?? [];
    return income.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // --- Bill Methods ---
  static Future<void> insertBill(Map<String, dynamic> bill) async {
    final storage = await getBillsStorage();
    List<dynamic> existingBills = storage.getItem('bills') ?? [];
    existingBills.add(bill);
    await storage.setItem('bills', existingBills);
  }

  static Future<List<Map<String, dynamic>>> fetchBills() async {
    final storage = await getBillsStorage();
    List<dynamic> bills = storage.getItem('bills') ?? [];
    return bills.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> deleteBill(String id) async {
    final storage = await getBillsStorage();
    List<dynamic> existingBills = storage.getItem('bills') ?? [];
    existingBills.removeWhere((bill) => bill['id'] == id);
    await storage.setItem('bills', existingBills);
  }

  // --- Savings Methods ---
  static Future<void> insertSaving(Map<String, dynamic> saving) async {
    final storage = await getSavingsStorage();
    List<dynamic> existingSavings = storage.getItem('savings') ?? [];
    existingSavings.add(saving);
    await storage.setItem('savings', existingSavings);
  }

  static Future<void> updateSaving(String id, double newAmount) async {
    final storage = await getSavingsStorage();
    List<dynamic> existingSavings = storage.getItem('savings') ?? [];
    final index = existingSavings.indexWhere((s) => s['id'] == id);
    if (index != -1) {
      existingSavings[index]['amount'] = newAmount;
      await storage.setItem('savings', existingSavings);
    }
  }

  static Future<List<Map<String, dynamic>>> fetchSavings() async {
    final storage = await getSavingsStorage();
    List<dynamic> savings = storage.getItem('savings') ?? [];
    return savings.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> deleteSaving(String id) async {
    final storage = await getSavingsStorage();
    List<dynamic> existingSavings = storage.getItem('savings') ?? [];
    existingSavings.removeWhere((saving) => saving['id'] == id);
    await storage.setItem('savings', existingSavings);
  }
  
  // --- Goals Methods ---
  static Future<void> insertGoal(Map<String, dynamic> goal) async {
    final storage = await getGoalsStorage();
    List<dynamic> existingGoals = storage.getItem('goals') ?? [];
    existingGoals.add(goal);
    await storage.setItem('goals', existingGoals);
  }

  static Future<List<Map<String, dynamic>>> fetchGoals() async {
    final storage = await getGoalsStorage();
    List<dynamic> goals = storage.getItem('goals') ?? [];
    return goals.map((e) => Map<String, dynamic>.from(e)).toList();
  }
  
  static Future<void> updateGoal(String id, Map<String, dynamic> updatedGoal) async {
    final storage = await getGoalsStorage();
    List<dynamic> existingGoals = storage.getItem('goals') ?? [];
    final index = existingGoals.indexWhere((g) => g['id'] == id);
    if (index != -1) {
      existingGoals[index] = updatedGoal;
      await storage.setItem('goals', existingGoals);
    }
  }

  static Future<void> deleteGoal(String id) async {
    final storage = await getGoalsStorage();
    List<dynamic> existingGoals = storage.getItem('goals') ?? [];
    existingGoals.removeWhere((goal) => goal['id'] == id);
    await storage.setItem('goals', existingGoals);
  }
}
