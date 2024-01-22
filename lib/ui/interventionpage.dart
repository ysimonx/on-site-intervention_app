import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';

import '../models/model_formulaire.dart';
import '../models/model_intervention.dart';
import '../network/api/intervention_api.dart';
import 'utils/logger.dart';

// Create a Form widget.
class InterventionPage extends StatefulWidget {
  const InterventionPage({super.key, required this.intervention});

  final Intervention intervention;

  @override
  InterventionPageState createState() {
    return InterventionPageState();
  }
}

// Create a corresponding State class.
class InterventionPageState extends State<InterventionPage> {
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  late TextEditingController controllerInterventionName;

  late String title = "";
  late String url = "";
  late String email = "";
  late int phone;
  late DateTime date1stutil;
  late int duration_days;

  bool _needSave = false;

  void _onChangedText() {
    final text = controllerInterventionName.text;
    logger.d(" new size of : '$text' (${text.characters.length})");
    _needSave = true;
  }

  @override
  void initState() {
    super.initState();
    controllerInterventionName =
        TextEditingController(text: widget.intervention.intervention_name);
    // Start listening to changes.
    controllerInterventionName.addListener(_onChangedText);
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.intervention.intervention_name),
        ),
        body: widgetBody(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Validate returns true if the form is valid, or false otherwise.
            if (_formKey.currentState!.validate()) {
              await saveIntervention(context);
            }
          },
          tooltip: 'Save',
          child: const Icon(Icons.save),
        ));
  }

  Widget widgetBody(BuildContext context) {
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
        child: SingleChildScrollView(child: widgetBodyForm(context)));
  }

  Widget widgetBodyForm(BuildContext context) {
    return Wrap(children: [
      Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            widgetBodyFormLocation(),
            widgetBodyFormInterventionName(),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 16), child: Text(' ')),
            CardSettings(
              children: <CardSettingsSection>[
                cardSettingsSectionUser(),
                cardSettingsSectionScaffold(),
              ],
            )
          ])),
      widgetBodyFormFormulaires(intervention: widget.intervention)
    ]);
  }

  CardSettingsSection cardSettingsSectionScaffold() {
    return CardSettingsSection(
        header: CardSettingsHeader(
          label: 'Scaffold',
        ),
        children: <CardSettingsWidget>[
          CardSettingsDatePicker(
            labelWidth: 200.0, //
            dateFormat: DateFormat('dd/MM/yyyy'),
            label: '1st Util',
            initialValue: DateTime.now().add(const Duration(days: 15)),
            validator: (value) {
              if (value == null) return 'Date 1st Util is required.';
              return null;
            },
            onSaved: (value) => date1stutil = value!,
          ),
          CardSettingsInt(
            initialValue: 10,
            labelWidth: 200.0, //
            label: 'Duration (days)',
            validator: (value) {
              if (value == null) return 'Duration is required.';
              return null;
            },
            onSaved: (value) => duration_days = value!,
          ),
          CardSettingsListPicker(
              label: 'Action',
              labelWidth: 200.0, //
              items: const [
                "Montage échafaudage",
                "Modification échafaudage",
                "Montage échafaudage roulant",
                "Modification échafaudage roulant",
                "Montage protection collective",
                "Modification protection collective",
                "Autres structures",
                "Erecting Scaffolding for",
                "Modification Scaffolding for",
                "Erecting Mobile Scaffolding",
                "Modification Mobile scaffolding",
                "Erecting personal protection",
                "Modification personal protection",
                "Other Structure"
              ]),
          CardSettingsListPicker(
              label: 'Usage',
              labelWidth: 200.0, //
              items: const [
                "Acces sécurisé",
                "Travaux de peinture",
                "Travaux de métallurgie",
                "Travaux de montage tuyauterie",
                "Travaux d'isolation",
                "Travaux électrique",
                "Travaux de génie civil",
                "Travaux d'inspection",
                "Travaux d'instrumentation",
                "Access",
                "Blasting and Painting",
                "Busbar",
                "Cleaning",
                "Commissioning Test",
                "Installation Cables Tray or Cables ",
                "Insulation Pipe or Valve",
                "Lifting Point",
                "Mechanical Assembly",
                "Metrology",
                "Not concerned",
                "Opening back/in filling",
                "Passerelle",
                "Piping Installation",
                "Piping or Support",
                "Protection floor",
                "Safety",
                "Tarpaulin installation",
                "TSM Pipeline",
                "Valve Installation",
                "Visual Inspection",
                "Welding",
                "X-Ray"
              ]),
          CardSettingsListPicker(
              label: 'P mat',
              labelWidth: 200.0, //
              items: const ["< 100kg", "> 100kg", "not concerned"]),
          CardSettingsListPicker(
              label: '# workers on scaffold',
              labelWidth: 200.0,
              initialItem: "1",
              items: const [
                "0",
                "1",
                "2",
                "3",
                "4",
                "5",
                "6",
                "7",
                "8",
                "9",
                "10",
                "11",
                "12",
                "13",
                "14",
                "15",
                "16",
                "17",
                "18",
                "19",
                "20",
                "not concerned"
              ])
        ]);
  }

  CardSettingsSection cardSettingsSectionUser() {
    return CardSettingsSection(
      header: CardSettingsHeader(
        label: 'User',
      ),
      children: <CardSettingsWidget>[
        CardSettingsText(
          labelWidth: 200.0,
          label: 'Name',
          initialValue: "Roberto Mignonne",
          validator: (value) {
            if (value == null || value.isEmpty) return 'Name is required.';
            return null;
          },
          onSaved: (value) => title = value!,
        ),
        CardSettingsPhone(
          labelWidth: 200.0,
          label: 'Phone',
          initialValue: 0651556170,
          validator: (value) {
            if (value == null) return 'Phone is required.';
            return null;
          },
          onSaved: (value) => phone = value!,
        ),
        CardSettingsEmail(
          label: 'E-mail',
          labelWidth: 200.0,
          initialValue: "roberto@iter.org",
          validator: (value) {
            // if (!value!.startsWith('http:'))
            //  return 'Must be a valid website.';
            return null;
          },
          onSaved: (value) => email = value!,
        ),
      ],
    );
  }

  Padding widgetBodyFormInterventionName() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: TextFormField(
          controller: controllerInterventionName,
          // The validator receives the text that the user has entered.
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ));
  }

  Padding widgetBodyFormLocation() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
            height: 100,
            width: double.infinity,
            child: Card(
              elevation: 10,
              shadowColor: Colors.black,
              color: const Color.fromARGB(255, 247, 251, 248),
              child: ListTile(
                  leading: const Icon(Icons.room),
                  subtitle: Text(widget.intervention.place.name),
                  title: const Text("Emplacement"),
                  trailing: const Icon(Icons.travel_explore)),
            )));
  }

  Widget widgetBodyFormFormulaires({required Intervention intervention}) {
    return ListTileTheme(
        contentPadding: const EdgeInsets.all(2),
        iconColor: Colors.green,
        textColor: Colors.black54,
        tileColor: Colors.yellow[10],
        style: ListTileStyle.list,
        dense: true,
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: intervention.forms.length,
          shrinkWrap: true,
          padding: const EdgeInsets.all(2.0),
          itemBuilder: (_, index) {
            int indicemap = index + 1;
            Formulaire? f = intervention.forms[indicemap.toString()];
            logger.d(f?.form_name);

            return widgetBodyFormFormulairesItem(indicemap, f);
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              height: 10,
            );
          },
        ));
  }

  ListTile widgetBodyFormFormulairesItem(int indicemap, Formulaire? f) {
    return ListTile(
      shape: RoundedRectangleBorder(
        //<-- SEE HERE
        side: BorderSide(width: 1, color: Colors.green.shade100),
        borderRadius: BorderRadius.circular(5),
      ),
      leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 139, 250, 166),
          child: Text("$indicemap")), // Text("$indicemap"),
      title: Text("${f?.form_name}"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                logger.d("yes");
              },
              icon: const Icon(Icons.navigate_next)),
        ],
      ),
    );
  }

  Future<void> saveIntervention(BuildContext context) async {
    widget.intervention.intervention_name = controllerInterventionName.text;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing Data')),
    );

    InterventionApi interventionApi = InterventionApi();

    await interventionApi.localUpdatedFileSave(
        intervention: widget.intervention);

    await interventionApi.syncLocalUpdatedFiles();

    _needSave = false;
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
}
