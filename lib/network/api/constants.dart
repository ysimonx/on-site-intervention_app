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

  static const String login = '/api/v1/login';
  static const String refreshToken = "/api/v1/token/refresh";
  static const String listUsers = "/api/v1/user";

  static const String uploadGeste = "/api/v1/geste";
  static const String downloadBackOfficeFeedBack =
      "/api/v1/controle/filter_by_gestes";

  static const String userMe = '/api/v1/user/me/config';
}
