import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracker/models/expense.dart';
import 'package:tracker/services/expenses_db.dart';
import 'package:tracker/services/prefs_service.dart';
import 'package:tracker/screens/expense_editor.dart';
import 'package:tracker/screens/settings_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ExpensesDb _db = ExpensesDb.instance;
  final PrefsService _prefs = PrefsService();

  List<Expense> _expenses = [];
  double _monthlyTotal = 0.0;
  String _currency = "ETB";
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final currency = await _prefs.getCurrency();
    final expenses = await _db.getAll();
    final total = await _db.getTotalByMonth(
      _currentMonth.year,
      _currentMonth.month,
    );

    setState(() {
      _currency = currency;
      _expenses = expenses;
      _monthlyTotal = total;
    });
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatAmount(double amount) {
    return "$_currency ${amount.toStringAsFixed(2)}";
  }

  Future<void> _deleteExpense(int id) async {
    await _db.delete(id);
    _loadData(); // Refresh
  }

  void _editExpense(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExpenseEditor(expense: expense)),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MyMoney"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Monthly Total Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                const Text("This Month", style: TextStyle(fontSize: 16)),
                Text(
                  _formatAmount(_monthlyTotal),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Expenses List
          Expanded(
            child: _expenses.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No expenses yet", style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return Dismissible(
                        key: Key(expense.id.toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _deleteExpense(expense.id!);
                        },
                        child: ListTile(
                          leading: const Icon(Icons.money_off),
                          title: Text(expense.category),
                          subtitle: Text(
                            expense.note.isEmpty
                                ? _formatDate(expense.date)
                                : "${expense.note} • ${_formatDate(expense.date)}",
                          ),
                          trailing: Text(
                            _formatAmount(expense.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () => _editExpense(expense),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpenseEditor()),
          ).then((_) => _loadData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
