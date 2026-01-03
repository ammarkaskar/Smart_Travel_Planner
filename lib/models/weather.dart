class Weather {
  final String description;
  final String icon;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String city;

  Weather({
    required this.description,
    required this.icon,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.city,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final main = json['main'] ?? {};
    final weather = (json['weather'] as List?)?[0] ?? {};
    final wind = json['wind'] ?? {};

    return Weather(
      description: weather['description'] ?? 'N/A',
      icon: weather['icon'] ?? '01d',
      temperature: (main['temp'] ?? 0).toDouble() - 273.15, // Convert from Kelvin
      feelsLike: (main['feels_like'] ?? 0).toDouble() - 273.15,
      humidity: main['humidity'] ?? 0,
      windSpeed: (wind['speed'] ?? 0).toDouble(),
      city: json['name'] ?? 'Unknown',
    );
  }

  String get temperatureString => '${temperature.toStringAsFixed(1)}°C';
  String get feelsLikeString => '${feelsLike.toStringAsFixed(1)}°C';
}

