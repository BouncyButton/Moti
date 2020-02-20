import 'package:flutter/material.dart';

class Task {
  final int id;
  int completed;
  String title;
  String subtitle;
  String emoji;
  Color color;
  DateTime completedDateSinceEpoch;
  DateTime creationDateSinceEpoch;
  int rowNumber;
  int objectiveId;
  String repetition;
  bool isSuggestingAction;
  String classification;
  bool suggested;

  Task(
      {this.id,
      this.completed = 0,
      this.title = "",
      this.subtitle = "",
      this.emoji = "",
      this.color,
      this.completedDateSinceEpoch,
      this.creationDateSinceEpoch,
      this.rowNumber,
      this.repetition = 'once',
      this.objectiveId = 1,
      this.classification = 'remind',
      this.isSuggestingAction = false,
      this.suggested = false});

  // Create a Note from JSON data
  factory Task.fromJson(Map<String, dynamic> json) => new Task(
        id: json["id"],
        completed: json["completed"],
        title: json["title"],
        subtitle: json["subtitle"],
        emoji: json["emoji"],
        color: Color(json["color"]),
        completedDateSinceEpoch: json["completedDateSinceEpoch"] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                json["completedDateSinceEpoch"])
            : DateTime.fromMillisecondsSinceEpoch(0),
        rowNumber: json["rowNumber"],
        repetition: json["repetition"],
        objectiveId: json["objectiveId"],
        creationDateSinceEpoch: json["creationDateSinceEpoch"] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                json["creationDateSinceEpoch"])
            : DateTime.fromMillisecondsSinceEpoch(0),
        classification: json['classification'],
    suggested: json['suggested'] == 0 ? false : true,
      );

  // Convert our Note to JSON to make it easier when we store it in the database
  Map<String, dynamic> toJson() => {
        "id": id,
        "completed": completed,
        "title": title,
        "subtitle": subtitle,
        "emoji": emoji,
        "color": color.value,
        "completedDateSinceEpoch": completedDateSinceEpoch == null
            ? 0
            : completedDateSinceEpoch.millisecondsSinceEpoch,
        "creationDateSinceEpoch": creationDateSinceEpoch == null
            ? 0
            : creationDateSinceEpoch.millisecondsSinceEpoch,
        "rowNumber": rowNumber,
        "repetition": repetition,
        "objectiveId": objectiveId,
        "classification": classification,
    "suggested": suggested ? 1 : 0,
      };
}
