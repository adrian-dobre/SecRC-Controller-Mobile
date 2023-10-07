import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../entities/climate_history.dart';

class StateChart extends Container {
  final List<Color> colors;
  final List<double> stops;
  static const double _border = 1;
  static const double _labelWidth = 80;
  static const double _leftPadding = 10;

  StateChart(
      {Key? key,
      required List<Widget> label,
      required List<ClimateHistory> history,
      required num? Function(ClimateHistory climate, int index) yValueMapper,
      required this.colors,
      required this.stops,
      required double width,
      num? Function(ClimateHistory climate, int index)? y2ValueMapper,
      double? minimum,
      double? maximum})
      : super(
            key: key,
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            padding: const EdgeInsets.fromLTRB(_leftPadding, 0, 0, 0),
            decoration: BoxDecoration(
                border: Border.all(
                    color: const Color.fromRGBO(16, 20, 40, _border)),
                color: const Color.fromRGBO(16, 20, 40, 1),
                borderRadius: BorderRadius.circular(5)),
            child: Row(children: [
              SizedBox(
                  width: _labelWidth,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: label)),
              SizedBox(
                  width: width - _labelWidth - _leftPadding - 2 * _border,
                  height: 80,
                  child: SfCartesianChart(
                      onTrackballPositionChanging: (TrackballArgs args) {
                        ChartSeries<dynamic, dynamic> series =
                            args.chartPointInfo.series as ChartSeries;
                        if (series.name == 'Secondary') {
                          args.chartPointInfo.header = '';
                          args.chartPointInfo.label = '';
                        }
                      },
                      trackballBehavior: TrackballBehavior(
                          // Enables the trackball
                          enable: true,
                          activationMode: ActivationMode.singleTap,
                          tooltipDisplayMode:
                              TrackballDisplayMode.floatAllPoints),
                      margin: const EdgeInsets.all(5),
                      plotAreaBorderWidth: 0,
                      // Initialize category axis
                      primaryXAxis: CategoryAxis(
                        name: 'Time',
                        isVisible: false,
                        majorGridLines: const MajorGridLines(width: 0),
                        axisLine: const AxisLine(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                          minimum: minimum, maximum: maximum, isVisible: false),
                      axes: <ChartAxis>[
                        NumericAxis(
                            name: 'Secondary',
                            minimum: 0,
                            maximum: 4,
                            isVisible: false),
                      ],
                      series: [
                        AreaSeries<ClimateHistory, int>(
                            name: 'Secondary',
                            // Bind data source
                            color: const Color.fromARGB(50, 173, 173, 173),
                            dataSource: history,
                            xValueMapper: (ClimateHistory climate, index) =>
                                index,
                            yValueMapper: y2ValueMapper,
                            yAxisName: 'Secondary'),
                        FastLineSeries<ClimateHistory, int>(
                          // Bind data source
                          dataSource: history,
                          xValueMapper: (ClimateHistory climate, index) =>
                              index,
                          yValueMapper: yValueMapper,
                          onCreateShader: (ShaderDetails details) {
                            return ui.Gradient.linear(details.rect.bottomCenter,
                                details.rect.topCenter, colors, stops);
                          },
                        ),
                      ]))
            ]));
}
