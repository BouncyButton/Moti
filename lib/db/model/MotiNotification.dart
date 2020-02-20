import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotiPriority { low, medium, high }

class MotiNotification {
  final int id;
  DateTime date;
  String title;
  String subtitle;
  int motivation;
  int ability;
  int addiction;
  int risk;
  String repetition;
  String classification;
  NotiPriority priority;
  String type;

  Time get preferredTime {
    if (date != null && date.hour != 0)
      return Time(date.hour, date.minute, date.second);
    return Time([10, 15, 18][Random(id).nextInt(3)], date.minute, date.second);
  }

  Day get preferredDay {
    if (date.weekday == 1) return Day.Monday;
    if (date.weekday == 2) return Day.Tuesday;
    if (date.weekday == 3) return Day.Wednesday;
    if (date.weekday == 4) return Day.Thursday;
    if (date.weekday == 5) return Day.Friday;
    if (date.weekday == 6) return Day.Saturday;
    if (date.weekday == 7) return Day.Sunday;
  }

  MotiNotification(
      {this.id,
      this.date,
      this.title,
      this.subtitle,
      this.motivation,
      this.ability,
      this.addiction,
      this.risk,
      this.repetition,
      this.classification,
      this.priority,
      this.type});

  // Create a Note from JSON data
  factory MotiNotification.fromJson(Map<String, dynamic> json) =>
      new MotiNotification(
        id: json["id"],
        date: json["date"] != null
            ? DateTime.fromMillisecondsSinceEpoch(json["date"])
            : DateTime.fromMillisecondsSinceEpoch(0),
        title: json['title'],
        subtitle: json['subtitle'],
        motivation: json["motivation"],
        ability: json["ability"],
        addiction: json["addiction"],
        risk: json["risk"],
        repetition: json["repetition"],
        classification: json["classification"],
        type: json["type"],
        priority: NotiPriority.values
            .firstWhere((e) => e.toString() == json['priority']),
      );

  // Convert our Note to JSON to make it easier when we store it in the database
  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date == null ? 0 : date.millisecondsSinceEpoch,
        "subtitle": subtitle,
        "title": title,
        "motivation": motivation,
        "ability": ability,
        "addiction": addiction,
        "risk": risk,
        "repetition": repetition,
        "classification": classification,
        "type": type,
        "priority": priority.toString(),
      };
}
