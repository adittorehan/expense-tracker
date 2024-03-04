import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db.dart';
import 'months.dart';

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

  void _showModal(BuildContext context, {Expense? expense}) {
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
                  expense: expense,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteExpenseConfirmation(int? id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel deletion
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close confirmation dialog
                _deleteExpense(id!); // Proceed with deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpenseById(id);
    _fetchExpenses(); // Refresh expenses after deletion
  }

  @override
  Widget build(BuildContext context) {
    const headerTextStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
    const dataTextStyle = TextStyle(fontSize: 16);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Expense List'),
              onTap: () {
                print('Clicked on expense list');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Months'),
              onTap: () {
                print('Clicked on expense months');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MonthList()),
                );
              },
            ),
          ],
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
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total Expense:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '$_totalExpendedAmount TK',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: const Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Title',
                        style: headerTextStyle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Amount',
                        style: headerTextStyle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Date',
                        style: headerTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  final expense = _expenses[index];
                  return InkWell(
                    onTap: () {
                      _showModal(context, expense: expense);
                    },
                    onLongPress: () {
                      _deleteExpenseConfirmation(expense.id);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.0),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[400]!,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              expense.title,
                              style: dataTextStyle,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Text(
                              '${expense.amount}',
                              style: dataTextStyle,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Text(
                              DateFormat('EEEE, d MMM').format(expense.date),
                              style: dataTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showModal(context),
        tooltip: 'Add Expense',
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExpenseForm extends StatefulWidget {
  final Function? onExpenseAdded;
  final Expense? expense;

  const ExpenseForm({super.key, this.onExpenseAdded, this.expense});

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
    _titleController.text = widget.expense?.title ?? '';
    _amountController.text = widget.expense?.amount.toString() ?? '';

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
                DateTime date = widget.expense?.date ?? DateTime.now(); // Use existing or current date
                if (widget.expense != null) {
                  await _databaseHelper.updateExpense(Expense.row(widget.expense!.id, title, amount, date));
                } else {
                  await _databaseHelper.insertExpense(Expense(title, amount, date));
                }
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
