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
