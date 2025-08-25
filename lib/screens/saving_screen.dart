import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/expense_provider.dart';

class SavingScreen extends StatefulWidget {
  const SavingScreen({super.key});

  @override
  State<SavingScreen> createState() => _SavingScreenState();
}

class _SavingScreenState extends State<SavingScreen> {
  final TextEditingController _amountController = TextEditingController();

  void _addSaving() {
    final amount = double.tryParse(_amountController.text);

    if (amount != null && amount > 0) {
      const uuid = Uuid();
      final newSaving = {
        'id': uuid.v4(),
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
      };
      Provider.of<ExpenseProvider>(context, listen: false).addSaving(newSaving);
      _amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saving added successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
    }
  }

  void _editSaving(String id, double currentAmount) {
    final TextEditingController editController = TextEditingController(text: currentAmount.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Saved Amount'),
          content: TextField(
            controller: editController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'New Amount'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAmount = double.tryParse(editController.text);
                if (newAmount != null && newAmount > 0) {
                  Provider.of<ExpenseProvider>(context, listen: false).updateSaving(id, newAmount);
                  Navigator.of(ctx).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount.')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSaving(String id) {
    Provider.of<ExpenseProvider>(context, listen: false).deleteSaving(id);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = context.watch<ExpenseProvider>();
    final savingsList = expenseProvider.savings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount to Save',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addSaving,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Add Saving'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: savingsList.isEmpty
                  ? Center(child: Text('No savings entries yet.', style: theme.textTheme.titleMedium))
                  : ListView.builder(
                      itemCount: savingsList.length,
                      itemBuilder: (context, index) {
                        final item = savingsList[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.savings, color: Colors.blueAccent),
                            title: Text('Saved Amount', style: theme.textTheme.titleMedium),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₹${(item['amount'] as num).toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.blueAccent),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editSaving(item['id'] as String, (item['amount'] as num).toDouble()),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteSaving(item['id'] as String),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}