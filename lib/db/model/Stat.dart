class Stat {
  final int id;
  String type;
  int count;
  DateTime date;
  int objectiveId;

  Stat({this.id, this.type, this.count, this.date, this.objectiveId});

  // Create a Note from JSON data
  factory Stat.fromJson(Map<String, dynamic> json) => new Stat(
      id: json["id"],
      date: json["date"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["date"])
          : DateTime.fromMillisecondsSinceEpoch(0),
      count: json["count"],
      type: json["type"],
  objectiveId: json["objectiveId"]);

  // Convert our Note to JSON to make it easier when we store it in the database
  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date == null ? 0 : date.millisecondsSinceEpoch,
        "count": count,
        "type": type,
    "objectiveId" : objectiveId,
      };
}
