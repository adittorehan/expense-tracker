import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Expense Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _totalExpendedAmount = 0;
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    List<Expense> expenses = await DatabaseHelper.instance.getExpenses();
    int total = 0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    setState(() {
      _expenses = expenses;
      _totalExpendedAmount = total;
    });
  }

  void _showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add Expense',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ExpenseForm(
                  onExpenseAdded: () {
                    _fetchExpenses();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const headerTextStyle = TextStyle(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Expense: $_totalExpendedAmount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Table(
                border: TableBorder.all(),
                children: [
                  const TableRow(
                    children: [
                      TableCell(
                        child: Center(
                            child: Text('Title', style: headerTextStyle)),
                      ),
                      TableCell(
                        child: Center(
                            child: Text('Amount', style: headerTextStyle)),
                      ),
                      TableCell(
                        child:
                            Center(child: Text('Date', style: headerTextStyle)),
                      ),
                    ],
                  ),
                  for (Expense expense in _expenses)
                    TableRow(
                      children: [
                        TableCell(
                          child: Center(child: Text(expense.title)),
                        ),
                        TableCell(
                          child: Center(child: Text('${expense.amount}')),
                        ),
                        TableCell(
                          child: Center(
                              child: Text(DateFormat('EEEE, d MMM')
                                  .format(expense.date))),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showModal(context),
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExpenseForm extends StatefulWidget {
  final Function? onExpenseAdded;

  const ExpenseForm({super.key, this.onExpenseAdded});

  @override
  _ExpenseFormState createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                String title = _titleController.text;
                int amount = int.parse(_amountController.text);
                DateTime date = DateTime.now(); // Use DateTime.now() directly
                await _databaseHelper
                    .insertExpense(Expense(title, amount, date));
                _titleController.clear();
                _amountController.clear();
                widget.onExpenseAdded!();
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
