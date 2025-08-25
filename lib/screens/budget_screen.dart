import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
import '../providers/expense_provider.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final LocalStorage budgetStorage = LocalStorage('budgets');
  Map<String, double> monthlyBudgets = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
  }

  Future<void> _fetchBudgets() async {
    await budgetStorage.ready;
    final budgets = budgetStorage.getItem('monthly_budgets');
    if (budgets != null) {
      setState(() {
        monthlyBudgets = (budgets as Map).cast<String, double>();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveBudgets() async {
    await budgetStorage.ready;
    await budgetStorage.setItem('monthly_budgets', monthlyBudgets);
  }

  void _setBudgetForCategory(String category) {
    final TextEditingController amountController = TextEditingController(
      text: monthlyBudgets[category]?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Set Budget for $category'),
            content: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              if (monthlyBudgets.containsKey(category))
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      monthlyBudgets.remove(category);
                    });
                    _saveBudgets();
                    Navigator.of(ctx).pop();
                  },
                  child: const Text(
                    'Remove Budget',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null && amount > 0) {
                    this.setState(() {
                      monthlyBudgets[category] = amount;
                    });
                    _saveBudgets();
                    Navigator.of(ctx).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a valid amount")),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = context.watch<ExpenseProvider>();
    final expenses = expenseProvider.expenses;
    final now = DateTime.now();
    final monthKey = DateFormat('yyyy-MM').format(now);

    final Map<String, double> monthlySpending = {};
    for (var expense in expenses) {
      final date = DateTime.parse(expense['date']);
      if (DateFormat('yyyy-MM').format(date) == monthKey) {
        final category = expense['category'] as String;
        final amount = (expense['amount'] as num).toDouble();
        monthlySpending.update(category, (value) => value + amount, ifAbsent: () => amount);
      }
    }

    final allCategories = ['Food', 'Transport', 'Utilities', 'Shopping', 'Others'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budget'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    'Budget for ${DateFormat('MMMM yyyy').format(now)}',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ...allCategories.map((category) {
                    final budget = monthlyBudgets[category] ?? 0.0;
                    final spent = monthlySpending[category] ?? 0.0;
                    final remaining = budget - spent;
                    final percentage = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
                    final progressColor = percentage > 1.0 ? Colors.red : Colors.green;

                    return Card(
                      color: theme.cardColor,
                      child: ListTile(
                        title: Text(
                          '$category Budget: ₹${budget.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Spent: ₹${spent.toStringAsFixed(2)}'),
                            if (budget > 0) ...[
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: percentage,
                                color: progressColor,
                                // ignore: deprecated_member_use
                                backgroundColor: theme.colorScheme.onSurface.withOpacity(0.25),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                remaining >= 0
                                    ? 'Remaining: ₹${remaining.toStringAsFixed(2)}'
                                    : 'Over Budget by: ₹${remaining.abs().toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: remaining >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _setBudgetForCategory(category),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
