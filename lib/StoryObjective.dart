import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:math';


class StoryObjective {
  StoryObjective({String title, String subtitle, DateTime dateStart, String photoPath, Color color}) {
    this.title = title;
    this.subtitle = subtitle;
    this.dateStart = dateStart;
    this.photoPath = photoPath;
    this.color = color;
  }

  String imagePath;
  String title;
  String subtitle;
  String photoPath;
  DateTime dateStart;
  Color color;

  ImageProvider get image {
    if (imagePath == null) {
      var rng = new Random.secure();
      var pics = [1000,1001,100,1002,1003,1004,1005,1006,1008,1011,101,1015,1016,102,1019,1018,1021,1024,1025];

      // var index = rng.nextInt(pics.length);
      if (photoPath != null)
        return FileImage(File(photoPath));
      else
        return null;//NetworkImage("https://picsum.photos/id/${pics[index].toString()}/200"); //FlutterLogo();
    }
    else {
      return AssetImage(imagePath);
    }
  }
  String get date {
    if (dateStart != null) {
      return formatDate(dateStart);
    }
    return '';
  }
}



String formatDate(DateTime tm, {capitalized: true}) {
  DateTime today = new DateTime.now();
  Duration oneDay = new Duration(days: 1);
  Duration twoDay = new Duration(days: 2);
  Duration oneWeek = new Duration(days: 7);
  String month;
  switch (tm.month) {
    case 1:
      month = "January";
      break;
    case 2:
      month = "February";
      break;
    case 3:
      month = "March";
      break;
    case 4:
      month = "April";
      break;
    case 5:
      month = "May";
      break;
    case 6:
      month = "June";
      break;
    case 7:
      month = "July";
      break;
    case 8:
      month = "August";
      break;
    case 9:
      month = "September";
      break;
    case 10:
      month = "October";
      break;
    case 11:
      month = "November";
      break;
    case 12:
      month = "December";
      break;
  }

  Duration difference = today.difference(tm);

  if (difference.compareTo(oneDay) < 1) {
    return capitalized ? "Today" : "today";
  } else if (difference.compareTo(twoDay) < 1) {
    return capitalized ? "Yesterday" : "yesterday";
  } else if (difference.compareTo(oneWeek) < 1) {
    switch (tm.weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
    }
  } else if (tm.year == today.year) {
    return '${tm.day} $month';
  } else {
    return '${tm.day} $month ${tm.year}';
  }
  return "";
}