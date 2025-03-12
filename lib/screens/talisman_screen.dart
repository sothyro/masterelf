import 'package:flutter/material.dart';

class TalismanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make the background transparent
      body: Center(
        child: Text(
          'យ័ន្ត Screen',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Dangrek',
          ),
        ),
      ),
    );
  }
}