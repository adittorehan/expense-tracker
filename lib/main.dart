import 'package:flutter/material.dart';
import 'db.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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
    expenses.forEach((expense) {
      total += expense.amount;
    });
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
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Expense',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
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
                      style: TextStyle(
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
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
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
                          child: Center(child: Text(expense.date)),
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

  const ExpenseForm({Key? key, this.onExpenseAdded}) : super(key: key);

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
            decoration: InputDecoration(labelText: 'Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(labelText: 'Amount'),
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
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                String title = _titleController.text;
                int amount = int.parse(_amountController.text);
                String date = DateTime.now().toString();
                await _databaseHelper.insertExpense(Expense(title, amount, date));
                _titleController.clear();
                _amountController.clear();
                widget.onExpenseAdded!();
                Navigator.pop(context);
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

