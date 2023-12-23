import 'package:flutter/material.dart';

import '../models/model_organization.dart';

class OrganizationPage extends StatelessWidget {
  const OrganizationPage({super.key, required this.organization});

  final Organization organization;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(organization.name.toUpperCase()),
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
