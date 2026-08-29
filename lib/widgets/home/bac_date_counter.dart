

import 'package:flutter/material.dart';

class BacDateCounter extends StatefulWidget {
  const BacDateCounter({super.key});

  @override
  State<BacDateCounter> createState() => _BacDateCounterState();
}

class _BacDateCounterState extends State<BacDateCounter> {
  late DateTime _selectedDate;
  late int _daysLeft;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _daysLeft = _calculateDaysLeft(_selectedDate);
  }

  int _calculateDaysLeft(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inDays;
  }

  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Days left: $_daysLeft'),
      ],
    );
  }
}