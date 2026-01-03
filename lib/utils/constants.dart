class ApiConstants {
  // opentripmap for places data
  static const String openTripMapBaseUrl =
      'https://api.opentripmap.io/0.1/en/places';
  static const String openTripMapApiKey =
      '5ae2e3f221c38a28845f05b6a3fd2c1f2e9a42d2ae9968aee75db33e';

  // openweathermap for weather info
  static const String openWeatherMapBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String openWeatherMapApiKey =
      '252efd73bd4ad6647fedeec0423b2333';

  // unsplash for destination images
  static const String unsplashBaseUrl = 'https://api.unsplash.com';
  static const String unsplashAccessKey =
      '0WHYV7o3d0ZBPcn3GP07hao6ny2i8ChWpIMJs7OKaHg';
}

class AppConstants {
  static const String appName = 'Smart Travel Planner';
  static const String sharedPrefsUserKey = 'user_data';
  static const String sharedPrefsAuthKey = 'is_authenticated';
  static const String dbName = 'travel_planner.db';
  static const int dbVersion = 1;
}
