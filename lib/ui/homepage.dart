import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/model_user.dart';
import '../network/api/login_api.dart';
import '../network/api/user_api.dart';
import 'widget/_homepage_authentifier_content.dart';
import './utils/context.dart';
import 'widget/app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  LoginApi loginApi = LoginApi();
  UserApi userAPI = UserApi();

  final String _title = 'sites';
  final String _currentTenant = 'ctei';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

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
                onDeconnexion: (value) => setState(() {}))
            : const BaseAppBar(title: "login"));
  }

  Widget widgetBody(User me) {
    return me.isAuthorized()
        ? HomepageAuthentifiedContent(user: me)
        : widgetLoginForm(context);
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

  Widget widgetLoginForm(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            emailForm(),
            const SizedBox(
              height: 10,
            ),
            passwordForm(),
            const SizedBox(
              height: 10,
            ),
            submit(),
            const SizedBox(
              height: 80,
            )
          ],
        ),
      ),
    );
  }

  Widget submit() {
    return MaterialButton(
        onPressed: () async {
          String email = "";

          email = emailController.text.trim();
          email = email.replaceAll("\n", " ");
          email = email.replaceAll("\r", " ");

          String password = "";

          password = passwordController.text.trim();
          password = password.replaceAll("\n", " ");
          password = password.replaceAll("\r", " ");

          try {
            Response result =
                await loginApi.login(email: email, password: password);

            if (result.statusCode == 401) {
              if (!context.mounted) {
                return;
              }
              context.showErrorSnackBar("Echec d'authentification");
              return;
            }

            setState(() {});
          } catch (e) {
            if (!context.mounted) {
              return;
            }
            context.showErrorSnackBar("Echec d'authentification $e");
            return;
          }
        },
        color: Theme.of(context).colorScheme.inversePrimary,
        textColor: Colors.white,
        child: const Text("Submit"));
  }

  Widget emailForm() {
    return TextFormField(
        controller: emailController,
        decoration: const InputDecoration(hintText: "email"),
        validator: validateEmail);
  }

  Widget passwordForm() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: const InputDecoration(hintText: "Password"),
    );
  }

  String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }
}
