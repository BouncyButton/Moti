import 'dart:io';
import 'package:fluffy_bunny/db/model/MotiNotification.dart';
import 'package:fluffy_bunny/db/model/Star.dart';
import 'package:fluffy_bunny/db/model/Stat.dart';
import 'package:fluffy_bunny/db/model/UserFeeling.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tinycolor/tinycolor.dart';

import 'model/Objective.dart';
import 'model/Task.dart';

class DBProvider {
  Objective _cachedObjective;

  Future<Objective> get cachedCurrentObjective async {
    if (_cachedObjective == null) await getLatestObjective(getCached: false);
    return _cachedObjective;
  }

  // Create a singleton
  DBProvider._();

  String taskTable = 'Task';
  String statsTable = 'Stats';
  String starsTable = 'Stars';
  String objectiveTable = 'Objective';
  String userFeelingsTable = 'UserFeelings';
  String motiNotificationTable = 'MotiNotification';

  static final DBProvider db = DBProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  // adb shell run-as com.example.fluffy_bunny ls  /data/data/com.example.fluffy_bunny/app_flutter
  // metti rm -r in caso al posto di ls.

  /// adb shell run-as com.example.fluffy_bunny cp /data/data/com.example.fluffy_bunny/app_flutter/m3-30.db-shm /sdcard

  /// adb shell run-as com.example.fluffy_bunny cp /data/data/com.example.fluffy_bunny/app_flutter/m3-30.db-wal /sdcard

  /// adb pull /sdcard/m3-30.db-shm C:\\Users\\berga\\Desktop
  /// 68 bytes in 0.012s)

  /// adb pull /sdcard/m3-30.db-wal C:\\Users\\berga\\Desktop
  ///  /sdcard/m3-30.db-wal: 1 file pulled. 14.8 MB/s (127752 bytes in 0.008s)

  /// adb shell run-as com.example.fluffy_bunny cp /data/data/com.example.fluffy_bunny/app_flutter/m3-41.db-shm /sdcard
  /// adb shell run-as com.example.fluffy_bunny cp /data/data/com.example.fluffy_bunny/app_flutter/m3-41.db-wal /sdcard
  /// adb shell run-as com.example.fluffy_bunny cp /data/data/com.example.fluffy_bunny/app_flutter/m3-41.db /sdcard
  /// adb pull /sdcard/m3-41.db-shm C:\\Users\\berga\\Desktop
  /// adb pull /sdcard/m3-41.db-wal C:\\Users\\berga\\Desktop
  /// adb pull /sdcard/m3-41.db C:\\Users\\berga\\Desktop
  initDB() async {
    // Get the location of our app directory. This is where files for our app,
    // and only our app, are stored. Files in this directory are deleted
    // when the app is deleted.
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'm3-52.db');

