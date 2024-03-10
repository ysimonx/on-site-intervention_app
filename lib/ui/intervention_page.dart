// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/ui/utils/mobilefirst.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flex_list/flex_list.dart';

import '../models/model_field.dart';
import '../models/model_formulaire.dart';
import '../models/model_intervention.dart';
import '../models/model_lists_for_places.dart';
import '../models/model_section.dart';
import '../models/model_user.dart';
import '../network/api/image.api.dart';
import '../network/api/intervention_api.dart';
import '../network/api/user_api.dart';
import 'utils/logger.dart';
import 'widget/card_settings_gallery.dart';
import 'widget/card_settings_signature.dart';
import 'widget/choose_place.dart';
import 'widget/widgetListInterventionSamePlace.dart';

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
  late List<GlobalKey<FormState>> _formsKey = [];

  bool _needSave = false;

  late Map<String, Formulaire> mapFormulaires = {};
  late Map<String, dynamic> mapMandatoryLists = {};

  String placename = "";
  int _initialIndex = 0;

  late Formulaire currentFormulaire;

  //Map<String, String> fieldsValue = {};
  Map<String, TextEditingController> fieldsController = {};
  List<String> listFieldsUUIDUpdated = [];

  late Directory deviceApplicationDocumentsDirectory;

  late String intervention_status;
  late User userCoordinator;
  late List<User> usersCoordinators;

  late Future<String> myFuture;

  // late Directory directory;

  @override
  void initState() {
    super.initState();

    intervention_status = widget.intervention.status;

    usersCoordinators =
        UserApi.getCoordinatorsList(user: widget.user, site: widget.site);
    usersCoordinators.insert(0, User.nobody());
    userCoordinator = usersCoordinators[0];
    print(widget.intervention.assignee_user_id);
    for (var i = 0; i < usersCoordinators.length; i++) {
      if (usersCoordinators[i].id == widget.intervention.assignee_user_id) {
        userCoordinator = usersCoordinators[i];
      }
    }

    myFuture = Future<String>.delayed(
      const Duration(milliseconds: 100),
      () => getMyConfig(),
    );
  }

  void refreshUI() {
    setState(() {
      myFuture = Future<String>.delayed(
        const Duration(milliseconds: 100),
        () => getMyVides(),
      );
    });
  }

  Future<String> getMyVides() async {
    return "";
  }

  // Future<List<User>> getMyConfig() async {
  Future<String> getMyConfig() async {
    mapFormulaires = await UserApi.getInterventionFormsFromTemplate(
        user: widget.user,
        site_name: widget.site.name,
        type_intervention_name: widget.intervention.type_intervention_name);

    mapMandatoryLists = await UserApi.getMandatoryListFromTemplate(
        user: widget.user,
        type_intervention_name: widget.intervention.type_intervention_name);

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

    String interventionName = widget.intervention.BuildNumRegistre();
    widget.intervention.intervention_name = interventionName;
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myFuture,
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
        onPopInvoked: (bool didPop) async {
          if (didPop) {
            return;
          }
          // await saveIntervention(context);

          if (_needSave) {
            _showBackDialog();
          } else {
            Navigator.pop(context, widget.intervention);
          }
        },
        child: SingleChildScrollView(child: widgetBodyForm(context)));
  }

  void onChangedPlace(place) {
    widget.intervention.place = place;
    String newName = widget.intervention.BuildNumRegistre();
    widget.intervention.intervention_name = newName;
    _needSave = true;
    refreshUI();
  }

  Widget widgetBodyForm(BuildContext context) {
    return Wrap(children: [
      Form(
          key: _formsKey[_initialIndex],
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(children: [
                  ChoosePlaceWidget(
                      site: widget.site,
                      onChanged: onChangedPlace,
                      place: widget.intervention.place),
                  widgetNumChrono(),
                  widgetHeaderFormulaire(),
                ])),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 2), child: Text(' ')),
            widgetBodyTabsFormulaires(),
            widgetBodyFormulaireNG(_initialIndex),
            const SizedBox(
              height: 600,
            ),
          ])),
    ]);
  }

  Widget widgetHeaderFormulaire() {
    List<dynamic> listStatus = UserApi.getListStatusFromTemplate(
        user: widget.user,
        site: widget.site,
        type_intervention_name: widget.intervention.type_intervention_name);

    List<DropdownMenuItem<String>> listStatusDropdownMenuItems = [];

    List<DropdownMenuItem<User>> listDropdownMenuItemsUsers = [];

    for (var i = 0; i < listStatus.length; i++) {
      listStatusDropdownMenuItems.add(
          DropdownMenuItem(value: listStatus[i], child: Text(listStatus[i])));
    }

    for (var i = 0; i < usersCoordinators.length; i++) {
      User u = usersCoordinators[i];
      listDropdownMenuItemsUsers
          .add(DropdownMenuItem(value: u, child: Text(u.email)));
    }
    if (listStatus.contains(intervention_status) == false) {
      intervention_status = listStatus[0];
    }

    return FlexList(horizontalSpacing: 5, verticalSpacing: 10, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Coordinateur"),
        DropdownButton<User>(
          value: userCoordinator,
          items: listDropdownMenuItemsUsers,
          onChanged: (value) {
            if (value is User) {
              setState(() {
                _needSave = true;
                widget.intervention.assignee_user_id = value.id;
                widget.intervention.assignee_user = value;
                userCoordinator = value;
              });
            }
          },
        )
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Status"),
          DropdownButton<String>(
              value: intervention_status,
              items: listStatusDropdownMenuItems,
              onChanged: dropdownCallback)
        ])
      ]),
    ]);
  }

  Widget widgetBodyTabsFormulaires() {
    List<Tab> tabs = [];
    mapFormulaires.forEach((k, f) => tabs.add(Tab(child: Text(f.form_name))));
    return DefaultTabController(
        initialIndex: _initialIndex,
        length: mapFormulaires.length,
        child: TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            onTap: (selectedTabIndex) async {
              //await saveIntervention(context);
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

    // TODO : ici, on n'a QUE la liste des champs qui ont été modifiés en local
    print(listFieldsUUIDUpdated.toString());

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

      // await interventionApi.uploadInterventions();
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
              child: const Text('Sauvegarder et quitter'),
              onPressed: () async {
                await saveIntervention(context);
                Navigator.pop(context);
                Navigator.pop(context, widget.intervention);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Quitter sans sauvegarder'),
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

    if (f.field_type == "list_from_mandatory_lists") {
      List<dynamic> possible_values = [];

      if (f.field_possible_values.isNotEmpty) {
        String sList = f.field_possible_values[0];
        Map<String, dynamic> mapJsonList = mapMandatoryLists[sList];
        if (mapJsonList["type"] == "fixed") {
          possible_values = mapJsonList["values"];
        }
        if (mapJsonList["type"] == "administrable_by_site") {
          if (widget.site.dictOfLists.containsKey(sList)) {
            possible_values = widget.site.dictOfLists[sList];
          }
        }
        return genCardSettingsListPicker(initialValue, f,
            possible_values: possible_values);
      }
    }

    if (f.field_type == "list") {
      return genCardSettingsListPicker(initialValue, f,
          possible_values: f.field_possible_values);
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
        if (initialValue != "") {
          listPictures = jsonDecode(initialValue);
        }
      } catch (e) {
        logger.e(e.toString());
      }

      Directory directoryImageGallery = Directory(
          "${deviceApplicationDocumentsDirectory.path}/${ImageApi.getDownloadedImageRelativeDirectoryPath()}");

      Directory directoryPendingUploadImageGallery = Directory(
          "${deviceApplicationDocumentsDirectory.path}/${ImageApi.getPendingUploadImageRelativeDirectoryPath()}");

      return genCardSettingsGallery(jsonEncode(listPictures), f,
          directory: directoryImageGallery,
          directoryPendingUpload: directoryPendingUploadImageGallery,
          intervention_values_on_site_uuid:
              widget.intervention.intervention_values_on_site_uuid);
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
          String newvalue = "";
          if (value is String) {
            newvalue = value;
          }
          fieldsController[f.field_on_site_uuid]!.text = newvalue;

          // keep track of real updates
          if (newvalue != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }

  CardSettingsListPicker<dynamic> genCardSettingsListPicker(
      String initialValue, Field f,
      {required List<dynamic> possible_values}) {
    return CardSettingsListPicker(
        initialItem: initialValue,
        label: f.field_label,
        items: possible_values,
        validator: (value) {
          String newvalue;
          if (value == null) {
            newvalue = "";
          } else {
            newvalue = value;
          }
          fieldsController[f.field_on_site_uuid]!.text = newvalue;

          // keep track of real updates
          if (newvalue != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }

  CardSettingsInt genCardSettingsInt(String initialValue, Section s, Field f) {
    int initialIntValue = 0;

    if (initialValue == "") {
      initialIntValue = 0;
    } else {
      try {
        initialIntValue = int.parse(initialValue);
      } catch (e) {
        initialIntValue = 0;
      }
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

        // keep track of real updates
        if (newvalue != initialValue) {
          if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
            listFieldsUUIDUpdated.add(f.field_on_site_uuid);
          }
          _needSave = true;
        }
        return null;
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
      firstDate: DateTime(2001, 1, 1, 0, 0),
      lastDate: DateTime(2030, 1, 1, 0, 0),
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

        // keep track of real updates
        if (newvalue != initialValue) {
          if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
            listFieldsUUIDUpdated.add(f.field_on_site_uuid);
          }
          _needSave = true;
        }
        return null;
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

          // keep track of real updates
          if (value != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }

  CardSettingsText genCardSettingsText(String initialValue, Field f) {
    return CardSettingsText(
        label: f.field_label,
        initialValue: initialValue,
        validator: (value) {
          logger.f(value);
          fieldsController[f.field_on_site_uuid]!.text = value as String;

          // keep track of real updates
          if (value != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }

  CardSettingsParagraph genCardSettingsParagraph(String initialValue, Field f) {
    return CardSettingsParagraph(
        label: f.field_label,
        initialValue: initialValue,
        validator: (value) {
          logger.f(value);
          fieldsController[f.field_on_site_uuid]!.text = value as String;

          // keep track of real updates
          if (value != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }
          return null;
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

          // keep track of real updates
          if (value as String != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
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

          // keep track of real updates
          if (newvalue != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }
        }
        return null;
      },
      onSaved: (value) {},
    );
  }

  CardSettingsWidget genCardSettingsGallery(String initialValue, Field f,
      {required Directory directory,
      required Directory directoryPendingUpload,
      required String intervention_values_on_site_uuid}) {
    return CardSettingsGallery(
        directory: directory,
        directoryPendingUpload: directoryPendingUpload,
        field: f,
        intervention_values_on_site_uuid: intervention_values_on_site_uuid,
        label: f.field_label,
        initialValue: initialValue,
        validator: (stringJsonListPictures) {
          logger.f(stringJsonListPictures);
          fieldsController[f.field_on_site_uuid]!.text =
              stringJsonListPictures as String;

          // keep track of real updates
          if (stringJsonListPictures != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
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

            // keep track of real updates
            if (value != initialValue) {
              if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
                listFieldsUUIDUpdated.add(f.field_on_site_uuid);
              }
              _needSave = true;
            }
          }
          return null;
        });
  }

  void dropdownCallback(String? value) {
    setState(() {
      if (value is String) {
        intervention_status = value;
        widget.intervention.status = intervention_status;
        _needSave = true;
      }
    });
  }

  Widget widgetNumChrono() {
    if (widget.intervention.num_chrono == null) {
      return Padding(
          padding: const EdgeInsets.all(40.0),
          child: FlexList(
              /* style: TextButton.styleFrom(
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),*/
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('reprendre un chrono existant'),
                  widgetListInterventionSamePlace(
                      site: widget.site,
                      place: widget.intervention.place,
                      onChanged: (
                          {required Intervention intervention,
                          required String next_indice}) {
                        print(intervention.toString());
                        print(next_indice);
                        widget.intervention.num_chrono =
                            intervention.num_chrono;
                        widget.intervention.indice = next_indice;
                        String newName = widget.intervention.BuildNumRegistre();
                        widget.intervention.intervention_name = newName;
                        _needSave = true;
                        refreshUI();
                      })
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  TextButton(
                      child: const Text('créer un numero de chrono'),
                      onPressed: () {
                        // Navigator.pop(context);
                        widget.intervention.num_chrono = "[NNNNN]";
                        _needSave = true;
                        refreshUI();
                      })
                ]),
              ]));
    } else {
      if (widget.intervention.num_chrono == "[NNNNN]") {
        return Text("numero de chrono en attente de génération...");
      }
      return Text('num_chrono ${widget.intervention.num_chrono}');
    }
  }
}
