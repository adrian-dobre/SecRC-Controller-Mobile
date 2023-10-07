import 'package:secrc_controller/repositories/secrc_repository.dart';

class Repos {
  static SecRCRepository? secRCRepository;

  static init(String controllerAddress, String controllerAccessKey) {
    secRCRepository = SecRCRepository(
        address: controllerAddress, accessKey: controllerAccessKey);
  }

  static reset() {
    secRCRepository = null;
  }
}
