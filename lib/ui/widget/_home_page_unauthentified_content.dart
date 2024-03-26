import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
//import 'package:tccore_plugin/TCDebug.dart';

import '../../network/api/tc.dart';
import '../utils/context.dart';

import '../../network/api/login_api.dart';

class HomepageUnAuthentifiedContent extends StatefulWidget {
  const HomepageUnAuthentifiedContent(
      {super.key, required this.context, required this.onConnexion});

  final BuildContext context;
  final Function(int) onConnexion;

  @override
  State<HomepageUnAuthentifiedContent> createState() =>
      _HomepageUnAuthentifiedContentState();
}

class _HomepageUnAuthentifiedContentState
    extends State<HomepageUnAuthentifiedContent> {
  LoginApi loginApi = LoginApi();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool badAuth = false;

  late TC tc;

  @override
  void initState() {
    super.initState();

    tc = TC();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetLoginForm(context),
    );
    // This trailing comma makes auto-formatting nicer for build methods.
  }

  Widget widgetLoginForm(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: AutofillGroup(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(children: [
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
                ]))
          ]),
        ),
      ),
    );
  }

  Widget submit() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      MaterialButton(
          onPressed: () async {
            String email = "";

            email = emailController.text.trim();
            email = email.replaceAll("\n", " ");
            email = email.replaceAll("\r", " ");

            if (validateEmail(email) != null) {
              context.showErrorSnackBar("adresse email non valide");
              badAuth = false;
              setState(() {});
              return;
            }

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
                badAuth = true;
                context.showErrorSnackBar("Echec d'authentification");
                setState(() {});
                return;
              }
              badAuth = false;
              tc.sendEventLogin(email: email);
              widget.onConnexion(1);

              // setState(() {});
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
          child: const Text("Submit")),
      const SizedBox(height: 20),
      (badAuth)
          ? MaterialButton(
              onPressed: () async {
                String email = "";

                email = emailController.text.trim();
                email = email.replaceAll("\n", " ");
                email = email.replaceAll("\r", " ");

                if (validateEmail(email) != null) {
                  context.showErrorSnackBar("adresse email non valide");
                  badAuth = false;
                  setState(() {});
                  return;
                }

                try {
                  Response result = await loginApi.resetPassword(
                    email: email,
                  );

                  if (result.statusCode == 200) {
                    if (!context.mounted) {
                      return;
                    }

                    context.showCustomSnackBar(
                        text:
                            "Veuillez retrouver votre nouveau mot de passe dans votre boite mail",
                        icon: const Icon(Icons.check));
                    badAuth = false;
                    setState(() {});
                    return;
                  }
                  badAuth = false;
                  if (!context.mounted) {
                    return;
                  }
                  context.showErrorSnackBar(
                      "Echec de la reinitialisation du mot de passe");
                  setState(() {});
                  return;
                } catch (e) {
                  if (!context.mounted) {
                    return;
                  }
                  context.showErrorSnackBar(
                      "Echec de la reinitialisation du mot de passe $e");
                  return;
                }
              },
              color: Theme.of(context).colorScheme.inversePrimary,
              textColor: Colors.white,
              child: const Text("send me a new password"))
          : Container()
    ]);
  }

  Widget emailForm() {
    return TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        //textCapitalization: TextCapitalization.none,
        decoration: const InputDecoration(hintText: "email"),
        enableSuggestions: false,
        validator: validateEmail,
        autofillHints: const [AutofillHints.email],
        onChanged: (value) {
          value = value.replaceAll(" ", "");
          value = removeDiacritics(value);
          emailController.value = TextEditingValue(
              text: value.toLowerCase(), selection: emailController.selection);
        });
  }

  Widget passwordForm() {
    return TextFormField(
      controller: passwordController,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: const [AutofillHints.password],
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
