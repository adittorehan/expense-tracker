import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db.dart';

class ExpenseList extends StatelessWidget {
  final String month;
  final List<Expense> expenses;

  const ExpenseList({super.key, required this.expenses, required this.month});

  @override
  Widget build(BuildContext context) {
    const headerTextStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
    const dataTextStyle = TextStyle(fontSize: 16);

    return Scaffold(
      appBar: AppBar(
        title: Text(month),
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
                    // Assuming you still want to display total expense here
                    Expanded(
                      child: Text(
                        '${_calculateTotalExpense(expenses)} TK',
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
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Container(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to calculate total expense
  int _calculateTotalExpense(List<Expense> expenses) {
    int total = 0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    return total;
  }
}
