import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/expense_provider.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _addOrEditGoal({Map<String, dynamic>? goalToEdit}) {
    final bool isEditing = goalToEdit != null;
    final String dialogTitle = isEditing ? 'Edit Goal' : 'Add New Goal';
    
    if (isEditing) {
      _nameController.text = goalToEdit['name'];
      _amountController.text = (goalToEdit['targetAmount'] as num).toString();
    } else {
      _nameController.clear();
      _amountController.clear();
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Goal Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Amount'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              final amount = double.tryParse(_amountController.text.trim());
              if (name.isNotEmpty && amount != null && amount > 0) {
                if (isEditing) {
                  final updatedGoal = {
                    'id': goalToEdit['id'],
                    'name': name,
                    'targetAmount': amount,
                  };
                  Provider.of<ExpenseProvider>(context, listen: false).updateGoal(goalToEdit['id'], updatedGoal);
                } else {
                  const uuid = Uuid();
                  final newGoal = {
                    'id': uuid.v4(),
                    'name': name,
                    'targetAmount': amount,
                  };
                  Provider.of<ExpenseProvider>(context, listen: false).addGoal(newGoal);
                }
                Navigator.of(ctx).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields correctly.")),
                );
              }
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }
  
  void _deleteGoal(String id) {
    Provider.of<ExpenseProvider>(context, listen: false).deleteGoal(id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = context.watch<ExpenseProvider>();
    final goalsList = expenseProvider.goals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Financial Goals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (goalsList.isEmpty)
              const Center(child: Text('No goals added yet.'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: goalsList.length,
                  itemBuilder: (context, index) {
                    final goal = goalsList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.flag, color: Colors.blueAccent),
                        title: Text(goal['name'], style: theme.textTheme.titleMedium),
                        subtitle: Text('Target: ₹${(goal['targetAmount'] as num).toStringAsFixed(2)}', style: theme.textTheme.bodyMedium),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _addOrEditGoal(goalToEdit: goal),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteGoal(goal['id'] as String),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditGoal(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
