class VentilationStats {
  int mode;
  int fanSpeed;
  bool filterChangeRequired;

  VentilationStats(
      {required this.mode,
      required this.fanSpeed,
      required this.filterChangeRequired});

  factory VentilationStats.fromJson(Map<String, dynamic> json) {
    return VentilationStats(
        mode: json['mode'],
        fanSpeed: json['fanSpeed'],
        filterChangeRequired: json['filterChangeRequired']);
  }
}
