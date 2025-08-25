import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/expense_provider.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _editingId;

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addOrUpdateIncome() {
    final source = _sourceController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (source.isNotEmpty && amount != null && amount > 0) {
      if (_editingId != null) {
        // If you add an updateIncome method in ExpenseProvider, call it here:
        // Provider.of<ExpenseProvider>(context, listen: false).updateIncome(_editingId!, {...});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Income updated successfully!")),
        );
      } else {
        const uuid = Uuid();
        final newIncome = {
          'id': uuid.v4(),
          'source': source,
          'amount': amount,
          'date': _selectedDate.toIso8601String(),
        };
        Provider.of<ExpenseProvider>(context, listen: false).addIncome(newIncome);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Income added successfully!")),
        );
      }
      _sourceController.clear();
      _amountController.clear();
      setState(() {
        _editingId = null;
        _selectedDate = DateTime.now();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly.")),
      );
    }
  }

  void _startEditing(Map<String, dynamic> income) {
    setState(() {
      _editingId = income['id'];
      _sourceController.text = income['source'];
      _amountController.text = (income['amount'] as num).toString();
      _selectedDate = DateTime.tryParse(income['date']) ?? DateTime.now();
    });
  }

  void _deleteIncome(String id) {
    Provider.of<ExpenseProvider>(context, listen: false).deleteIncome(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Income removed successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = context.watch<ExpenseProvider>();
    final incomeList = expenseProvider.income;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Tracker'),
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
                      controller: _sourceController,
                      decoration: const InputDecoration(
                        labelText: 'Source',
                        prefixIcon: Icon(Icons.work),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, color: Colors.blue),
                          onPressed: _pickDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addOrUpdateIncome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Text(_editingId != null ? 'Update Income' : 'Add Income'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: incomeList.isEmpty
                  ? Center(child: Text('No income entries yet.', style: theme.textTheme.titleMedium))
                  : ListView.builder(
                      itemCount: incomeList.length,
                      itemBuilder: (context, index) {
                        final item = incomeList[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.monetization_on, color: Colors.green),
                            title: Text(item['source'], style: theme.textTheme.titleMedium),
                            subtitle: Text(
                              "Date: ${DateTime.tryParse(item['date'])?.toLocal().toString().split(' ')[0] ?? ''}",
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₹${(item['amount'] as num).toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.green),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _startEditing(item);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _deleteIncome(item['id'] as String);
                                  },
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
