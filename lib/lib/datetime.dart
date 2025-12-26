import 'package:flutter/material.dart';

TimeOfDay convertToTime(String time) {
  int hour = int.parse(time.substring(0, 1));
  int mins = int.parse(time.substring(2, 3));
  return TimeOfDay(hour: hour, minute: mins);
}

String converToString(TimeOfDay time) {
  String hour = time.hour.toString();
  String minute = time.minute.toString();
  if (time.hour < 10) hour = '0$hour';
  if (time.minute < 10) minute = '0$minute';
  return '$hour$minute';
}
