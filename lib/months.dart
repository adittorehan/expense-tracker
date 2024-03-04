import 'package:flutter/material.dart';
import 'db.dart';
import 'package:intl/intl.dart';

class MonthList extends StatelessWidget {
  const MonthList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Months'),
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
                Navigator.of(context)
                  ..pop()
                  ..pop()
                  ..pop();
              },
            ),
            ListTile(
              title: const Text('Months'),
              onTap: () {
                print('Clicked on expense months');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: DatabaseHelper.instance.getTotalExpenseByMonth(),
        builder:
            (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final Map<String, int>? totalExpensesByMonth = snapshot.data;
            if (totalExpensesByMonth == null || totalExpensesByMonth.isEmpty) {
              return const Center(
                child: Text('No data available.'),
              );
            }
            const textStyle = TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            );
            return ListView.builder(
              itemCount: totalExpensesByMonth.length,
              itemBuilder: (BuildContext context, int index) {
                final String month = totalExpensesByMonth.keys.elementAt(index);
                final int totalExpense = totalExpensesByMonth[month]!;
                final DateTime monthDate = DateFormat('yyyy-MM').parse(month);
                final String formattedMonth =
                    DateFormat('MMMM, yyyy').format(monthDate);
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      // Add functionality here for what happens when you tap on a month
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedMonth,
                            style: textStyle,
                          ),
                          Text(
                            'Total: $totalExpense TK',
                            style: textStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
