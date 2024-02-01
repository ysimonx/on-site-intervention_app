import 'dart:async';
import 'package:flutter/material.dart';
import '../models/model_user.dart';
import '../network/api/login_api.dart';
import '../network/api/user_api.dart';
import 'widget/_homepage_authentifier_content.dart';
import 'widget/_homepage_unauthentified_content.dart';
import 'widget/app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserApi userAPI = UserApi();
  LoginApi loginApi = LoginApi();

  final String _title = 'sites';
  final String _currentTenant = 'ctei';

  Future<User> getMyInformations() async {
    bool ok = await loginApi.hasAnAccessToken();
    if (ok) {
      User userMe = await userAPI.myConfig(tryRealTime: true);
      return userMe;
    }
    return User.nobody();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getMyInformations(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            User me = snapshot.data;
            return Scaffold(appBar: widgetAppBar(me), body: widgetBody(me));
          } else if (snapshot.hasError) {
            return widgetError();
          } else {
            return widgetWaiting();
          }
        });
  }

  PreferredSize widgetAppBar(User me) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: me.isAuthorized()
            ? AuthentifiedBaseAppBar(
                title: _title,
                tenant: _currentTenant,
                user: me,
                onCallback: (value) => setState(() {}))
            : const BaseAppBar(title: "login"));
  }

  Widget widgetBody(User me) {
    return me.isAuthorized()
        ? HomepageAuthentifiedContent(
            user: me, onRefresh: (value) => setState(() {}))
        : HomepageUnAuthentifiedContent(
            context: context, onConnexion: (value) => setState(() {}));
  }

  Scaffold widgetWaiting() {
    return const Scaffold(
        body: Center(
            child: SizedBox(
      width: 60,
      height: 60,
      child: CircularProgressIndicator(),
    )));
  }

  Scaffold widgetError() {
    return const Scaffold(body: Text("error"));
  }
}
