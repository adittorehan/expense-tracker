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
      body: FutureBuilder<List<String>>(
        future: DatabaseHelper.instance.getExpenseMonths(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final List<String>? months = snapshot.data;
            if (months == null || months.isEmpty) {
              return Center(
                child: Text('No data available.'),
              );
            }
            return ListView.builder(
              itemCount: months.length,
              itemBuilder: (BuildContext context, int index) {
                final DateTime monthDate =
                    DateFormat('yyyy-MM').parse(months[index]);
                final String formattedMonth =
                    DateFormat('MMMM, yyyy').format(monthDate);
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      // Add functionality here for what happens when you tap on a month
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          formattedMonth,
                          style: TextStyle(fontSize: 18),
                        ),
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
