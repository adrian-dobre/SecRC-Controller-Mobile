import 'package:flutter/material.dart';
import 'package:secrc_controller/application/widgets/remote_button.dart';

class ModeButton extends SizedBox {
  ModeButton(
      {Key? key,
      required void Function()? onPressed,
      bool active = false,
      bool showIndicator = false,
      required IconData iconData})
      : super(
            key: key,
            child: Stack(children: [
              RemoteButton(
                  active: active,
                  onPressed: onPressed,
                  child: Icon(
                    iconData,
                    size: 100,
                  )),
              showIndicator
                  ? Padding(
                      padding: const EdgeInsets.all(5),
                      child: SizedBox(
                        width: 15,
                        height: 15,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.blue),
                        ),
                      ))
                  : Container()
            ]));
}
