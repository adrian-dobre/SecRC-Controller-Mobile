import 'dart:async';

import 'package:flutter/material.dart';
import 'package:secrc_controller/application/helpers/colors.dart';
import 'package:secrc_controller/application/helpers/sec-rc_icons.dart';
import 'package:secrc_controller/application/helpers/utils.dart';
import 'package:secrc_controller/application/widgets/context_button.dart';
import 'package:secrc_controller/application/widgets/controller_status.dart';
import 'package:secrc_controller/application/widgets/labeled_state_chart.dart';
import 'package:secrc_controller/application/widgets/mode_button.dart';
import 'package:secrc_controller/application/widgets/themed_container.dart';
import 'package:secrc_controller/application/widgets/themed_scaffold.dart';
import 'package:secrc_controller/entities/climate_history.dart';
import 'package:secrc_controller/entities/fan_speed.dart';
import 'package:secrc_controller/entities/humidity.dart';
import 'package:secrc_controller/entities/ventilation_mode.dart';
import 'package:secrc_controller/repositories/repos.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'configuration.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  VentilationMode? ventilationMode;
  FanSpeed? fanSpeed;
  Humidity? humidity;
  int? co2;
  double? temperature;
  double? relativeHumidity;
  double? pressure;
  bool sendingCommand = false;
  bool refreshingData = false;
  Timer? refreshTimer;
  String? controllerAddress;
  String? controllerAccessKey;
  bool preferencesLoaded = false;
  bool filterChangeRequired = false;
  List<ClimateHistory> history = [
    ClimateHistory(
        temperature: 0, humidity: 0, pressure: 0, co2: 0, mode: 0, fanSpeed: 0)
  ];

  @override
  void dispose() {
    super.dispose();
    cancelRefreshTimerIfNeeded();
    WidgetsBinding.instance.removeObserver(this);
  }

  void cancelRefreshTimerIfNeeded() {
    if (refreshTimer != null && refreshTimer!.isActive) {
      refreshTimer!.cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        refreshData();
        break;
      default:
        break;
    }
  }

  void refreshData() {
    cancelRefreshTimerIfNeeded();
    getSecRCStats().whenComplete(() => getSecRCHistory()).whenComplete(() {
      refreshTimer = Timer(const Duration(minutes: 1), () {
        refreshData();
      });
    });
  }

  Future<void> changeMode(VentilationMode mode) {
    return checkConfiguration().then((value) {
      var previousMode = ventilationMode;
      setState(() {
        ventilationMode = mode;
      });
      return sendCommand(
              () => Repos.secRCRepository!.changeVentilationMode(mode))
          .catchError((error) {
        setState(() {
          ventilationMode = previousMode;
        });
      });
    });
  }

  void changeFanSpeed(FanSpeed speed) {
    checkConfiguration().then((value) {
      var previousSpeed = fanSpeed;
      setState(() {
        fanSpeed = speed;
      });
      sendCommand(() => Repos.secRCRepository!.changeFanSpeed(speed))
          .catchError((error) {
        setState(() {
          fanSpeed = previousSpeed;
        });
      });
    });
  }

  void resetFilter() {
    checkConfiguration().then((value) {
      setState(() {
        filterChangeRequired = false;
      });
      sendCommand(() => Repos.secRCRepository!.filterReset());
    });
  }

  Future<void> checkConfiguration() {
    if (Repos.secRCRepository == null) {
      navigateToConfiguration(context);
      return Future.error("Invalid configuration");
    }
    return Future.value(null);
  }

  Future<dynamic> sendCommand(Future<dynamic> Function() runCommand) {
    setState(() {
      sendingCommand = true;
    });
    return runCommand().then((value) {}).catchError((error) {
      showError(context, "Error while sending command: ${error.message}");
      throw error;
    }).whenComplete(() {
      setState(() {
        sendingCommand = false;
      });
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    initController();
  }

  void initController() {
    loadPreferences()
        .then((value) => {
              if (controllerAddress == null || controllerAccessKey == null)
                {navigateToConfiguration(context)}
              else
                {Repos.init(controllerAddress!, controllerAccessKey!)}
            })
        .then((value) => refreshData());
  }

  Future<dynamic> getSecRCStats() {
    if (Repos.secRCRepository == null) {
      return Future.value(null);
    }
    setState(() {
      refreshingData = true;
    });
    int startTime = DateTime.now().millisecondsSinceEpoch;
    return Repos.secRCRepository!
        .getStats()
        .then((value) {
          setState(() {
            fanSpeed = FanSpeed.values[value.ventilation.fanSpeed - 1];
            ventilationMode =
                VentilationMode.values[value.ventilation.mode - 1];
            co2 = value.climate.co2;
            temperature = value.climate.temperature;
            relativeHumidity = value.climate.humidity;
            pressure = value.climate.pressure;
            filterChangeRequired = value.ventilation.filterChangeRequired;
          });
        })
        .catchError((error) {
          showError(context, "Error while getting data: ${error.message}");
        })
        .whenComplete(() => Future.delayed(Duration(
            milliseconds:
                1000 - (DateTime.now().millisecondsSinceEpoch - startTime))))
        .whenComplete(() {
          setState(() {
            refreshingData = false;
          });
        });
  }

  Future<dynamic> getSecRCHistory() {
    if (Repos.secRCRepository == null) {
      return Future.value(null);
    }
    setState(() {
      refreshingData = true;
    });
    return Repos.secRCRepository!.getHistory().then((value) {
      setState(() {
        history = value;
      });
    }).catchError((error) {
      showError(context, "Error while getting data: ${error.message}");
    }).whenComplete(() {
      setState(() {
        refreshingData = false;
      });
    });
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      controllerAddress = prefs.getString('controllerAddress');
      controllerAccessKey = prefs.getString('controllerAccessKey');
      preferencesLoaded = true;
    });
  }

  void clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('controllerAddress');
    prefs.remove('controllerAccessKey');
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('controllerAddress', controllerAddress!);
    prefs.setString('controllerAccessKey', controllerAccessKey!);
  }

  confirmReset(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget reset = TextButton(
      child: const Text("Reset"),
      onPressed: () {
        clearPreferences();
        cancelRefreshTimerIfNeeded();
        Repos.reset();
        setState(() {
          controllerAddress = null;
          controllerAccessKey = null;
          ventilationMode = null;
          fanSpeed = null;
          humidity = null;
          co2 = null;
          pressure = null;
          humidity = null;
          temperature = null;
        });
        Navigator.pop(context);
        navigateToConfiguration(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: themeColorGradientEnd,
      title: const Text("Reset Configuration"),
      content: const Text("Are you sure you want to reset the configuration?"),
      actions: [
        cancelButton,
        reset,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double chartPadding = 10;
    double chartWidth = MediaQuery.of(context).size.width - 2 * chartPadding;
    return ThemedScaffold(
        title: "SecRC",
        drawer: Drawer(
          child: ThemedContainer(
              child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                  height: 120,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: themeColorGradientEnd,
                    ),
                    child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Menu',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24))
                        ]),
                  )),
              ListTile(
                title: const Text('Configuration'),
                onTap: () {
                  Navigator.pop(context);
                  navigateToConfiguration(context);
                },
              ),
              ListTile(
                title: const Text('Reset Configuration'),
                onTap: () {
                  Navigator.pop(context);
                  confirmReset(context);
                },
              ),
            ],
          )),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: chartPadding),
                    child: Stack(children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              LabeledStateChart(
                                label: ChartLabel(
                                  "CO\u2082",
                                  co2?.toDouble(),
                                  "PPM",
                                  stripDecimals: true,
                                ),
                                history: history,
                                yValueMapper: (ClimateHistory climate, _) =>
                                    climate.co2,
                                y2ValueMapper: (ClimateHistory climate, _) =>
                                    climate.fanSpeed,
                                minimum: 400,
                                maximum: 2500,
                                colors: [
                                  Colors.green,
                                  Colors.lightGreen,
                                  Colors.yellow,
                                  Colors.orange,
                                  Colors.red
                                ],
                                values: [400, 750, 1100, 1500, 2000],
                                colorTransition: 100,
                                width: chartWidth,
                              ).stateChart,
                              LabeledStateChart(
                                label: ChartLabel(
                                  "TEMPERATURE",
                                  temperature,
                                  "O",
                                ),
                                history: history,
                                yValueMapper: (ClimateHistory climate, _) =>
                                    climate.temperature,
                                y2ValueMapper: (ClimateHistory climate, _) =>
                                    climate.mode,
                                minimum: 10,
                                maximum: 40,
                                colors: [
                                  Colors.blue,
                                  Colors.green,
                                  Colors.yellow,
                                  Colors.orange,
                                  Colors.red
                                ],
                                values: [10, 20, 26, 28, 30],
                                colorTransition: 1,
                                width: chartWidth,
                              ).stateChart,
                              LabeledStateChart(
                                label: ChartLabel(
                                  "HUMIDITY",
                                  relativeHumidity,
                                  "%",
                                ),
                                history: history,
                                yValueMapper: (ClimateHistory climate, _) =>
                                    climate.humidity,
                                y2ValueMapper: (ClimateHistory climate, _) =>
                                    climate.fanSpeed,
                                minimum: 10,
                                maximum: 90,
                                colors: [
                                  Colors.white,
                                  Colors.green,
                                  Colors.blue
                                ],
                                values: [10, 40, 70],
                                colorTransition: 5,
                                width: chartWidth,
                              ).stateChart,
                              LabeledStateChart(
                                label: ChartLabel(
                                    "PRESSURE", pressure?.toDouble(), "MBAR",
                                    stripDecimals: true),
                                history: history,
                                yValueMapper: (ClimateHistory climate, _) =>
                                    climate.pressure,
                                minimum: 990,
                                maximum: 1020,
                                colors: [
                                  Colors.white,
                                ],
                                values: [990],
                                width: chartWidth,
                              ).stateChart
                            ],
                          )
                        ],
                      ),
                      ActivityIndicator(
                          refreshingData: refreshingData,
                          sendingCommand: sendingCommand)
                    ])),
                Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromRGBO(14, 18, 36, 1)),
                        color: const Color.fromRGBO(14, 18, 36, 1),
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 30, left: 10, right: 10),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              getContextualControls(),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: getFirstRowControls(),
                                  )),
                            ]))),
              ],
            ),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }

  List<Widget> getFirstRowControls() {
    return [
      ModeButton(
        active: ventilationMode == VentilationMode.heatRecovery,
        onPressed: () {
          FanSpeed? previousFanSpeed = fanSpeed;
          changeMode(VentilationMode.heatRecovery)
              .whenComplete(() => Future.delayed(const Duration(seconds: 1)))
              .whenComplete(() => changeFanSpeed(previousFanSpeed!));
        },
        iconData: SecRC.hrv,
      ),
      ModeButton(
        active: ventilationMode == VentilationMode.bypass,
        onPressed: () {
          FanSpeed? previousFanSpeed = fanSpeed;
          changeMode(VentilationMode.bypass)
              .whenComplete(() => Future.delayed(const Duration(seconds: 1)))
              .whenComplete(() => changeFanSpeed(previousFanSpeed!));
        },
        iconData: SecRC.bypass,
      ),
      ModeButton(
        active: filterChangeRequired,
        showIndicator: filterChangeRequired,
        onPressed: () {
          resetFilter();
        },
        iconData: SecRC.filter,
      )
    ];
  }

  void onSaveConfiguration(
      {required String controllerAccessKey,
      required String controllerAddress}) {
    setState(() {
      this.controllerAddress = controllerAddress;
      this.controllerAccessKey = controllerAccessKey;
      savePreferences();
      initController();
    });
  }

  void navigateToConfiguration(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Configuration(
                controllerAddress: controllerAddress,
                controllerAccessKey: controllerAccessKey,
                onSave: onSaveConfiguration)));
  }

  Padding getContextualControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: getFanControls()),
    );
  }

  List<Widget> getFanControls() {
    return [
      ContextButton(
        active: fanSpeed == FanSpeed.one,
        onPressed: () {
          changeFanSpeed(FanSpeed.one);
        },
        child: const Icon(SecRC.fan, size: 24),
      ),
      ContextButton(
        active: fanSpeed == FanSpeed.two,
        onPressed: () {
          changeFanSpeed(FanSpeed.two);
        },
        child: const Icon(SecRC.fan, size: 32),
      ),
      ContextButton(
        active: fanSpeed == FanSpeed.three,
        onPressed: () {
          changeFanSpeed(FanSpeed.three);
        },
        child: const Icon(SecRC.fan, size: 46),
      ),
      ContextButton(
        active: fanSpeed == FanSpeed.four,
        onPressed: () {
          changeFanSpeed(FanSpeed.four);
        },
        child: const Icon(SecRC.fan, size: 60),
      ),
    ];
  }
}
