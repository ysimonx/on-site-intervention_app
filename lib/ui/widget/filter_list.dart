import 'package:flex_list/flex_list.dart';
import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/models/model_user.dart';
import 'package:on_site_intervention_app/network/api/user_api.dart';

class FilterList {
  final User user;
  String? status = "";
  late List<User> usersCoordinators;
  User user_coordinator;
  late List<dynamic> listStatus;

  int indiceCoordinator = 0;

  late String searchText;

  FilterList(
      {this.status,
      required this.user_coordinator,
      required this.user,
      required Site site}) {
    listStatus = UserApi.getListStatusFromTemplate(
        user: user, site: site, type_intervention_name: "scaffolding request");

    searchText = "";
    usersCoordinators = UserApi.getCoordinatorsList(user: user, site: site);
    if (usersCoordinators.contains(User.nobody())) {
    } else {
      usersCoordinators.insert(0, User.nobody());
    }

    if (listStatus.contains("-")) {
    } else {
      listStatus.insert(0, "-");
    }
  }
}

Widget widgetFilterList(FilterList filterList,
    {required Null Function(FilterList value) onChangedFilterList,
    required User user,
    required Site site}) {
  TextEditingController textSearchController = TextEditingController();

  textSearchController.text = filterList.searchText;

  List<dynamic> listStatus = UserApi.getListStatusFromTemplate(
      user: user, site: site, type_intervention_name: "scaffolding request");

  if (listStatus.contains("-")) {
  } else {
    listStatus.insert(0, "-");
  }

  List<User> usersCoordinators =
      UserApi.getCoordinatorsList(user: user, site: site);
  if (usersCoordinators.contains(User.nobody)) {
  } else {
    usersCoordinators.insert(0, User.nobody());
  }

  List<DropdownMenuItem<String>> listStatusDropdownMenuItems = [];
  List<DropdownMenuItem<int>> listDropdownMenuItemsUsers = [];

  for (var i = 0; i < listStatus.length; i++) {
    listStatusDropdownMenuItems.add(
        DropdownMenuItem(value: listStatus[i], child: Text(listStatus[i])));
  }

  for (var i = 0; i < usersCoordinators.length; i++) {
    User u = usersCoordinators[i];
    listDropdownMenuItemsUsers
        .add(DropdownMenuItem(value: i, child: Text(u.email)));
  }
  return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Container(
            padding:
                const EdgeInsets.symmetric(vertical: 50.0, horizontal: 0.0),
            child: Row(children: [
              Expanded(
                  child: TextField(
                controller: textSearchController,
                onSubmitted: (value) {
                  filterList.searchText = value;
                  onChangedFilterList(filterList);
                  print(value.toString());
                },
                onChanged: (value) {
                  print(value.toString());
                },
              )),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    textSearchController.text = "";
                    filterList.searchText = "";
                    onChangedFilterList(filterList);
                  }),
              Icon(Icons.search)
            ])),
        FlexList(horizontalSpacing: 5, verticalSpacing: 10, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Status"),
            DropdownButton<String>(
                value: filterList.status,
                items: listStatusDropdownMenuItems,
                onChanged: (value) {
                  filterList.status = value;
                  onChangedFilterList(filterList);
                  print(value);
                })
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Coordinator"),
            DropdownButton<int>(
                value: filterList.indiceCoordinator,
                items: listDropdownMenuItemsUsers,
                onChanged: (value) {
                  if (value is int) {
                    filterList.user_coordinator =
                        filterList.usersCoordinators[value];
                    filterList.indiceCoordinator = value;
                    onChangedFilterList(filterList);
                    print(value.toString());
                  }
                })
          ])
        ]),
      ]));
}
