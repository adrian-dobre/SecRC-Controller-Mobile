import 'dart:math';

import 'package:flutter/material.dart';

List<Widget> getLabeledStatusIndicator(String label, double? value, String unit,
    {Color? rangeIndicatorColor, bool stripDecimals = false}) {
  return [
    Row(children: [
      Text(label,
          style: const TextStyle(
              color: Color(0xFF434657),
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    ]),
    Row(children: [
      Row(children: [
        Text(
            (value != null
                    ? stripDecimals
                        ? value.toInt()
                        : value
                    : '-- ')
                .toString(),
            style: const TextStyle(color: Colors.white, fontSize: 18))
      ]),
      simulateScript(unit, 18)
    ]),
    Row(
        children: rangeIndicatorColor != null
            ? [
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 50,
                      height: 2,
                      color: rangeIndicatorColor,
                    ))
              ]
            : [])
  ];
}

SizedBox simulateScript(String unit, double fontSize,
    {bool superscript = true}) {
  return SizedBox(
    height: fontSize,
    child: Column(
      mainAxisAlignment:
          superscript ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Text(unit,
            style: TextStyle(color: Colors.white, fontSize: fontSize / 2)),
      ],
    ),
  );
}

void showError(BuildContext context, String errorMessage) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          errorMessage,
          style: const TextStyle(color: Colors.white),
        )));
  });
}

int getHeatIndex(double celsisusTemperature, double relativeHumidity) {
    var fahrenheitTemperature = celsiusToFahrenheit(celsisusTemperature);
    var heatIndex = celsisusTemperature;
    if (fahrenheitTemperature > 40) {
        heatIndex = -42.379 + 2.04901523 * fahrenheitTemperature + 10.14333127 * relativeHumidity - 0.22475541 * fahrenheitTemperature * relativeHumidity - 0.00683783 * fahrenheitTemperature * fahrenheitTemperature - 0.05481717 * relativeHumidity * relativeHumidity + 0.00122874 * fahrenheitTemperature * fahrenheitTemperature * relativeHumidity + 0.00085282 * fahrenheitTemperature * relativeHumidity * relativeHumidity - 0.00000199 * fahrenheitTemperature * fahrenheitTemperature * relativeHumidity * relativeHumidity;
        if (relativeHumidity < 13 && fahrenheitTemperature >= 80 && fahrenheitTemperature <= 112) {
            var adjust = ((13 - relativeHumidity) / 4) * sqrt(17 - (fahrenheitTemperature - 95).abs() / 17);
            heatIndex -= adjust;
        } else if (relativeHumidity > 85 && fahrenheitTemperature >= 80 && fahrenheitTemperature <= 87) {
            var adjust = ((relativeHumidity - 85) / 10) * ((87 - fahrenheitTemperature) / 5);
            heatIndex += adjust;
        } else if (fahrenheitTemperature < 80) {
            heatIndex = 0.5 * (fahrenheitTemperature + 61.0 + ((fahrenheitTemperature - 68.0) * 1.2) + (relativeHumidity * 0.094));
        }
    }
    return fahrenheitToCelsius(heatIndex).round();
}


double celsiusToFahrenheit(double temperature) {
    return (temperature * 9 / 5) + 32;
}

double fahrenheitToCelsius(double temperature) {
    return (temperature - 32) * 5 / 9;
}

HeatIndexCategory getHeatIndexCategory(int heatIndex) {
    HeatIndexCategory? category;
    var tempRIndex = 0;
    while (category == null && tempRIndex < heatIndexRanges.length) {
        var range = heatIndexRanges[tempRIndex];
        if (range.min <= heatIndex && heatIndex <= range.max) {
            category = range.heatIndex;
        }
        tempRIndex++;
    }
    return category ?? HeatIndexCategory.beyondHumanThreshold;
}

enum HeatIndexCategory {
    safe,
    caution,
    extremeCaution,
    danger,
    extremeDanger,
    beyondHumanThreshold
}

const heatIndexToMessageMap = {
    [HeatIndexCategory.safe]: 'No heat stress danger.',
    [HeatIndexCategory.caution]: 'Fatigue possible with prolonged exposure and/or physical activity.',
    [HeatIndexCategory.extremeCaution]: 'Heat stroke, heat cramps or heat exhaustion possible with prolonged exposure and/or physicial activity.',
    [HeatIndexCategory.danger]: 'Heat cramps or heat exhaustion likely and heat stroke possible with prolonged exposure and/or physical activity.',
    [HeatIndexCategory.extremeDanger]: 'Heat stroke highly likely.',
    [HeatIndexCategory.beyondHumanThreshold]: 'alues beyond human resistance to heat.'
};

class HeatIndexRange {
  int min;
  int max;
  HeatIndexCategory heatIndex;
  HeatIndexRange({required this.min, required this.max, required this.heatIndex});
}

var heatIndexRanges = [HeatIndexRange(
    min: -0x8000000000000000, 
    max: 26,
    heatIndex: HeatIndexCategory.safe
), HeatIndexRange(
    min: 27,
    max: 31,
    heatIndex: HeatIndexCategory.caution
), HeatIndexRange(
    min: 32,
    max: 39,
    heatIndex: HeatIndexCategory.extremeCaution
), HeatIndexRange(
    min: 40,
    max: 50,
    heatIndex: HeatIndexCategory.danger
), HeatIndexRange(
    min: 51,
    max: 91,
    heatIndex: HeatIndexCategory.extremeDanger
), HeatIndexRange(
    min: 92,
    max: 0x7FFFFFFFFFFFFFFF,
    heatIndex: HeatIndexCategory.beyondHumanThreshold
)];
