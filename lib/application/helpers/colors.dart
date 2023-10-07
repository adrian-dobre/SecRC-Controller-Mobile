import 'package:flutter/material.dart';

Color? getCO2IndicatorColor(int? value) {
  if (value == null) {
    return null;
  }
  Color color;
  if (value > 2000) {
    color = Colors.red;
  } else if (value > 1500) {
    color = Colors.orange;
  } else if (value > 1000) {
    color = Colors.yellow;
  } else if (value > 600) {
    color = Colors.lightGreen;
  } else {
    color = Colors.green;
  }
  return color;
}

Color? getHumidityIndicatorColor(double? value) {
  if (value == null) {
    return null;
  }
  Color color;
  if (value > 70) {
    color = Colors.blue;
  } else if (value > 40) {
    color = Colors.green;
  } else {
    color = Colors.white;
  }
  return color;
}

Color? getTemperatureIndicatorColor(double? value) {
  if (value == null) {
    return null;
  }
  Color color;
  if (value > 30) {
    color = Colors.red;
  } else if (value > 27) {
    color = Colors.orange;
  } else if (value > 25) {
    color = Colors.yellow;
  } else if (value > 19) {
    color = Colors.green;
  } else {
    color = Colors.blue;
  }
  return color;
}

Color themeColorGradientStart = const Color(0xFF1c1f38);
Color themeColorGradientEnd = const Color(0xff101428);

class GradientConfig {
  List<Color> colors = [];
  List<double> stops = [];

  GradientConfig(
      {required List<Color> colors,
      required List<double> values,
      double transition = 0,
      required double min,
      required double max}) {
    colors.asMap().forEach((key, value) {
      if (key > 0) {
        double prevStop =
            (values.elementAt(key) - transition - min) / (max - min);
        double nextStop = (values.elementAt(key) - min) / (max - min);
        if (key < colors.length) {
          stops.add(prevStop);
          this.colors.add(colors.elementAt(key - 1));
          stops.add(nextStop);
          this.colors.add(value);
        }
      } else {
        double stop = (values.elementAt(key) - min) / (max - min);
        stops.add(stop);
        this.colors.add(value);
      }
    });
  }
}

Color lerpGradient(List<Color> colors, List<double> stops, double t) {
  for (var s = 0; s < stops.length - 1; s++) {
    final leftStop = stops[s], rightStop = stops[s + 1];
    final leftColor = colors[s], rightColor = colors[s + 1];
    if (t <= leftStop) {
      return leftColor;
    } else if (t < rightStop) {
      final sectionT = (t - leftStop) / (rightStop - leftStop);
      return Color.lerp(leftColor, rightColor, sectionT)!;
    }
  }
  return colors.last;
}

Color getLerp(GradientConfig gf, double? value, double min, double max) {
  return lerpGradient(
      gf.colors, gf.stops, ((value ?? min) - min) / (max - min));
}
