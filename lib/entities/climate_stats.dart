class ClimateStats {
  double pressure;
  double temperature;
  double humidity;
  int co2;

  ClimateStats(
      {required this.temperature,
      required this.humidity,
      required this.pressure,
      required this.co2});

  factory ClimateStats.fromJson(Map<String, dynamic> json) {
    return ClimateStats(
        temperature: json['temperature'].toDouble(),
        humidity: json['humidity'].toDouble(),
        pressure: json['pressure'].toDouble(),
        co2: json['co2']);
  }
}
