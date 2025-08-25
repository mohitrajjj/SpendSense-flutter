import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = context.watch<ExpenseProvider>();
    final expenses = expenseProvider.expenses;

    // Data for the Expense Breakdown Pie Chart
    final Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      final category = expense['category'] as String;
      final amount = (expense['amount'] as num).toDouble();
      categoryTotals.update(category, (value) => value + amount, ifAbsent: () => amount);
    }

    final List<PieChartSectionData> sections = categoryTotals.entries.map((entry) {
      final color = _getColorForCategory(entry.key);
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: entry.key,
        radius: 70,
        titleStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      );
    }).toList();

    // Data for the Saving Progress Card
    final double savingGoal = expenseProvider.savingGoal;
    // FIX: This now uses totalSavings, not totalBalance
    final double currentSavings = expenseProvider.totalSavings;
    final double savingProgress = savingGoal > 0 ? (currentSavings / savingGoal).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Saving Progress Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saving Progress',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current Savings: ₹${currentSavings.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        'Goal: ₹${savingGoal.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: savingProgress,
                        // ignore: deprecated_member_use
                        backgroundColor: theme.colorScheme.onSurface.withOpacity(0.25),
                        color: Colors.lightGreen,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        savingGoal > 0
                            ? (currentSavings >= savingGoal ? 'Goal Reached! 🎉' : '${(savingProgress * 100).toStringAsFixed(0)}% of goal reached')
                            : 'Set a goal to start tracking!',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Existing Expense Breakdown Section
              Text(
                'Expense Breakdown by Category',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              expenses.isEmpty
                  ? Center(
                      child: Text(
                        'No expenses to display analytics.',
                        style: theme.textTheme.titleMedium,
                      ),
                    )
                  : Center(
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sections: sections,
                            sectionsSpace: 4,
                            centerSpaceRadius: 45,
                            startDegreeOffset: -90,
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: categoryTotals.keys.map((category) {
                  return LegendItem(
                    color: _getColorForCategory(category),
                    label: '$category (₹${categoryTotals[category]!.toStringAsFixed(2)})',
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Food': return Colors.deepPurple;
      case 'Transport': return Colors.red;
      case 'Utilities': return Colors.blue;
      case 'Shopping': return Colors.teal;
      case 'Others': return Colors.orange;
      default: return Colors.grey;
    }
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({required this.color, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withAlpha(102), blurRadius: 4)
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}