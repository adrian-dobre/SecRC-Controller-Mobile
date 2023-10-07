import 'package:flutter/material.dart';
import 'package:secrc_controller/application/widgets/state_chart.dart';

import '../../entities/climate_history.dart';
import '../helpers/colors.dart';
import '../helpers/utils.dart';

class ChartLabel {
  String label;
  double? value;
  String unit;
  bool stripDecimals;

  ChartLabel(this.label, this.value, this.unit, {this.stripDecimals = false});
}

class LabeledStateChart {
  late final StateChart stateChart;

  LabeledStateChart(
      {Key? key,
      required ChartLabel label,
      required List<ClimateHistory> history,
      required num? Function(ClimateHistory climate, int index) yValueMapper,
      required List<Color> colors,
      required List<double> values,
      double colorTransition = 0,
      num? Function(ClimateHistory climate, int index)? y2ValueMapper,
      required double minimum,
      required double maximum,
      required double width})
      : super() {
    GradientConfig gradientConfig = GradientConfig(
        colors: colors,
        values: values,
        min: minimum,
        max: maximum,
        transition: colorTransition);
    stateChart = StateChart(
      key: key,
      label: getLabeledStatusIndicator(label.label, label.value, label.unit,
          stripDecimals: label.stripDecimals,
          rangeIndicatorColor:
              getLerp(gradientConfig, label.value, minimum, maximum)),
      history: history,
      yValueMapper: yValueMapper,
      colors: gradientConfig.colors,
      stops: gradientConfig.stops,
      y2ValueMapper: y2ValueMapper,
      minimum: minimum,
      maximum: maximum,
      width: width,
    );
  }
}
