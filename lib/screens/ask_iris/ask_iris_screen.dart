import 'package:flutter/material.dart';

class AskIrisScreen extends StatelessWidget {
  const AskIrisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask Iris'),
      ),
      body: const Center(
        child: Text('Ask Iris'),
      ),
    );
  }
}
