import 'package:flutter/material.dart';

import '../models/model_formulaire.dart';
import '../models/model_intervention.dart';
import '../network/api/intervention_api.dart';
import 'utils/logger.dart';

class InterventionPage extends StatefulWidget {
  const InterventionPage({super.key, required this.intervention});

  final Intervention intervention;
  @override
  State<InterventionPage> createState() => _InterventionState();
}

class _InterventionState extends State<InterventionPage> {
  @override
  initState() {
    super.initState();
    print("initState Called");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.intervention.intervention_name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InterventionValuesForm(intervention: widget.intervention),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// Create a Form widget.
class InterventionValuesForm extends StatefulWidget {
  const InterventionValuesForm({super.key, required this.intervention});

  final Intervention intervention;

  @override
  InterventionValuesFormState createState() {
    return InterventionValuesFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class InterventionValuesFormState extends State<InterventionValuesForm> {
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
    logger.d('Second text field: $text (${text.characters.length})');
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

// cf https://docs.flutter.dev/cookbook/lists/mixed-list

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
        child: Wrap(children: [
          Form(
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
                        await saveIntervention(context);
                      }
                    },
                    child: const Text('Sauvegarder'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: InterventionForms(intervention: widget.intervention))
        ]));
  }

  Future<void> saveIntervention(BuildContext context) async {
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

  Widget InterventionForms({required Intervention intervention}) {
    // return Text("tests");

    return ListTileTheme(
        contentPadding: const EdgeInsets.all(15),
        iconColor: Colors.green,
        textColor: Colors.black54,
        tileColor: Colors.yellow[10],
        style: ListTileStyle.list,
        dense: true,
        child: ListView.builder(
            itemCount: intervention.forms.length,
            shrinkWrap: true,
            itemBuilder: (_, index) {
              int indicemap = index + 1;
              Formulaire? f = intervention.forms[indicemap.toString()];
              print(f?.form_name);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("${f?.form_name}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            print("yes");
                          },
                          icon: const Icon(Icons.arrow_forward)),
                    ],
                  ),
                ),
              );
            }));
  }
}
