import 'package:flutter/material.dart';
import 'package:tabebi/helper/colors.dart';

class DesignConfig {
  static double bottomSheetTopRadius = 20.0;
  static RoundedRectangleBorder setRoundedBorder(
    double bradius,
    bool isboarder, {
    Color bordercolor = Colors.transparent,
    double bwidth = 1.0,
  }) {
    return RoundedRectangleBorder(
        side: BorderSide(color: bordercolor, width: isboarder ? bwidth : 0),
        borderRadius: BorderRadius.circular(bradius));
  }

  static BoxDecoration boxDecorationBorder(
    Color color,
    double radius, {
    Color? bcolor,
    double bwidth = 1.0,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: bcolor == null ? null : Border.all(color: bcolor, width: bwidth),
    );
  }

  static BoxDecoration boxSpecificSide(Color color,
      {Color? bcolor,
      double? topStart = 0,
      double? topEnd = 0,
      double? bottomStart = 0,
      double? bottomEnd = 0}) {
    return BoxDecoration(
      color: color,
      border: bcolor == null ? null : Border.all(color: bcolor),
      borderRadius: BorderRadiusDirectional.only(
        topStart: Radius.circular(topStart!),
        bottomStart: Radius.circular(bottomStart!),
        topEnd: Radius.circular(topEnd!),
        bottomEnd: Radius.circular(bottomEnd!),
      ),
    );
  }

  static BoxDecoration boxDecoration(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration boxDecorationWithShadow(Color color, double bradius,
      {double blurradius = 7, Color? shadowcolor}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(bradius),
      boxShadow: [
        BoxShadow(
          blurRadius: blurradius,
          color: shadowcolor ?? lightGrey,
          spreadRadius: 3,
        ),
      ],
    );
  }

  static OutlineInputBorder setOutlineInputBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color),
    );
  }

  static UnderlineInputBorder setUnderlineInputBorder(Color color) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: color),
    );
  }
}
