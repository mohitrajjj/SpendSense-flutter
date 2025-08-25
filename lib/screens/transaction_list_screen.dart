import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../providers/expense_provider.dart';
import '../utils/export_utility.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _selectedCategory = 'All';
  String _sortOrder = 'Newest';

  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseProvider>(context, listen: false).fetchAllData();
  }

  // Filters and sorts the list of expenses based on user selections.
  List<Map<String, dynamic>> _getFilteredAndSortedExpenses(List<Map<String, dynamic>> expenses) {
    List<Map<String, dynamic>> filtered = expenses.where((expense) {
      if (_selectedCategory == 'All') {
        return true;
      }
      return expense['category'] == _selectedCategory;
    }).toList();

    // Sort the filtered list
    filtered.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      if (_sortOrder == 'Oldest') {
        return dateA.compareTo(dateB);
      } else {
        return dateB.compareTo(dateA);
      }
    });

    return filtered;
  }
  
  void _addOrEditExpense({Map<String, dynamic>? expenseToEdit}) {
    final bool isEditing = expenseToEdit != null;
    final String dialogTitle = isEditing ? 'Edit Expense' : 'Add New Expense';

    final TextEditingController amountController = TextEditingController(
      text: isEditing ? (expenseToEdit['amount'] as num).toString() : '',
    );
    final TextEditingController noteController = TextEditingController(
      text: isEditing ? expenseToEdit['note'] : '',
    );
    String category = isEditing ? expenseToEdit['category'] : 'Food';
    DateTime selectedDate = isEditing ? DateTime.parse(expenseToEdit['date']) : DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(dialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: 'Note'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: <String>['Food', 'Transport', 'Utilities', 'Shopping', 'Others']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            category = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: Text('Date: ${DateFormat.yMMMd().format(selectedDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      if (isEditing) {
                        final updatedExpense = {
                          'id': expenseToEdit['id'],
                          'amount': amount,
                          'category': category,
                          'note': noteController.text,
                          'date': selectedDate.toIso8601String(),
                        };
                        Provider.of<ExpenseProvider>(context, listen: false).updateExpense(expenseToEdit['id'], updatedExpense);
                      } else {
                        const uuid = Uuid();
                        final newExpense = {
                          'id': uuid.v4(),
                          'amount': amount,
                          'category': category,
                          'note': noteController.text,
                          'date': selectedDate.toIso8601String(),
                        };
                        Provider.of<ExpenseProvider>(context, listen: false).addExpense(newExpense);
                      }
                      Navigator.of(ctx).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a valid amount")),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeExpense(String id) {
    // FIX: The method now correctly expects and uses a String ID.
    Provider.of<ExpenseProvider>(context, listen: false).deleteExpense(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense removed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = context.watch<ExpenseProvider>();
    final expenses = expenseProvider.expenses;
    final displayedExpenses = _getFilteredAndSortedExpenses(expenses);
    final allCategories = ['All', 'Food', 'Transport', 'Utilities', 'Shopping', 'Others'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: () {
              if (displayedExpenses.isNotEmpty) {
                ExportUtility.exportToPdf(
                  fileName: 'SpendSense_Report',
                  data: displayedExpenses.map((expense) => {
                    'Amount': (expense['amount'] as num).toString(),
                    'Category': expense['category'],
                    'Note': expense['note'],
                    'Date': DateFormat.yMMMd().format(DateTime.parse(expense['date'])),
                  }).toList(),
                );
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No data to export.')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: _selectedCategory,
                      items: allCategories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                    DropdownButton<String>(
                      value: _sortOrder,
                      items: ['Newest', 'Oldest', 'Amount Asc', 'Amount Desc'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sortOrder = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: displayedExpenses.isEmpty
                  ? Center(
                      child: Text(
                        'No expenses found.',
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
                      ),
                    )
                  : ListView.builder(
                      itemCount: displayedExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = displayedExpenses[index];
                        final expenseId = expense['id'] as String;
                        return Dismissible(
                          key: Key(expenseId),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _removeExpense(expenseId);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: ExpenseCard(
                            expense: expense,
                            onEdit: () => _addOrEditExpense(expenseToEdit: expense),
                            onRemove: () => _removeExpense(expenseId),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditExpense(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExpenseCard extends StatelessWidget {
  final Map<String, dynamic> expense;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.parse(expense['date']);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.shopping_cart),
        title: Text(
          expense['category'],
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${expense['note']}\n${DateFormat.yMMMd().format(date)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹${(expense['amount'] as num).toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.red),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
