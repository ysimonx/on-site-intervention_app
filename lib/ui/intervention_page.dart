import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/ui/utils/mobilefirst.dart';
import 'package:path_provider/path_provider.dart';

import '../models/model_field.dart';
import '../models/model_formulaire.dart';
import '../models/model_intervention.dart';
import '../models/model_section.dart';
import '../models/model_user.dart';
import '../network/api/image.api.dart';
import '../network/api/intervention_api.dart';
import '../network/api/user_api.dart';
import 'utils/logger.dart';
import 'widget/card_settings_gallery.dart';
import 'widget/card_settings_signature.dart';
import 'widget/scaffold.dart';
import 'widget/scaffold_supervisor.dart';
import 'widget/scaffold_user.dart';

// Create a Form widget.
class InterventionPage extends StatefulWidget {
  const InterventionPage(
      {super.key,
      required this.intervention,
      required this.site,
      required this.user});

  final Intervention intervention;
  final Site site;
  final User user;

  @override
  InterventionPageState createState() {
    return InterventionPageState();
  }
}

// Create a corresponding State class.
class InterventionPageState extends State<InterventionPage> {
  // final _formKey = GlobalKey<FormState>();

  late List<GlobalKey<FormState>> _formsKey = [];
  late TextEditingController controllerInterventionName;

  bool _needSave = false;

  late List<User> usersCoordinators;
  late Map<String, Formulaire> mapFormulaires = {};
  late Map<String, dynamic> mapMandatoryLists = {};

  int _initialIndex = 0;

  late Formulaire currentFormulaire;

  //Map<String, String> fieldsValue = {};
  Map<String, TextEditingController> fieldsController = {};

  late Directory deviceApplicationDocumentsDirectory;

  // late Directory directory;

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