    return await openDatabase(path, version: 1, onOpen: (db) async {},
        onCreate: (Database db, int version) async {
      // guess what? sqlite non supporta ADD FOREIGN KEY.
      await db.execute('''
      CREATE TABLE Objective (
                    id INTEGER PRIMARY KEY,
                    isTutorial INTEGER, --bool
                    title TEXT,
                    subtitle TEXT,
                    isActive INTEGER, --bool
                    createdDate INTEGER,
                    predictedCompletionDate INTEGER,
                    photoPath STRING,
                    hasUserSelectedDate INTEGER,
                    color INTEGER,
                    notificationEnabled INTEGER -- bool
                );
                ''');

      // Create the task table
      await db.execute('''
                CREATE TABLE Task (
                    id INTEGER PRIMARY KEY,
                    completed INTEGER,
                    title TEXT,
                    subtitle TEXT,
                    emoji TEXT,
                    color INTEGER, 
                    completedDateSinceEpoch INTEGER,
                    creationDateSinceEpoch INTEGER,
                    rowNumber INTEGER,
                    repetition STRING,
                    objectiveId INTEGER,
                    classification STRING,
                    suggested INTEGER,
                    FOREIGN KEY (objectiveId) REFERENCES Objective(id)
                );
                ''');

      // Create the stats table
      await db.execute('''
                CREATE TABLE Stats (
                    id INTEGER PRIMARY KEY,
                    type TEXT,
                    count INTEGER,
                    date INTEGER,
                    objectiveId INTEGER
                );
                ''');

      // Create the stars table
      await db.execute('''
                CREATE TABLE Stars (
                    id INTEGER PRIMARY KEY,
                    type TEXT,
                    currentLevel INTEGER,
                    lastLevelUp INTEGER,
                    levelUps STRING,
                    emoji STRING,
                    title STRING,
                    subtitle STRING,
                    description STRING
                );
                ''');

      // Create the userFeelings table
      await db.execute('''
                CREATE TABLE UserFeelings (
                    id INTEGER PRIMARY KEY,
                    date INTEGER,
                    objectiveId INTEGER,
                    motivation INTEGER,
                    ability INTEGER,
                    addiction INTEGER,
                    risk INTEGER,
                    inactivityDays INTEGER,
                    nextTaskTodoDaySpan REAL
                );
                ''');

      // Create the motiNotification table
      await db.execute('''
                CREATE TABLE MotiNotification (
                    id INTEGER PRIMARY KEY,
                    date INTEGER,
                    title STRING,
                    subtitle STRING,
                    motivation INTEGER,
                    ability INTEGER,
                    addiction INTEGER,
                    risk INTEGER,
                    priority STRING,
                    repetition STRING,
                    classification STRING,
                    type STRING
                );
                ''');
    });
  }

  newObjective(Objective objective) async {
    final db = await database;

    DateTime now = DateTime.now();
    objective.predictedCompletionDate = DateTime(now.year, now.month,
        now.day + 5 + 1, 0, 0, 0); //DateTime.now().add(Duration(days: 4));
    var result = await db.insert(this.objectiveTable, objective.toJson());
    print("Inserisco obiettivo: " + objective.title);

    var result3 = await db.query(this.objectiveTable,
        orderBy: 'createdDate DESC', limit: 1);

    int oid;
    if (result3.isNotEmpty)
      oid = result3.map((o) => Objective.fromJson(o)).first.id;
    else
      oid = null;

    UserFeeling uf = UserFeeling(
//        id: DateTime(now.year, now.month, now.day - 1, 0, 0, 0)
//                .millisecondsSinceEpoch +
//            oid,
        objectiveId: oid,
        date: DateTime(now.year, now.month, now.day - 1, 0, 0, 0),
        addiction: 4,
        risk: 4,
        motivation: 2,
        ability: 2);

    print("inserisco user feeling per obiettivo");
    print(uf.objectiveId);
    print(uf.toJson());

    // TODO wtf hack
    await db.insert(userFeelingsTable, uf.toJson());

    await db.insert(userFeelingsTable, uf.toJson());

    print("risultato inserimento user feeling");
  }

