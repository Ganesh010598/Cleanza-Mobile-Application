import 'package:flutter/material.dart';

Color getmeterColor({value}) {
  if (value > 0 && value < 26) {
    return Color.fromRGBO(0, 107, 255, 1);
  } else if (value >= 26 && value < 53) {
    return Colors.amber;
  } else {
    return Colors.red;
  }
}

Color getmeterAmbientColor({value}) {
  if (value > 0 && value < 26) {
    return Color.fromRGBO(0, 107, 255, 1).withOpacity(0.6);
  } else if (value >= 26 && value < 53) {
    return Colors.amber.withOpacity(0.6);
  } else {
    return Colors.red.withOpacity(0.6);
  }
}
