import 'dart:convert';

import 'package:secrc_controller/entities/climate_history.dart';
import 'package:secrc_controller/entities/fan_speed.dart';
import 'package:secrc_controller/entities/secrc_stats.dart';
import 'package:secrc_controller/entities/ventilation_mode.dart';

import 'base/base_repository.dart';

class SecRCRepository extends BaseRepository {
  SecRCRepository({required String address, required String accessKey})
      : super(address: address, accessKey: accessKey);

  Future<dynamic> changeVentilationMode(VentilationMode mode) {
    var url = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port,
        pathSegments: [uri.path, 'sec-rc', 'ventilation', 'mode']);

    return put(url, body: {"mode": mode.index + 1});
  }

  Future<dynamic> changeFanSpeed(FanSpeed fanSpeed) {
    var url = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port,
        pathSegments: [uri.path, 'sec-rc', 'ventilation', 'fan-speed']);

    return put(url, body: {"fanSpeed": fanSpeed.index + 1});
  }

  Future<dynamic> filterReset() {
    var url = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port,
        pathSegments: [uri.path, 'sec-rc', 'ventilation', 'filter-reset']);

    return post(url);
  }

  Future<SecRCStats> getStats() {
    var url = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port,
        pathSegments: [uri.path, 'sec-rc', 'stats']);

    return get(url).then((value) =>
        SecRCStats.fromJson(json.decode(String.fromCharCodes(value.data))));
  }

  Future<List<ClimateHistory>> getHistory() {
    var url = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port,
        pathSegments: [uri.path, 'sec-rc', 'history']);

    return get(url).then((value) =>
        ClimateHistory.fromJson(json.decode(String.fromCharCodes(value.data))));
  }
}
