import 'package:flutter/material.dart';

class ActivityIndicator extends StatelessWidget {
  const ActivityIndicator(
      {Key? key, required this.refreshingData, required this.sendingCommand})
      : super(key: key);

  final bool refreshingData;
  final bool sendingCommand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 32,
        child: Stack(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: refreshingData
                ? [
                    const Padding(
                        padding: EdgeInsets.fromLTRB(0, 7, 10, 5),
                        child: SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                                strokeWidth: 3, color: Colors.white)))
                  ]
                : [],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: sendingCommand
                ? [
                    const Padding(
                        padding: EdgeInsets.fromLTRB(0, 2, 35, 20),
                        child: Icon(Icons.wifi_rounded, size: 25))
                  ]
                : [],
          ),
        ]));
  }
}
