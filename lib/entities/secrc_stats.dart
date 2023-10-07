import 'package:secrc_controller/entities/ventilation_stats.dart';

import 'climate_stats.dart';

class SecRCStats {
  ClimateStats climate;
  VentilationStats ventilation;

  SecRCStats({required this.climate, required this.ventilation});

  factory SecRCStats.fromJson(Map<String, dynamic> json) {
    return SecRCStats(
        climate: ClimateStats.fromJson(json['climate']),
        ventilation: VentilationStats.fromJson(json['ventilation']));
  }
}