//
//  Future insertObjective(Objective objective) async {
//    final db = await database;
//    DateTime now = DateTime.now();
//    objective.predictedCompletionDate = DateTime(now.year, now.month,
//        now.day + 3 + 1, 0, 0, 0); //DateTime.now().add(Duration(days: 4));
//    var result = await db.insert(this.objectiveTable, objective.toJson());
//    print("Inserisco obiettivo: " + objective.title);
//
//    return result;
//  }

  getLatestObjective({bool getCached = true}) async {
    if (getCached && cachedCurrentObjective != null) {
      return cachedCurrentObjective;
    }

    final db = await database;

    print("GET LATEST OBJ ================");
    var result =
        await db.query(this.objectiveTable, orderBy: 'createdDate DESC');

    result.map((o) => print(o));

    Objective o;

    if (result.isNotEmpty) {
      o = result.map((obj) => Objective.fromJson(obj)).toList().first;
    } else {
      o = Objective(
          title: "Loading...", subtitle: "", isTutorial: false); // TODO
    }

    // TODO sfoltire gli aggiornamenti
    // print("Obiettivo recuperato: " + (o?.title));

    _cachedObjective = o;

    return o;
  }

  newTask(Task task, {bool unloggedInsert = false}) async {
    final db = await database;
    print('Il db sta aggiungendo il task.');
    print(task.title);
    var result = await db.insert(this.taskTable, task.toJson());

    if (!unloggedInsert) {
      await db.rawUpdate(
          'UPDATE Stats SET count = count + 1, date = ? WHERE type = ?',
          [DateTime.now().millisecondsSinceEpoch, 'addedTasks']);
      await db.insert(
          statsTable,
          Stat(
                  type: task.suggested
                      ? 'MotiEventAddedSuggestedTask'
                      : 'MotiEventAddedTask',
                  count: 1,
                  date: DateTime.now())
              .toJson());
    }
    return result;
  }

  completeTask(Task task) async {
    final db = await database;
    print(task);
    var result = await db.update(this.taskTable, task.toJson(),
        where: "id = ?", whereArgs: [task.id]);
    await db.rawUpdate(
        'UPDATE Stats SET count = count + 1, date = ? WHERE type = ?',
        [DateTime.now().millisecondsSinceEpoch, 'completedTasks']);

    if(task.emoji.contains('🐇')) // jump
    await db.rawUpdate(
        'UPDATE Stats SET count = count + 1, date = ? WHERE type = ?',
        [DateTime.now().millisecondsSinceEpoch, 'jumps']);


    await db.insert(
        statsTable,
        Stat(
                type: task.suggested
                    ? 'MotiEventCompletedSuggestedTask'
                    : 'MotiEventCompletedTask',
                count: 1,
                date: DateTime.now(),
                objectiveId: (await cachedCurrentObjective).id)
            .toJson());

    var result2 = await db
        .query(statsTable, where: 'type = ?', whereArgs: ['MotiStatDayStreak']);
    Stat stat = result2.toList().map((r) => Stat.fromJson(r)).toList().first;
    DateTime date = DateTime.now();
    var newCount;
    if (date.difference(stat.date).inDays > 1) {
      newCount = 1;
    } else if (date.day == stat.date.day &&
        date.month == stat.date.month &&
        date.year == stat.date.year) {
      // è lo stesso giorno
      newCount = stat.count;
    } else {
      // è un altro giorno
      newCount = stat.count + 1;
    }

    await db.rawUpdate(
        "UPDATE $statsTable SET count = $newCount, date = ${date.millisecondsSinceEpoch} WHERE type = 'MotiStatDayStreak'");

    return result;
  }

  updateTask(Task task) async {
    final db = await database;
    print(task);
    var result = await db.update(this.taskTable, task.toJson(),
        where: "id = ?", whereArgs: [task.id]);
    return result;
  }

  updateObjective(Objective objective) async {
    final db = await database;
    print(objective);
    var result = await db.update(this.objectiveTable, objective.toJson(),
        where: "id = ?", whereArgs: [objective.id]);

    await db.update(
        statsTable,
        Stat(
                type: "MotiEventDateLimit",
                count: objective.predictedCompletionDate.millisecondsSinceEpoch,
                // ehh
                date: DateTime.now(),
                objectiveId: objective.id)
            .toJson(),
        where:
            "objectiveId = ? AND type = ? AND count <> ${objective.predictedCompletionDate.millisecondsSinceEpoch}",
        whereArgs: [objective.id, 'MotiEventDateLimit']);

    return result;
  }

  deleteTask(Task task) async {
    final db = await database;
    print(task);
    var result =
        await db.delete(this.taskTable, where: 'id = ?', whereArgs: [task.id]);

    if (task.completed == 0 &&
        DateTime.now().difference(task.creationDateSinceEpoch).inHours >= 24) {
      await db.rawUpdate(
          'UPDATE Stats SET count = count + 1, date = ? WHERE type = ?',
          [DateTime.now().millisecondsSinceEpoch, 'deletedTasks']);

      var statType;
      if (task.classification == 'learn')
        statType = 'MotiEventDeletedLearnTask';
      if (task.classification == 'stop') statType = 'MotiEventDeletedStopTask';
      if (task.classification == 'remind')
        statType = 'MotiEventDeletedRemindTask';

      await db.insert(statsTable,
          Stat(type: statType, count: 1, date: DateTime.now()).toJson());
    }

    return result;
  }

  getIncompleteTasks(int objectiveId) async {
    // TODO refactor order
    if (objectiveId == null) {
      print("perché non c'è l'id?");
      objectiveId = 1;
    }
    final db = await database;
    var result = await db.query("$taskTable",
        where: '((completed = ?) or (repetition <> ?)) and objectiveId = ?',
        whereArgs: [0, 'once', objectiveId],
        orderBy: 'rowNumber ASC, creationDateSinceEpoch DESC');
    List<Task> tasks = result.isNotEmpty
        ? result.map((task) => Task.fromJson(task)).toList()
        : [];
    return tasks;
  }

  getTaskByName(int objectiveId, String name) async {
    // TODO refactor order
    if (objectiveId == null) {
      print("perché non c'è l'id?");
      objectiveId = 1;
    }
    final db = await database;
    var result = await db.query("$taskTable",
        where: 'objectiveId = ? AND title LIKE \'$name%\'',
        whereArgs: [objectiveId],
        orderBy: 'rowNumber ASC, creationDateSinceEpoch DESC');
    List<Task> tasks = result.isNotEmpty
        ? result.map((task) => Task.fromJson(task)).toList()
        : [];

    if (tasks.length > 0)
      return tasks[0];
    return null;
  }

  getStars() async {
    final db = await database;
    var result = await db.query("$starsTable",
        orderBy: 'currentLevel DESC, lastLevelUp DESC');
    List<Star> stars = result.isNotEmpty
        ? result.map((star) => Star.fromJson(star)).toList()
        : [];

    for (Star star in stars) {
      await star.init();
    }
    return stars;
  }

  getCompletedTasks(int objectiveId) async {
    final db = await database;
    if (objectiveId == null) objectiveId = 1;
    var result = await db.query("$taskTable",
        where: 'completed >= ? and objectiveId = ?',
        whereArgs: [1, objectiveId],
        orderBy: "completedDateSinceEpoch DESC");
    List<Task> tasks = result.isNotEmpty
        ? result.map((task) => Task.fromJson(task)).toList()
        : [];

    return tasks;
  }

  getObjectives() async {
    final db = await database;

    var result = await db.query("$objectiveTable", orderBy: "createdDate DESC");
    List<Objective> objectives = result.isNotEmpty
        ? result.map((o) => Objective.fromJson(o)).toList()
        : [];

    return objectives;
  }

  Future<Stat> getGenericStats(String type) async {
    // da rifare scrivendo ogni evento come stat, con datetime associati.
    // a richiesta generare le vere stats. suppongo. in questo modo posso tracciare
    // gli andamenti nel tempo.
    final db = await database;
    var result = await db.query(
      "$statsTable",
      where: 'type = ?',
      whereArgs: [type],
    );
    List<Stat> stats = result.isNotEmpty
        ? result.map((stat) => Stat.fromJson(stat)).toList()
        : [Stat(type: 'error')];

    return stats[0];
  }

  Future<Star> getGenericStar(String type) async {
    final db = await database;
    var result = await db.query(
      "$starsTable",
      where: 'type = ?',
      whereArgs: [type],
    );
    List<Star> stars = result.isNotEmpty
        ? result.map((star) => Star.fromJson(star)).toList()
        : [Star(type: 'error', title: 'error')];

    for (Star star in stars) {
      await star.init();
    }
    return stars[0];
  }

  removeAll() async {
    final db = await database;
    // prima obj?
    await db.execute("DELETE FROM Objective");
    await db.execute("DELETE FROM Task");
    await db.execute("DELETE FROM Stats");
    await db.execute("DELETE FROM UserFeelings");
    await db.execute("DELETE FROM Stars");
    await db.execute("DELETE FROM $motiNotificationTable");
    // return true;

    await db.insert(statsTable,
        Stat(type: "completedTasks", count: 0, date: DateTime.now()).toJson());
    await db.insert(statsTable,
        Stat(type: "deletedTasks", count: 0, date: DateTime.now()).toJson());
    await db.insert(statsTable,
        Stat(type: "addedTasks", count: 0, date: DateTime.now()).toJson());
    await db.insert(
        statsTable,
        Stat(type: "objectiveCompleted", count: 0, date: DateTime.now())
            .toJson());
    await db.insert(statsTable,
        Stat(type: "tutorial", count: 0, date: DateTime.now()).toJson());
    await db.insert(statsTable,
        Stat(type: "jumps", count: 0, date: DateTime.now()).toJson());

    await db.insert(
        statsTable,
        Stat(
                type: "MotiStatDayStreak",
                count: 0,
                date: DateTime.fromMillisecondsSinceEpoch(0))
            .toJson());
    await db.insert(
        statsTable,
        Stat(type: "objectivesCompleted", count: 0, date: DateTime.now())
            .toJson());

    await db.insert(
        starsTable,
        Star(
                type: "MotiStatDayStreak",
                levelUps: [2, 5, 30, 100, 365],
                lastLevelUp: DateTime.now(),
                currentLevel: 0,
                emoji: "💎",
                title: "Everlasting",
                subtitle: "Complete a task each day.",
                description:
                    "This is the most difficult achievement.\nCan you complete it?")
            .toJson());

    await db.insert(
        starsTable,
        Star(
                type: "jumps",
                levelUps: [1],
                lastLevelUp: DateTime.now(),
                currentLevel: 0,
                emoji: "🐇",
                title: "Dynamic",
                subtitle: "Complete a physical task.",
                description:
                    "Did you know that moving can improve your mood when you're feeling down?")
            .toJson());

    await db.insert(
        starsTable,
        Star(
                type: "deletedTasks",
                levelUps: [1, 2, 3],
                lastLevelUp: DateTime.now(),
                currentLevel: 0,
                emoji: "🔥",
                title: "Perseverant",
                subtitle: "Delete a task.",
                description:
                    "It's okay to change your mind, try to think to another task you can complete!")
            .toJson());

    await db.insert(
        starsTable,
        Star(
          type: "addedTasks",
          levelUps: [2, 5, 10, 30],
          lastLevelUp: DateTime.now(),
          currentLevel: 0,
          emoji: "💭",
          title: "Dreamer",
          subtitle: "Add a new task.",
          description: "Keep having new ideas 😉",
        ).toJson());

    await db.insert(
        starsTable,
        Star(
                type: "objectiveCompleted",
                levelUps: [2, 3, 4, 10],
                lastLevelUp: DateTime.now(),
                currentLevel: 0,
                emoji: "🏹",
                title: "Achiever",
                subtitle: "Complete an objective.",
                description: "You can always find something new to try 😎")
            .toJson());

    await db.insert(
        starsTable,
        Star(
          type: "completedTasks",
          levelUps: [1, 10, 30, 100, 300],
          lastLevelUp: DateTime.now(),
          currentLevel: 0,
          emoji: "🎖",
          title: "Completionist",
          subtitle: "Complete a task.",
          description: "One step at a time you can accomplish everything. 🤗",
        ).toJson());

    await db.insert(
        starsTable,
        Star(
                type: "tutorial",
                levelUps: [1],
                lastLevelUp: DateTime.now(),
                currentLevel: 0,
                emoji: "🎉",
                title: "Getting started",
                subtitle: "Complete the tutorial.",
                description: "Everybody need to start somewhere!")
            .toJson());
  }

  Future isFirstLaunch() async {
    final db = await database;
    return await db.query("$objectiveTable").then((value) {
      if (value.isEmpty) print('database vuoto');

      return value.isEmpty;
    });
  }

  deleteCurrentObjective() async {
    final db = await database;
    Objective currentObjective = await DBProvider.db.getLatestObjective();

    await db.delete(objectiveTable,
        where: 'id = ?', whereArgs: [currentObjective.id]);
    await db.delete(taskTable,
        where: 'objectiveId = ?', whereArgs: [currentObjective.id]);
  }



  completeCurrentObjective() async {
    final db = await database;

    Objective currentObjective = await DBProvider.db.getLatestObjective();

    currentObjective.isActive = false;
    // TODO currentObjective.completedDate = DateTime.now();
    // currentObjective.isCompleted = true;

    await db.update(objectiveTable, currentObjective.toJson(),
        where: 'id = ?', whereArgs: [currentObjective.id]);

//    await db.rawUpdate(
//        "INSERT INTO $statsTable SET count = count + 1, date = ${DateTime.now().millisecondsSinceEpoch} WHERE type = 'objectiveCompleted'");

    await db.rawUpdate(
        'UPDATE Stats SET count = count + 1, date = ? WHERE type = ?',
        [DateTime.now().millisecondsSinceEpoch, 'objectiveCompleted']);

    if (currentObjective.isTutorial)
      await db.rawUpdate(
          "UPDATE $statsTable SET count = 1, date = ${DateTime.now().millisecondsSinceEpoch} WHERE type = 'tutorial'");
  }

  levelUp(Star completedStar) async {
    final db = await database;
    await db.rawUpdate(
        'UPDATE Stars SET currentLevel = currentLevel + 1, lastLevelUp = ? WHERE id = ?',
        [DateTime.now().millisecondsSinceEpoch, completedStar.id]);

    await db.insert(
        statsTable,
        Stat(date: DateTime.now(), count: 1, type: 'MotiEventStarAchieved')
            .toJson());
  }

  Future<int> getTotalStarsGathered() async {
    final db = await database;
    var result =
        await db.rawQuery('SELECT SUM(currentLevel) as Total FROM $starsTable');

    return result.toList().first['Total'];
  }

  getYesterdayMotiStats() async {
    final db = await database;
    var lastLastMidnight = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day - 1, 0, 0, 0);
    //AND date >= ${twoWeeksAgo.millisecondsSinceEpoch}
    var lastMidnight = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
    //AND date >= ${twoWeeksAgo.millisecondsSinceEpoch}

    var oid = (await cachedCurrentObjective).id;

    var result = await db.rawQuery(
        "SELECT * FROM $statsTable WHERE type LIKE 'MotiEvent%' AND objectiveId = $oid AND date <= ${lastMidnight.millisecondsSinceEpoch} AND date >= ${lastLastMidnight.millisecondsSinceEpoch} ORDER BY date");

    return result.map((s) => Stat.fromJson(s)).toList();
  }

  getMotiStats(DateTime dt) async {
    final db = await database;
    var lastMidnight = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
    //AND date >= ${twoWeeksAgo.millisecondsSinceEpoch}
    var nextMidnight = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day + 1, 0, 0, 0);
    //AND date >= ${twoWeeksAgo.millisecondsSinceEpoch}

    var oid = (await cachedCurrentObjective).id;

    var result = await db.rawQuery(
        "SELECT * FROM $statsTable WHERE type LIKE 'MotiEvent%' AND objectiveId = $oid AND date <= ${nextMidnight.millisecondsSinceEpoch} AND date >= ${lastMidnight.millisecondsSinceEpoch} ORDER BY date");

    return result.map((s) => Stat.fromJson(s)).toList();
  }

  getLastFeelings() async {
    final db = await database;
    Objective o = await cachedCurrentObjective;
//    print("last feeling objective");
//    print(o.id);
    var result = await db.query(userFeelingsTable,
        limit: 1,
        orderBy: 'date DESC',
        where: 'objectiveId = ?',
        whereArgs: [o.id]);
    if (result.length == 0) return null;
    return UserFeeling.fromJson(result.toList().first);
  }

  getFeelingsByDay(DateTime d) async {
    final db = await database;
    Objective o = await cachedCurrentObjective;

    var result = await db.query(userFeelingsTable,
        limit: 1,
        orderBy: 'date DESC',
        where: 'objectiveId = ? AND date <= ?',
        whereArgs: [o.id, d.millisecondsSinceEpoch]);

    return UserFeeling.fromJson(result.toList().first);
  }

  getRecentFeelings() async {
    final db = await database;
    Objective o = await cachedCurrentObjective;
    print("recentfeelings for objective: ");
    print(o.id);

    if (o.id == null) return <UserFeeling>[];

    var result = await db.query(userFeelingsTable,
        orderBy: 'date ASC', where: 'objectiveId = ?', whereArgs: [o.id]);

//    var result3 = await db.insert(userFeelingsTable, UserFeeling(objectiveId: 1, motivation: 2, ability: 2, addiction: 4, risk: 4, date: DateTime.now()).toJson());

//    var result = await db.rawQuery(
//        "SELECT * FROM $userFeelingsTable WHERE objectiveId = ${o.id}");
    print("questi sono i feelings recuperati");
    assert(result.length > 0);
    for (var r in result) print(r);
    return result.isEmpty
        ? <UserFeeling>[]
        : result.map((uf) => UserFeeling.fromJson(uf)).toList();
  }

  getShouldRecalculateFeelings() async {
    final db = await database;
    Objective o = await cachedCurrentObjective;
    var result = await db.query(userFeelingsTable,
        orderBy: 'date DESC',
        where: 'objectiveId = ?',
        whereArgs: [o.id],
        limit: 1);

    if (result.length == 0) return true;

    UserFeeling latestUserFeeling = UserFeeling.fromJson(result.first);

    if (latestUserFeeling == null) return true;
    if (DateTime.now().add(Duration(days: -1)).isAfter(latestUserFeeling.date))
      return true;
    return false;
  }

  insertUserFeeling(UserFeeling todayFeeling) async {
    final db = await database;
    if (todayFeeling.objectiveId == null) {
      Objective o =
          await cachedCurrentObjective; //await getLatestObjective(getCached: false);
      todayFeeling.objectiveId = o.id;
    }

    print("inserisco user feeling per obiettivo");
    print(todayFeeling.objectiveId);
    print(todayFeeling.toJson());
    var result = await db.insert(userFeelingsTable, todayFeeling.toJson());
    print("risultato inserimento user feeling");
    print(result);
//    final db = await database;
  }

  updateUserFeeling(UserFeeling todayFeeling) async {
    final db = await database;

    if (todayFeeling.objectiveId == null) {
      Objective o = await cachedCurrentObjective;
      todayFeeling.objectiveId = o.id;
    }
    print("inserisco user feeling per obiettivo");
    print(todayFeeling.objectiveId);

    await db.rawUpdate(
        "UPDATE $userFeelingsTable SET date = ?, objectiveId = ?, motivation = ?, ability = ?, addiction = ?, risk = ? WHERE date = ? AND objectiveId = ?",
        [
          DateTime(todayFeeling.date.year, todayFeeling.date.month,
                  todayFeeling.date.day, 0, 0, 0)
              .millisecondsSinceEpoch,
          todayFeeling.objectiveId,
          todayFeeling.motivation,
          todayFeeling.ability,
          todayFeeling.addiction,
          todayFeeling.risk,
          DateTime(todayFeeling.date.year, todayFeeling.date.month,
                  todayFeeling.date.day, 0, 0, 0)
              .millisecondsSinceEpoch,
          todayFeeling.objectiveId
        ]);
  }

  goBackInTimeByOneDay() async {
    final db = await database;
    await db.rawUpdate(
        "UPDATE $taskTable SET completedDateSinceEpoch = completedDateSinceEpoch - 86400000");
    await db.rawUpdate(
        "UPDATE $taskTable SET creationDateSinceEpoch = creationDateSinceEpoch - 86400000");
    await db.rawUpdate(
        "UPDATE $objectiveTable SET predictedCompletionDate = predictedCompletionDate - 86400000");
    await db.rawUpdate(
        "UPDATE $objectiveTable SET createdDate = createdDate - 86400000");
    await db.rawUpdate("UPDATE $statsTable SET date = date - 86400000");
    await db.rawUpdate(
        "UPDATE $starsTable SET lastLevelUp = lastLevelUp - 86400000");
    await db.rawUpdate("UPDATE $userFeelingsTable SET date = date - 86400000");
    await db
        .rawUpdate("UPDATE $motiNotificationTable SET date = date - 86400000");
  }

  getTotalTasksCompleted() async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(completed) as Total FROM $taskTable WHERE completed > 0');

    print(result.toList().first['Total']);
    return result.toList().first['Total'];
  }

  getTotalStoriesCompleted() async {
    final db = await database;
    var result =
        await db.rawQuery('SELECT COUNT(*) as Total FROM $objectiveTable');

    print(result.toList().first['Total']);
    return result.toList().first['Total'];
  }

  addMotiNotification(MotiNotification notification) async {
    final db = await database;
    var result = await db.insert(motiNotificationTable, notification.toJson());
    return result;
  }

  void deletePendingNotifications() async {
    final db = await database;
    var result = await db.delete(motiNotificationTable);
  }

  Future<List<MotiNotification>> retrieveNotifications() async {
    final db = await database;
    var result = await db.query(motiNotificationTable);

    if (result.isNotEmpty)
      return result.map((e) => MotiNotification.fromJson(e)).toList();

    print("recupero ${result.length}");
    return <MotiNotification>[];
  }

  getDaysStreak() async {
    final db = await database;
    var result =
        await db.query(statsTable, where: "type = 'MotiStatDayStreak'");
    if (result.length > 0 &&
        DateTime.now()
                .difference(
                    DateTime.fromMillisecondsSinceEpoch(result.first['date']))
                .inDays <=
            1)
      return result.first['count'];
    else
      return 0;
  }

  changeNotificationEnabled(Objective o, bool enabled) async {
    final db = await database;
    var result = await db.rawUpdate(
        "UPDATE $objectiveTable SET notificationEnabled = ${enabled ? 1 : 0} WHERE id = ${o.id}");

    return result;
  }
}
