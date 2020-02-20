class UserFeeling {
  final int id;
  DateTime date;
  int objectiveId;
  int motivation;
  int ability;
  int addiction;
  int risk;
  int inactivityDays;
  double nextTaskTodoDaySpan;

  UserFeeling(
      {this.id,
      this.date,
      this.objectiveId,
      this.motivation,
      this.ability,
      this.addiction,
      this.risk,
      this.nextTaskTodoDaySpan,
      this.inactivityDays});

  // Create a Note from JSON data
  factory UserFeeling.fromJson(Map<String, dynamic> json) => new UserFeeling(
        id: json["id"],
        date: json["date"] != null
            ? DateTime.fromMillisecondsSinceEpoch(json["date"])
            : DateTime.fromMillisecondsSinceEpoch(0),
        objectiveId: json["objectiveId"],
        motivation: json["motivation"],
        ability: json["ability"],
        addiction: json["addiction"],
        risk: json["risk"],
        nextTaskTodoDaySpan: json["nextTaskTodoDaySpan"],
        inactivityDays: json["inactivityDays"],
      );

  // Convert our Note to JSON to make it easier when we store it in the database
  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date == null ? 0 : date.millisecondsSinceEpoch,
        "objectiveId": objectiveId,
        "motivation": motivation,
        "ability": ability,
        "addiction": addiction,
        "risk": risk,
        "nextTaskTodoDaySpan": nextTaskTodoDaySpan,
        "inactivityDays": inactivityDays,
      };
}
