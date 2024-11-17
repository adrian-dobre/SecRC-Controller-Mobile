import 'package:secrc_controller/application/helpers/utils.dart';

class ClimateHistory {
  int heatIndex;
  double temperature;
  double humidity;
  int co2;
  int mode;
  int fanSpeed;

  ClimateHistory(
      {required this.temperature,
      required this.humidity,
      required this.heatIndex,
      required this.co2,
      required this.mode,
      required this.fanSpeed});

  static List<ClimateHistory> fromJson(Map<String, dynamic> json) {
    List<ClimateHistory> history = [];
    (json['climate']['temperature'] as List<dynamic>)
        .asMap()
        .forEach((index, value) {
      history.add(ClimateHistory(
          temperature: json['climate']['temperature'][index].toDouble(),
          humidity: json['climate']['humidity'][index].toDouble(),
          heatIndex: getHeatIndex(json['climate']['temperature'][index].toDouble(), json['climate']['humidity'][index].toDouble()),
          co2: json['climate']['co2'][index],
          mode: json['ventilation']['mode'][index],
          fanSpeed: json['ventilation']['fanSpeed'][index]));
    });
    return history;
  }
}
