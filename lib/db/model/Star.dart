import 'package:fluffy_bunny/db/Database.dart';
import 'package:fluffy_bunny/db/model/Stat.dart';

class Star {
  final int id;
  String type;
  int currentLevel;
  List<int> levelUps;
  DateTime lastLevelUp;

  String title;
  String subtitle;
  String description;
  String emoji;

  Stat _stat;

  int get maxStars => levelUps.length;

  int get currentLimit => currentLevel == maxStars
      ? levelUps[currentLevel - 1]  // TODO
      : levelUps[currentLevel];

  int get nextLimit => currentLevel + 1 >= maxStars
      ? levelUps[currentLevel]
      : levelUps[currentLevel + 1];

  int get currentValue => _stat.count;

  Star(
      {this.id,
      this.type,
      this.currentLevel,
      this.levelUps,
      this.lastLevelUp,
      this.emoji,
      this.title,
      this.subtitle,
      this.description});

  Future init() async {
    _stat = await getStat();
  }

  // Create a Note from JSON data
  factory Star.fromJson(Map<String, dynamic> json) => new Star(
      id: json["id"],
      lastLevelUp: json["lastLevelUp"] != 0
          ? DateTime.fromMillisecondsSinceEpoch(json["lastLevelUp"])
          : null,
      levelUps: json["levelUps"]
          .toString()
          .split(",")
          .map((v) => int.parse(v))
          .toList(),
      type: json["type"],
      currentLevel: json["currentLevel"],
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      emoji: json['emoji']);

  // Convert our Note to JSON to make it easier when we store it in the database
  Map<String, dynamic> toJson() => {
        "id": id,
        "lastLevelUp":
            lastLevelUp == null ? 0 : lastLevelUp.millisecondsSinceEpoch,
        "levelUps": levelUps.join(","),
        "type": type,
        "currentLevel": currentLevel,
        "emoji": emoji,
        "title": title,
        "subtitle": subtitle,
        "description": description,
      };

  Future<Stat> getStat({cached: true}) async {
    if (_stat == null || !cached) {
      _stat = await DBProvider.db.getGenericStats(type);
    }
    return _stat;
  }
}
