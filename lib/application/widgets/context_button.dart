import 'package:flutter/material.dart';
import 'package:secrc_controller/application/widgets/remote_button.dart';

class ContextButton extends SizedBox {
  ContextButton(
      {Key? key,
      required void Function()? onPressed,
      required Widget child,
      bool active = false})
      : super(
            key: key,
            width: 83,
            height: 70,
            child: RemoteButton(
                active: active, onPressed: onPressed, child: child));
}
