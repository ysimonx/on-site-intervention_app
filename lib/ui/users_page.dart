import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/models/model_tenant.dart';

import '../models/model_user.dart';
import '../network/api/user_api.dart';

class UsersPage extends StatefulWidget {
  final List<Tenant> tenants;
  final Site site;
  const UsersPage({super.key, required this.tenants, required this.site});

  @override
  State<StatefulWidget> createState() {
    return UsersPageState();
  }
}

// Create a corresponding State class.
class UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> entries = <String>['user A', 'user B', 'user C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  Future<List<User>> getUsersList() async {
    UserApi userApi = UserApi();
    List<User> res =
        await userApi.userList(tenants: widget.tenants, site: widget.site);
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Users"),
        ),
        body: FutureBuilder(
            future: getUsersList(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                List<User> listUsers = snapshot.data;
                return ListTileTheme(
                    contentPadding: const EdgeInsets.all(15),
                    iconColor: Colors.green,
                    textColor: Colors.black54,
                    tileColor: Colors.yellow[10],
                    style: ListTileStyle.list,
                    dense: true,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: listUsers.length,
                        itemBuilder: (_, index) => Card(
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                  title:
                                      Text('Entry ${listUsers[index].email}')),
                            )));
              }
              return Text("to");
            }));
  }
}
