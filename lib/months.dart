import 'package:flutter/material.dart';

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
                Navigator.of(context)..pop()..pop()..pop();
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
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context)..pop()..pop();
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
