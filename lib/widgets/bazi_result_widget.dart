import 'package:flutter/material.dart';

class BaziResultWidget extends StatelessWidget {
  final String baziResult;

  const BaziResultWidget(this.baziResult, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Bazi:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Text(baziResult, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
