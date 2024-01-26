import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';
import 'package:on_site_intervention_app/models/model_organization.dart';

import '../models/model_field.dart';
import '../models/model_formulaire.dart';
import '../models/model_intervention.dart';
import '../models/model_section.dart';
import '../models/model_user.dart';
import '../network/api/intervention_api.dart';
import '../network/api/user_api.dart';
import 'utils/logger.dart';
import 'widget/scaffold.dart';
import 'widget/scaffold_supervisor.dart';
import 'widget/scaffold_user.dart';

// Create a Form widget.
class InterventionPage extends StatefulWidget {
  const InterventionPage(
      {super.key, required this.intervention, required this.organization});

  final Intervention intervention;
  final Organization organization;

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

  late List<User> usersSupervisors;
  late Map<String, Formulaire> mapFormulaires = {};

  UserApi userAPI = UserApi();

  int _initialIndex = 0;

  late Formulaire currentFormulaire;

  Map<String, String> fieldsValue = {};
  Map<String, TextEditingController> fieldsController = {};

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

  void test() {
    setState(() {});
  }

  Future<List<User>> getMyConfig({required int dummy}) async {
    usersSupervisors =
        await userAPI.getSupervisorsList(organization: widget.organization);

    mapFormulaires = await userAPI.getInterventionFormsFromTemplate(
        organization_name: widget.organization.name,
        type_intervention_name: widget.intervention.type_intervention_name);

    String s = (_initialIndex + 1).toString();
    currentFormulaire = mapFormulaires[s] as Formulaire;

    return usersSupervisors;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return FutureBuilder(
        future: getMyConfig(dummy: _initialIndex),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: Text(widget.intervention.intervention_name),
                ),
                body: widgetMainBody(context),
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    // if (_formKey.currentState!.validate()) {
                    await saveIntervention(context);
                    // }
                  },
                  tooltip: 'Save',
                  child: const Icon(Icons.save),
                ));
          }
          return const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget widgetMainBody(BuildContext context) {
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
    var scaffold = CardSettingsSectionScaffold();
    var scaffoldSupervisor = CardSettingsSectionSupervisor();
    var scaffoldUser = CardSettingsSectionScaffoldUser();

    return Wrap(children: [
      Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            widgetBodyFormLocation(),
            widgetBodyFormInterventionName(),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 2), child: Text(' ')),
            widgetBodyTabsFormulaires(intervention: widget.intervention),
            _initialIndex == 0
                ? widgetBodyFormulaire(
                    scaffoldSupervisor, scaffoldUser, scaffold)
                : widgetBodyFormulaireNG(_initialIndex)
          ])),
    ]);
  }

  CardSettings widgetBodyFormulaire(
      CardSettingsSectionSupervisor scaffoldSupervisor,
      CardSettingsSectionScaffoldUser scaffoldUser,
      CardSettingsSectionScaffold scaffold) {
    return CardSettings(
      labelWidth: 200.0,
      showMaterialonIOS: true, // default is false
      cardless: true, // default is fals
      children: <CardSettingsSection>[
        scaffoldSupervisor.render(key: _formKey, supervisors: usersSupervisors),
        scaffoldUser.render(key: _formKey),
        scaffold.render(key: _formKey),
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

  Widget widgetBodyTabsFormulaires({required Intervention intervention}) {
    List<Tab> tabs = [];
    mapFormulaires.forEach((k, f) => tabs.add(Tab(child: Text(f.form_name))));
    return DefaultTabController(
        initialIndex: _initialIndex,
        length: mapFormulaires.length,
        child: TabBar(
            isScrollable: false,
            onTap: (selectedTabIndex) async {
              await saveIntervention(context);
              setState(() {
                _initialIndex = selectedTabIndex;
                String s = (_initialIndex + 1).toString();
                currentFormulaire = mapFormulaires[s] as Formulaire;
              });
            },
            tabs: tabs));
  }

  Future<void> saveIntervention(BuildContext context) async {
    // sauvegarde du nom
    widget.intervention.intervention_name = controllerInterventionName.text;

    // sauvegarde des valeurs textes des formulaires
    widget.intervention.field_on_site_uuid_values = {};
    fieldsController.forEach((key, value) {
      widget.intervention.field_on_site_uuid_values[key] = value.text;
    });

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

  Widget widgetBodyFormulaireNG(int initialIndex) {
    Map<String, Section> sections = currentFormulaire.sections;
    List<CardSettingsSection> lCardSettingsSection = [];

    sections
        .forEach((k, s) => lCardSettingsSection.add(sectionCardSettings(s)));

    return CardSettings(
      labelWidth: 200.0,
      showMaterialonIOS: true, // default is false
      cardless: true, // default is fals
      children: lCardSettingsSection,
    );
  }

  CardSettingsSection sectionCardSettings(Section s) {
    List<CardSettingsWidget> lCardSettingsWidget = [];

    s.fields.forEach((key, f) {
      if (fieldsController.containsKey(f.field_on_site_uuid)) {
      } else {
        fieldsController[f.field_on_site_uuid] = TextEditingController();
      }

      if (widget.intervention.field_on_site_uuid_values
          .containsKey(f.field_on_site_uuid)) {
        fieldsController[f.field_on_site_uuid]!.text =
            widget.intervention.field_on_site_uuid_values[f.field_on_site_uuid];
      } else {
        fieldsController[f.field_on_site_uuid]!.text = "10";
      }
    });

    s.fields
        .forEach((key, f) => lCardSettingsWidget.add(fieldCardSettings(f, s)));

    return CardSettingsSection(
        header: CardSettingsHeader(
          label: s.section_name,
        ),
        children: lCardSettingsWidget);
  }

  CardSettingsWidget fieldCardSettings(Field f, Section s) {
    String _DefaultInitialValue = "10";

    late String _initialValue;

    if (f.field_on_site_uuid == '8dd3f411-6f67-43c4-9d9d-1d420cc6bc68') {
      print("gotchao");
    }
    if (fieldsValue.containsKey(f.field_on_site_uuid)) {
      _initialValue = fieldsValue[f.field_on_site_uuid] as String;
    } else {
      _initialValue = _DefaultInitialValue;
    }

    return CardSettingsInt(
      initialValue: int.parse(_initialValue),
      label: "${s.section_name}-${f.field_name}",
      controller: fieldsController[f.field_on_site_uuid],
      validator: (value) {
        // if (value == null) return 'is required.';
        String newvalue;
        if (value == null) {
          newvalue = "";
        } else {
          newvalue = value.toString();
        }

        fieldsValue[f.field_on_site_uuid] = newvalue;
      },
      onSaved: (value) {},
    );
  }
}
