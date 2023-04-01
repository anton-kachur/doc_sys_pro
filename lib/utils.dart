import 'package:flutter/material.dart';
import 'dart:math';


late int personsBoxLength;
late int docsBoxLength;

Map<int, bool> generateCheckBoxBitMap({String? mode}) {
  Map<int, bool> map = {};
  for (int i = 0; i<(mode == "persons" ? personsBoxLength : docsBoxLength); i++) {
    map[i] = false;
  }

  return map;
}

Widget waitingOrErrorWindow(var text, var context) {
  return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            130, MediaQuery.of(context).size.height / 2, 0.0, 0.0),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 20,
              decoration: TextDecoration.none,
              color: Colors.black),
        ),
      ));
}

OutlineInputBorder textFieldStyle = OutlineInputBorder(
  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
  borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5),
);