  Future<List<User>> getMyConfig() async {
    usersCoordinators =
        await UserApi.getCoordinatorsList(user: widget.user, site: widget.site);

    mapFormulaires = await UserApi.getInterventionFormsFromTemplate(
        user: widget.user,
        site_name: widget.site.name,
        type_intervention_name: widget.intervention.type_intervention_name);

    mapMandatoryLists = await UserApi.getMandatoryListFromTemplate(
        user: widget.user,
        type_intervention_name: widget.intervention.type_intervention_name);
    print(mapMandatoryLists.toString());

    // Chargement des données initiales de chaque "Field"
    // dans des TextEditingController
    _formsKey = [];
    mapFormulaires.forEach((key, formulaire) {
      _formsKey.add(GlobalKey<FormState>());
      formulaire.sections.forEach((key, section) {
        section.fields.forEach((key, f) {
          if (fieldsController.containsKey(f.field_on_site_uuid)) {
          } else {
            fieldsController[f.field_on_site_uuid] = TextEditingController();
          }
          if (widget.intervention.field_on_site_uuid_values
              .containsKey(f.field_on_site_uuid)) {
            fieldsController[f.field_on_site_uuid]!.text = widget
                .intervention.field_on_site_uuid_values[f.field_on_site_uuid];
          } else {
            if (f.field_type == "integer") {
              fieldsController[f.field_on_site_uuid]!.text = "10";
            }
            if (f.field_type == "date") {
              fieldsController[f.field_on_site_uuid]!.text = "";
            }
          }
        });
      });
    });

    String s = (_initialIndex + 1).toString();
    currentFormulaire = mapFormulaires[s] as Formulaire;

    deviceApplicationDocumentsDirectory =
        await getApplicationDocumentsDirectory();

    return usersCoordinators;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return FutureBuilder(
        future: getMyConfig(),
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
          saveIntervention(context);
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
          key: _formsKey[_initialIndex],
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: widgetBodyFormLocation()),
            widgetHeaderFormulaire(),
            widgetBodyFormInterventionName(),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 2), child: Text(' ')),
            widgetBodyTabsFormulaires(intervention: widget.intervention),
            widgetBodyFormulaireNG(_initialIndex),
            const SizedBox(
              height: 600,
            ),
          ])),
    ]);
  }

  CardSettings widgetHeaderFormulaire() {
    var scaffoldSupervisor = CardSettingsSectionHeader();
    return CardSettings(
      labelWidth: 200.0,
      showMaterialonIOS: true, // default is false
      cardless: true, // default is fals
      children: <CardSettingsSection>[
        scaffoldSupervisor.render(
            key: _formsKey[_initialIndex], coordinators: usersCoordinators),
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
    return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
            height: 100,
            width: double.infinity,
            child: Card(
              elevation: 10,
              child: ListTile(
                  leading: Icon(Icons.room),
                  subtitle: Text("batiment: B1, level: L2, room: R3"),
                  title: Text("Emplacement"),
                  trailing: Icon(Icons.travel_explore)),
            )));
  }

  Widget widgetBodyTabsFormulaires({required Intervention intervention}) {
    List<Tab> tabs = [];
    mapFormulaires.forEach((k, f) => tabs.add(Tab(child: Text(f.form_name))));
    return DefaultTabController(
        initialIndex: _initialIndex,
        length: mapFormulaires.length,
        child: TabBar(
            isScrollable: true,
            onTap: (selectedTabIndex) async {
              saveIntervention(context);
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
    // widget.intervention.field_on_site_uuid_values = {};
    fieldsController.forEach((key, value) {
      widget.intervention.field_on_site_uuid_values[key] = value.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Processing Data'), duration: Duration(seconds: 1)),
    );

    InterventionApi interventionApi = InterventionApi();

    if (isMobileFirst()) {
      await interventionApi.localUpdatedFileSave(
          intervention: widget.intervention);

      await interventionApi.syncLocalUpdatedFiles();
    } else {
      var r = await interventionApi
          .postInterventionValuesOnServer(widget.intervention);
      logger.d("saveIntervention, statusCode ${r?.statusCode}");
    }

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

    return Form(
        child: CardSettings(
      labelWidth: 200.0,
      showMaterialonIOS: true, // default is false
      cardless: true, // default is fals
      children: lCardSettingsSection,
    ));
  }

  CardSettingsSection sectionCardSettings(Section s) {
    List<CardSettingsWidget> lCardSettingsWidget = [];

    s.fields
        .forEach((key, f) => lCardSettingsWidget.add(fieldCardSettings(f, s)));

    return CardSettingsSection(
        header: CardSettingsHeader(
          label: s.section_name,
          /* child: Container(
                color: Colors.grey,
                child: Column(children: [
                  SizedBox(height: 100),
                  Row(children: [
                    Text(s.section_name, style: TextStyle(fontSize: 18))
                  ])
                ])),
                */
        ),
        children: lCardSettingsWidget);
  }

  CardSettingsWidget fieldCardSettings(Field f, Section s) {
    String defaultInitialValue = "10";
    late String initialValue;

    if (fieldsController.containsKey(f.field_on_site_uuid)) {
      initialValue = fieldsController[f.field_on_site_uuid]!.text;
    } else {
      initialValue = defaultInitialValue;
    }

    if (f.field_type == "integer") {
      return genCardSettingsInt(initialValue, s, f);
    }

    if (f.field_on_site_uuid == "e28cbc05-2f4b-46f5-acca-c147ae8a1db8") {
      print("you");
    }

    if (f.field_type == "list_from_mandatory_lists") {
      if (f.field_possible_values.isNotEmpty) {
        String sList = f.field_possible_values[0];
        Map<String, dynamic> mapJsonList = mapMandatoryLists[sList];
        if (mapJsonList["type"] == "fixed") {
          f.field_possible_values = mapJsonList["values"];
        }
        if (mapJsonList["type"] == "administrable_by_site") {
          f.field_possible_values = [];
          if (widget.site.dictOfLists.containsKey(sList)) {
            f.field_possible_values = widget.site.dictOfLists[sList];
          } else {
            f.field_possible_values = [];
          }
        }
        return genCardSettingsListPicker(initialValue, f);
      }
    }

    if (f.field_type == "list") {
      return genCardSettingsListPicker(initialValue, f);
    }

    if (f.field_type == "date") {
      return genCardSettingsDatePicker(initialValue, f);
    }

    if (f.field_type == "switch") {
      return genCardSettingsSwitch(initialValue, f);
    }

    if (f.field_type == "text") {
      return genCardSettingsText(initialValue, f);
    }

    if (f.field_type == "paragraph") {
      return genCardSettingsParagraph(initialValue, f);
    }

    if (f.field_type == "email") {
      return genCardSettingsEmail(initialValue, f);
    }

    if (f.field_type == "phone") {
      return genCardSettingsPhone(initialValue, f);
    }

    if (f.field_type == "user_from_role") {
      return genCardSettingsUserFromRole(initialValue, f);
    }

    if (f.field_type == "signature") {
      // return genCardSettingsInt(initialValue, s, f);
      return genCardSettingsSignature(initialValue, f);
    }

    if (f.field_type == "gallery") {
      /* List<String> listPictures = [
        "https://webapp.sandbox.fidwork.fr/api/request/images/picture_4398_visit_20230306165933.jpg",
        "https://webapp.sandbox.fidwork.fr/api/request/images/picture_4398_visit_20221204154542.jpg"
      ]; */
      List<dynamic> listPictures = [];
      try {
        listPictures = jsonDecode(initialValue);
      } catch (e) {
        logger.e(e.toString());
      }

      Directory directoryImageGallery = Directory(
          "${deviceApplicationDocumentsDirectory.path}/${ImageApi.getDownloadedImageRelativeDirectoryPath()}");

      return genCardSettingsGallery(jsonEncode(listPictures), f,
          directory: directoryImageGallery);
    }

    return genCardSettingsInt(initialValue, s, f);
  }

  CardSettingsListPicker<dynamic> genCardSettingsUserFromRole(
      String initialValue, Field f) {
    String roleName = f.field_possible_values[0];
    List<String> possibleValues = widget.site.getUsersForRoleName(roleName);

    return CardSettingsListPicker(
        initialItem: initialValue,
        label: f.field_label,
        items: possibleValues,
        // controller: fieldsController[f.field_on_site_uuid],
        validator: (value) {
          String newvalue;
          if (value == null) {
            newvalue = "";
          } else {
            newvalue = value;
          }
          fieldsController[f.field_on_site_uuid]!.text = newvalue;
        });
  }

  CardSettingsListPicker<dynamic> genCardSettingsListPicker(
      String initialValue, Field f) {
    return CardSettingsListPicker(
        initialItem: initialValue,
        label: f.field_label,
        items: f.field_possible_values,
        validator: (value) {
          String newvalue;
          if (value == null) {
            newvalue = "";
          } else {
            newvalue = value;
          }
          fieldsController[f.field_on_site_uuid]!.text = newvalue;
        });
  }

  CardSettingsInt genCardSettingsInt(String initialValue, Section s, Field f) {
    int initialIntValue = 0;

    try {
      initialIntValue = int.parse(initialValue);
    } catch (e) {
      initialIntValue = 0;
    }

    return CardSettingsInt(
      initialValue: initialIntValue,
      label: f.field_label,
      controller: fieldsController[f.field_on_site_uuid],
      validator: (value) {
        String newvalue;
        if (value == null) {
          newvalue = "";
        } else {
          newvalue = value.toString();
        }
        fieldsController[f.field_on_site_uuid]!.text = newvalue;
      },
      onSaved: (value) {},
    );
  }

  CardSettingsDatePicker genCardSettingsDatePicker(
      String initialValue, Field f) {
    DateTime initialDateTimeValue = DateTime.now();

    if (initialValue == "") {
      initialDateTimeValue = f.getDefaultDateTimeValue();
    } else {
      try {
        initialDateTimeValue = DateTime.parse(initialValue);
      } catch (e) {
        initialDateTimeValue = f.getDefaultDateTimeValue();
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        String newvalue = formatter.format(initialDateTimeValue);
        fieldsController[f.field_on_site_uuid]!.text = newvalue;
      }
    }

    return CardSettingsDatePicker(
      dateFormat: DateFormat('dd/MM/yyyy'),
      label: f.field_label,
      initialValue: initialDateTimeValue,
      validator: (value) {
        String newvalue;
        if (value == null) {
          newvalue = "";
        } else {
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          newvalue = formatter.format(value);
        }
        fieldsController[f.field_on_site_uuid]!.text = newvalue;
      },
      onSaved: (value) {},
    );
  }

  CardSettingsEmail genCardSettingsEmail(String initialValue, Field f) {
    return CardSettingsEmail(
        label: f.field_label,
        initialValue: initialValue,
        validator: (value) {
          logger.f(value);
          fieldsController[f.field_on_site_uuid]!.text = value as String;
        });
  }

  CardSettingsText genCardSettingsText(String initialValue, Field f) {
    return CardSettingsText(
        label: f.field_label,
        initialValue: initialValue,
        validator: (value) {
          logger.f(value);
          fieldsController[f.field_on_site_uuid]!.text = value as String;
        });
  }

  CardSettingsParagraph genCardSettingsParagraph(String initialValue, Field f) {
    return CardSettingsParagraph(
        label: f.field_label,
        initialValue: initialValue,
        validator: (value) {
          logger.f(value);
          fieldsController[f.field_on_site_uuid]!.text = value as String;
        });
  }

  CardSettingsPhone genCardSettingsPhone(String initialValue, Field f) {
    int initialIntValue;
    try {
      initialIntValue = int.parse(initialValue);
    } catch (e) {
      initialIntValue = 0;
    }

    return CardSettingsPhone(
        label: f.field_label,
        initialValue: initialIntValue,
        validator: (value) {
          logger.f(value);
          fieldsController[f.field_on_site_uuid]!.text = value as String;
        });
  }

  CardSettingsSwitch genCardSettingsSwitch(String initialValue, Field f) {
    bool init = false;
    if (initialValue == f.field_switch_on) {
      init = true;
    }

    if (initialValue == f.field_switch_off) {
      init = false;
    }

    return CardSettingsSwitch(
      label: f.field_label,
      trueLabel: f.field_switch_on,
      falseLabel: f.field_switch_off,
      initialValue: init,
      validator: (value) {
        String newvalue;
        if (value != null) {
          if (value) {
            newvalue = f.field_switch_on;
          } else {
            newvalue = f.field_switch_off;
          }
          fieldsController[f.field_on_site_uuid]!.text = newvalue;
        }
      },
      onSaved: (value) {},
    );
  }

  CardSettingsWidget genCardSettingsGallery(String initialValue, Field f,
      {required Directory directory}) {
    return CardSettingsGallery(
        directory: directory,
        field: f,
        label: f.field_label,
        initialValue: initialValue,
        validator: (stringJsonListPictures) {
          logger.f(stringJsonListPictures);
          fieldsController[f.field_on_site_uuid]!.text =
              stringJsonListPictures as String;
        });
  }

  CardSettingsWidget genCardSettingsSignature(String initialValue, Field f) {
    return CardSettingsSignature(
        field: f,
        label: f.field_label,
        initialValue: initialValue,
        validator: (value) {
          if (value != null) {
            fieldsController[f.field_on_site_uuid]!.text = value;
          }
        });
  }
}
