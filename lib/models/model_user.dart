import 'model_organization.dart';

class User {
  String id;
  String firstname;
  String lastname;
  late List<Organization> organizations;

  User({required this.id, required this.firstname, required this.lastname});

  Map<String, dynamic> toJSON() {
    var resorg = [];
    for (var i = 0; i < organizations.length; i++) {
      resorg.add(organizations[i].toJSON());
    }

    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['organizations'] = resorg;
    return data;
  }

  static User fromJson(Map<String, dynamic> json) {
    User user = User(
        id: json['user']['id'] as String,
        firstname: json['user']['firstname'] as String,
        lastname: json['user']['lastname'] as String);

    var organizations = json['organizations'];

    List<Organization> res = [];
    for (var i = 0; i < organizations.length; i++) {
      Organization org = Organization.fromJson(organizations[i]);
      res.add(org);
      print(organizations[i]);
    }

    user.organizations = res;
    return user;
  }

  bool isAuthorized() {
    if (id != "") {
      return true;
    }
    return false;
  }

  List<Organization> organizationsFromJson(Map<String, dynamic> json) {
    List<Organization> res = [];
    return res;
  }
}
