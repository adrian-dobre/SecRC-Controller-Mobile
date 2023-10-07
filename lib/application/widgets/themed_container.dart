import 'package:flutter/material.dart';
import 'package:secrc_controller/application/helpers/colors.dart';

class ThemedContainer extends Container {
  ThemedContainer({Key? key, required Widget child})
      : super(
            key: key,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[themeColorGradientStart, themeColorGradientEnd],
              ),
            ),
            child: child);
}
