import 'package:flutter/material.dart';

class ListsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ListsPageState();
  }
}

// Create a corresponding State class.
class ListsPageState extends State<ListsPage> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Lists"),
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 50,
                color: Colors.amber[colorCodes[index]],
                child: Center(child: Text('Entry ${entries[index]}')),
              );
            }));
  }
}