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


String generate_id() {
  Random random = new Random();
  String id = '';

  for (int i = 1; i<15; i++) {
    if (i%2 == 0 && i!=10) {
      id += String.fromCharCodes(List.generate(1, (index) => random.nextInt(26) + 65));
    } else if (i%5 == 0) {
      id+= '-';
    } else {
      id += '${random.nextInt(9)}';
    }
  }

  return id;
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

// Function which creates standart app button
Widget button(
    {List<Function>? functions,
    String? text,
    BuildContext? context,
    EdgeInsetsGeometry? edgeInsetsGeometry}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 15),
    child: ElevatedButton(
      child: Text(text!, style: const TextStyle(color: Colors.black87)),
      onPressed: () {
        for (var func in functions!) {
          func();
        }
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Colors.black87,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
