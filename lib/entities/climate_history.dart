class ClimateHistory {
  double pressure;
  double temperature;
  double humidity;
  int co2;
  int mode;
  int fanSpeed;

  ClimateHistory(
      {required this.temperature,
      required this.humidity,
      required this.pressure,
      required this.co2,
      required this.mode,
      required this.fanSpeed});

  static List<ClimateHistory> fromJson(Map<String, dynamic> json) {
    List<ClimateHistory> history = [];
    // var list = List<int>.generate(100, (i) => i * 10 + 400);
    // list.asMap().forEach((index, value) {
    //   history.add(ClimateHistory(
    //       temperature: value.toDouble(),
    //       humidity: value.toDouble(),
    //       pressure: value.toDouble(),
    //       co2: value,
    //       mode: value,
    //       fanSpeed: value
    //   ));
    // });
    (json['climate']['temperature'] as List<dynamic>)
        .asMap()
        .forEach((index, value) {
      history.add(ClimateHistory(
          temperature: json['climate']['temperature'][index].toDouble(),
          humidity: json['climate']['humidity'][index].toDouble(),
          pressure: json['climate']['pressure'][index].toDouble(),
          co2: json['climate']['co2'][index],
          mode: json['ventilation']['mode'][index],
          fanSpeed: json['ventilation']['fanSpeed'][index]));
    });
    return history;
  }
}
