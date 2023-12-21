class User {
  String id;
  String firstname;
  String lastname;

  User({required this.id, required this.firstname, required this.lastname});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    return data;
  }

  User.fromJson(Map<String, dynamic> json)
      : id = json['user']['id'] as String,
        firstname = json['user']['firstname'] as String,
        lastname = json['user']['lastname'] as String;

  bool isAuthorized() {
    if (id != "") {
      return true;
    }
    return false;
  }
}
