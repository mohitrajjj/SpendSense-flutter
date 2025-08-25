import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/auth_helper.dart';
import '../providers/expense_provider.dart';
import 'analytics_screen.dart';
import 'bills_screen.dart';
import 'income_screen.dart';
import 'goals_screen.dart';
import 'settings_screen.dart';
import 'transaction_list_screen.dart';
import 'budget_screen.dart';
import 'saving_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseProvider>(context, listen: false).fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final expenseProvider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('SpendSense Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              AuthHelper.logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialSummaryCard(
                totalIncome: expenseProvider.totalIncome,
                totalExpenses: expenseProvider.totalExpenses,
                totalBalance: expenseProvider.totalBalance,
              ),
              const SizedBox(height: 24),
              
              SavingProgressCard(
                // FIX: This now uses totalSavings, not totalBalance
                currentSavings: expenseProvider.totalSavings,
                savingGoal: expenseProvider.savingGoal,
              ),
              const SizedBox(height: 24),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isTablet ? 3 : 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                children: [
                  DashboardCard(
                    icon: Icons.account_balance_wallet,
                    label: 'Transactions',
                    gradientColors: const [Colors.purple, Colors.deepPurpleAccent],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionListScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.attach_money,
                    label: 'Income',
                    gradientColors: const [Colors.green, Colors.lightGreenAccent],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IncomeScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.savings,
                    label: 'Savings',
                    gradientColors: const [Colors.blue, Colors.lightBlueAccent],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavingScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.bar_chart,
                    label: 'Analytics',
                    gradientColors: const [Color.fromARGB(255, 7, 85, 85), Color.fromARGB(255, 27, 43, 43)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnalyticsScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.calendar_today,
                    label: 'Bills',
                    gradientColors: const [Colors.indigo, Colors.blueAccent],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BillsScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.flag,
                    label: 'Set Goal',
                    gradientColors: const [Colors.teal, Colors.cyan],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GoalScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.pie_chart,
                    label: 'Set Budget',
                    gradientColors: const [Colors.deepOrange, Colors.orangeAccent],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BudgetScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FinancialSummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final double totalBalance;

  const FinancialSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalBalance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Current Balance',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '₹${totalBalance.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: totalBalance >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            _buildSummaryRow(
              context,
              'Total Income',
              '₹${totalIncome.toStringAsFixed(2)}',
              Colors.green,
            ),
            _buildSummaryRow(
              context,
              'Total Expenses',
              '₹${totalExpenses.toStringAsFixed(2)}',
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, String value, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.bodyLarge),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class SavingProgressCard extends StatelessWidget {
  final double currentSavings;
  final double savingGoal;

  const SavingProgressCard({
    super.key,
    required this.currentSavings,
    required this.savingGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savingProgress = savingGoal > 0 ? (currentSavings / savingGoal).clamp(0.0, 1.0) : 0.0;
    return Card(
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
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final List<Color> gradientColors;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.white.withAlpha(51),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withAlpha(102),
              blurRadius: 12,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: Colors.white),
              const SizedBox(height: 14),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}