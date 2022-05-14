// ignore_for_file: file_names

library svs.globals;

import 'package:flutter/material.dart';

Color textColor = Colors.grey.shade100;
Color backGrColorText = Colors.blueGrey;
String globalUserName = '';
Color mainColor = const Color(0xFFC165DD);
Color secondaryColor = const Color(0xFF5C27FE);
Color tertiaryColor = Colors.redAccent;
Color outlineColor = Colors.white;
String globalParentID = '';
String globalBusRegistrationNumber = '';
BoxDecoration globalDecoration = BoxDecoration(
    gradient: LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [
    mainColor,
    secondaryColor,
  ],
));

TextStyle getTextInputStyle() {
  return TextStyle(color: textColor, fontSize: 15);
}

InputDecoration getInputDecoration(String hint, Icon icon) {
  return InputDecoration(
      counterStyle: const TextStyle(color: Colors.white),
      // labelText: 'From',
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[100], fontSize: 15),
      labelStyle: TextStyle(color: textColor, fontSize: 15),
      contentPadding:
          const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
      fillColor: Colors.transparent,
      filled: true,
      disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: outlineColor, width: 3, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(20)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: outlineColor, width: 3, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(20)),
      focusColor: Colors.grey[100],
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: outlineColor, width: 3, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(20)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: outlineColor, width: 3, style: BorderStyle.solid)),
      suffixIcon: icon);
}
