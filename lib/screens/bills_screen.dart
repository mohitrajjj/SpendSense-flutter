import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/expense_provider.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _addBill(String title, int amount, DateTime dueDate) {
    const uuid = Uuid();
    final newBill = {
      'id': uuid.v4(),
      'title': title,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
    };
    Provider.of<ExpenseProvider>(context, listen: false).addBill(newBill);
  }

  void _showAddBillDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? dueDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text('Add New Bill'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                      'Due Date: ${dueDate != null ? DateFormat.yMMMd().format(dueDate!) : 'Select Date'}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dueDate = pickedDate;
                      });
                    }
                  },
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
                  final title = titleController.text.trim();
                  final amount = int.tryParse(amountController.text.trim()) ?? 0;
                  if (title.isNotEmpty && amount > 0 && dueDate != null) {
                    _addBill(title, amount, dueDate!);
                    Navigator.of(ctx).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }

  List<Map<String, dynamic>> getBillsDueInDays(List<Map<String, dynamic>> bills, int daysOrLess) {
    final now = DateTime.now();
    return bills.where((bill) {
      try {
        final due = DateTime.parse(bill['dueDate']);
        final diff = due.difference(now).inDays;
        return diff >= 0 && diff <= daysOrLess;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> getUpcomingBillsAfterDays(List<Map<String, dynamic>> bills, int days) {
    final now = DateTime.now();
    return bills.where((bill) {
      try {
        final due = DateTime.parse(bill['dueDate']);
        final diff = due.difference(now).inDays;
        return diff > days;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseProvider = context.watch<ExpenseProvider>();
    final allBills = expenseProvider.bills;
    final dueSoonBills = getBillsDueInDays(allBills, 3);
    final upcomingBills = getUpcomingBillsAfterDays(allBills, 3);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Due Soon'),
            Tab(text: 'Upcoming'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBillList(dueSoonBills, expenseProvider),
          _buildBillList(upcomingBills, expenseProvider),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBillDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBillList(List<Map<String, dynamic>> billList, ExpenseProvider provider) {
    if (billList.isEmpty) {
      return const Center(child: Text('No bills available.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: billList.length,
      itemBuilder: (context, index) {
        final bill = billList[index];
        final uniqueKey = Key(bill['id'] as String);
        return Dismissible(
          key: uniqueKey,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            provider.deleteBill(bill['id'] as String);
          },
          child: BillCard(
            title: bill['title'],
            dueDate: DateFormat.yMMMd().format(DateTime.parse(bill['dueDate'])),
            amount: '₹${bill['amount']}',
            onRemove: () => provider.deleteBill(bill['id'] as String), // New onRemove callback
          ),
        );
      },
    );
  }
}

class BillCard extends StatelessWidget {
  final String title;
  final String dueDate;
  final String amount;
  final VoidCallback onRemove;

  const BillCard({
    super.key,
    required this.title,
    required this.dueDate,
    required this.amount,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Due: $dueDate', style: theme.textTheme.bodyMedium),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amount,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
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