import 'package:flutter/material.dart';

import '../models/model_intervention.dart';
import '../network/api/intervention_api.dart';

class InterventionPage extends StatefulWidget {
  const InterventionPage({super.key, required this.intervention});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Intervention intervention;
  @override
  State<InterventionPage> createState() => _InterventionState();
}

class _InterventionState extends State<InterventionPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.intervention.intervention_name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MyCustomForm(intervention: widget.intervention),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key, required this.intervention});

  final Intervention intervention;

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  late TextEditingController myController;

  bool _needSave = false;

  void _printLatestValue() {
    final text = myController.text;
    print('Second text field: $text (${text.characters.length})');
    _needSave = true;
  }

  @override
  void initState() {
    super.initState();
    myController =
        TextEditingController(text: widget.intervention.intervention_name);
    // Start listening to changes.
    myController.addListener(_printLatestValue);
  }

  void _showBackDialog() {
    showDialog<void>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Etes vous sûr ?'),
          content: const Text(
            'Souhaitez vous quitter ce formulaire sans avoir sauvegardé vos modifications ?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Quitter'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          if (_needSave) {
            _showBackDialog();
          } else {
            Navigator.pop(context);
          }
        },
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: myController,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      widget.intervention.intervention_name = myController.text;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );

                      InterventionApi interventionApi = InterventionApi();
                      /* widget.intervention.version =
                          widget.intervention.version + 1; */

                      await interventionApi.localUpdatedFileSave(
                          intervention: widget.intervention);

                      await interventionApi.syncLocalUpdatedFiles();

                      _needSave = false;
                    }
                  },
                  child: const Text('Sauvegarder'),
                ),
              ),
            ],
          ),
        ));
  }
}
