class Config {
  Config._();
  static const String roleAssignee = "coordinateur échafaudage";
}

class Endpoints {
  Endpoints._();

  // base url
  static const String baseUrl = "https://api.on-site-intervention.com";

  // receiveTimeout
  static const Duration receiveTimeout = Duration(seconds: 15000);

  // connectTimeout
  static const Duration connectionTimeout = Duration(seconds: 15000);

  static const String provisionDeviceKey = "l4yp81gmjcg57afvpq8p";
  static const String provisionDeviceSecret = "9wh3ym3qr2e5jlnbbvbo";

  static const String uploadImage = '/api/v1/photo';
  static const String readyuploadimage = '/api/v1/photo/ready';
  static const String downloadImage = '/static/photos/<image>';

  static const String login = '/api/v1/login';
  static const String refreshToken = "/api/v1/token/refresh";
  static const String listUsers = "/api/v1/user";

  static const String userMe = '/api/v1/user/me/config';
  static const String userList = '/api/v1/user';
  static const String resetPassword = '/api/v1/user/reset_password';

  static const String listInterventionsValues = '/api/v1/intervention_values';
  static const String postInterventionValues = '/api/v1/intervention_values';
  static const String listInterventionsValuesPhotos =
      '/api/v1/intervention_values/photos';

  static const String postSite = '/api/v1/site';
  static const String siteRead = '/api/v1/site/<id>';
  static const String addUserRoles = '/api/v1/site/<site_id>/user';
  static const String removeUserRoles = '/api/v1/site/<site_id>/user';
  static const String updateLists = '/api/v1/site/<site_id>/lists';
  static const String updateListsForPlaces =
      '/api/v1/site/<site_id>/lists_for_places';
  static const String updateCustomFields =
      '/api/v1/site/<site_id>/custom_fields';

  static const String exportInterventionsCSV =
      "/api/v1/intervention_values/csv?site_id=<site_id>&type_intervention_id=scaffolding%20request";
  static const String downloadFEB =
      "/backoffice/v1/intervention_values/feb/xlsx/<intervention_values_id>";
}
