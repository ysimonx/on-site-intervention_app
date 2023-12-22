import 'package:flutter/material.dart';

import '../models/model_organization.dart';

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key, required this.organization});

  final Organization organization;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
