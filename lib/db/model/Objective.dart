import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class Objective {
  int id;
  bool isTutorial;
  String photoPath;
  String title;
  String subtitle;
  bool isActive;
  DateTime createdDate;
  bool hasUserSelectedDate;
  DateTime predictedCompletionDate;
  Color color;
  bool notificationEnabled;

  Objective({this.id,
    this.isTutorial,
    this.photoPath,
    this.title,
    this.subtitle,
    this.isActive,
    this.createdDate,
    this.predictedCompletionDate,
    this.color,
    this.hasUserSelectedDate = false,
    this.notificationEnabled = true,
  }) {
    if (predictedCompletionDate == null)
      this.predictedCompletionDate = DateTime.now().add(Duration(days: 3));
    if (color == null)
      this.color = TinyColor(Color(0xff213277))
          .lighten(0)
          .saturate(0)
          .color;
  }

  // Create a Note from JSON data
  factory Objective.fromJson(Map<String, dynamic> json) =>
      new Objective(
        id: json["id"],
        isTutorial: json["isTutorial"] == 1 ? true : false,
        title: json["title"],
        subtitle: json["subtitle"],
        photoPath: json['photoPath'],
        isActive: json["isActive"] == 1 ? true : false,
        createdDate: DateTime.fromMillisecondsSinceEpoch(json["createdDate"]),
        predictedCompletionDate: DateTime.fromMillisecondsSinceEpoch(
            json["predictedCompletionDate"]),
        hasUserSelectedDate: json['hasUserSelectedDate'] == 1 ? true : false,
        color: Color(json["color"]),
          notificationEnabled: json['notificationEnabled'] == 1? true:  false,
      );

  // Convert our Note to JSON to make it easier when we store it in the database
  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "isTutorial": isTutorial,
        "title": title,
        "subtitle": subtitle,
        "photoPath": photoPath,
        "isActive": isActive,
        "createdDate": createdDate.millisecondsSinceEpoch,
        "predictedCompletionDate": predictedCompletionDate
            .millisecondsSinceEpoch,
        'hasUserSelectedDate': hasUserSelectedDate,
        'color': color.value,
        'notificationEnabled' : notificationEnabled,
      };

}
