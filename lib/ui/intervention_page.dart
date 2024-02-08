import 'dart:io';

import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:path_provider/path_provider.dart';

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
      {super.key, required this.intervention, required this.site});

  final Intervention intervention;
  final Site site;

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
  late int durationInDays;

  bool _needSave = false;

  late List<User> usersSupervisors;
  late Map<String, Formulaire> mapFormulaires = {};

  UserApi userAPI = UserApi();

  int _initialIndex = 0;

  late Formulaire currentFormulaire;

  Map<String, String> fieldsValue = {};
  Map<String, TextEditingController> fieldsController = {};

  late Directory directory;

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

  Future<List<User>> getMyConfig({required int dummy}) async {
    directory = await getApplicationDocumentsDirectory();

    usersSupervisors = await userAPI.getSupervisorsList(site: widget.site);

    mapFormulaires = await userAPI.getInterventionFormsFromTemplate(
        site_name: widget.site.name,
        type_intervention_name: widget.intervention.type_intervention_name);

    // Chargement des données initiales de chaque "Field"
    // dans des TextEditingController
    mapFormulaires.forEach((key, formulaire) {
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
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: widgetBodyFormLocation()),
            widgetBodyFormInterventionName(),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 2), child: Text(' ')),
            widgetBodyTabsFormulaires(intervention: widget.intervention),
            _initialIndex == 0
                ? widgetBodyFormulaire(
                    scaffoldSupervisor, scaffoldUser, scaffold)
                : widgetBodyFormulaireNG(_initialIndex),
            widgetSlider(),
            const SizedBox(
              height: 200,
            ),
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
            isScrollable: true,
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
    // widget.intervention.field_on_site_uuid_values = {};
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

    s.fields
        .forEach((key, f) => lCardSettingsWidget.add(fieldCardSettings(f, s)));

    return CardSettingsSection(
        header: CardSettingsHeader(
          label: s.section_name,
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

    if (f.field_type == "list") {
      return genCardSettingsListPicker(initialValue, f);
    }

    if (f.field_type == "date") {
      return genCardSettingsDatePicker(initialValue, f);
    }

    if (f.field_type == "switch") {
      return genCardSettingsSwitch(initialValue, f);
    }

    if (f.field_type == "user_from_role") {
      return genCardSettingsUserFromRole(initialValue, f);
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
          fieldsValue[f.field_on_site_uuid] = newvalue;
        });
  }

  CardSettingsListPicker<dynamic> genCardSettingsListPicker(
      String initialValue, Field f) {
    return CardSettingsListPicker(
        initialItem: initialValue,
        label: f.field_label,
        items: f.field_possible_values,
        // controller: fieldsController[f.field_on_site_uuid],
        validator: (value) {
          String newvalue;
          if (value == null) {
            newvalue = "";
          } else {
            newvalue = value;
          }
          fieldsController[f.field_on_site_uuid]!.text = newvalue;
          fieldsValue[f.field_on_site_uuid] = newvalue;
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
        fieldsValue[f.field_on_site_uuid] = newvalue;
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
        fieldsValue[f.field_on_site_uuid] = newvalue;
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
        fieldsValue[f.field_on_site_uuid] = newvalue;
      },
      onSaved: (value) {},
    );
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
          fieldsValue[f.field_on_site_uuid] = newvalue;
        }
      },
      onSaved: (value) {},
    );
  }

  Widget widgetSlider() {
    List<String> listPictures = [
      "https://webapp.sandbox.fidwork.fr/api/request/images/picture_4398_visit_20230306165933.jpg",
      "https://webapp.sandbox.fidwork.fr/api/request/images/picture_4398_visit_20221204154542.jpg"
    ];

    return CarouselSlider.builder(
        itemCount: listPictures.length,
        options: CarouselOptions(
            scrollDirection: Axis.horizontal,
            // height: 100,
            autoPlay: false,
            aspectRatio: 0.85,
            enlargeCenterPage: true,
            enableInfiniteScroll: false),
        itemBuilder: (ctx, photoIndex, realIdx) {
          return CarouselSliderItem(listPictures[photoIndex]);
        });
  }

  Widget CarouselSliderItem(itemPicture) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          child: Stack(
            children: <Widget>[
              GestureDetector(
                  child: itemPicture.startsWith("http")
                      ? CachedNetworkImage(
                          imageUrl: itemPicture,
                          fit: BoxFit.cover,
                          width: 1000.0,
                          height: 1000.0)
                      : Image.file(
                          File(Platform.isIOS
                              ? getImagePathiOS(directory, itemPicture)
                              : itemPicture),
                          alignment: Alignment.topCenter,
                          fit: BoxFit.fitWidth,
                          width: 1000.0,
                          height: 1000.0)),
              Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: GestureDetector(
                    onTap: () async {
                      //
                      setState(() {});
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.black,
                            ))),
                  )),
            ],
          )),
    );
  }

  String getImagePathiOS(Directory directory, String pathOrigin) {
    const String localSubDirectoryCameraPictures = 'camera/pictures';
    final String pathDirectory =
        "${directory.path}/$localSubDirectoryCameraPictures";

    var strParts = pathOrigin.split('pictures/');

    String path = "${pathDirectory}/${strParts[1]}";
    return path;
  }
}
