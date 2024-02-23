import 'package:flutter/material.dart';

class SmartWearablePage extends StatelessWidget {
  const SmartWearablePage({super.key});

  @override
  Widget build(BuildContext context) {
    var data = 'Smart Wearable Page';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Wearable Page'),
      ),
      body: Center(
        child: Text(
          data,
          style: const TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
