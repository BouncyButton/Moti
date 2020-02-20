import 'dart:async';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:fluffy_bunny/StatData.dart';
import 'package:fluffy_bunny/db/model/MotiNotification.dart';
import 'package:fluffy_bunny/db/model/UserFeeling.dart';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/model/MotivationalMessage.dart';
import 'package:fluffy_bunny/db/model/MotivationalEvent.dart';
import 'package:fluffy_bunny/db/model/Star.dart';
import 'package:fluffy_bunny/db/model/Stat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tinycolor/tinycolor.dart';
import '../model/Task.dart';
import '../model/Objective.dart';
import 'dart:math';

import '../Database.dart';

class StatBloc implements BlocBase {
  final AppBloc appBloc;

  final _statController = StreamController<BezierChart>.broadcast();

  StreamSink<BezierChart> get _inStatChart => _statController.sink;

  Stream<BezierChart> get statChart => _statController.stream;

  StatBloc({this.appBloc});

  int inactivityDays;
  double nextTaskTodoDaySpan;
  DateTime startDate;
  List<Task> completedTasksInDay;
  bool userBehind;
  var noti;

  getStats() async {

    //UserFeeling latestUserFeeling = await DBProvider.db.getLastFeelings();  // ritorna null ma non dovrebbe ! D: TODO
    List<UserFeeling> allUserFeeling = await DBProvider.db.getRecentFeelings();

    // facciamo che viene scritto l'umore dell'utente con giorno startobiettivo - 1.
    // e scrivo moti: 2, abi: 2.
    List<Stat> rawStats;

    DateTime ufToCalculateDate = allUserFeeling.last.date;
    // while(ufToCalculate.isBefore(other))

    // calcolo i giorni mancanti
    while (DateTime.now().difference(ufToCalculateDate).inDays > 1) {
      ufToCalculateDate = ufToCalculateDate.add(Duration(days: 1));

      rawStats = await DBProvider.db.getMotiStats(ufToCalculateDate);

      print("qualche giorno fa è successo: ");
      rawStats.map((s) => print(s.type));

      UserFeeling uf = await _calculateUserFeeling(rawStats, ufToCalculateDate);
      await DBProvider.db.insertUserFeeling(uf);
    }

    // ricalcola oggi
    print("calcolo feeling di oggi");
    rawStats = await DBProvider.db.getMotiStats(DateTime.now());

    print("oggi è successo: ");
    rawStats.map((s) => print(s.type));

    // noti = appBloc.motivationalBloc.noti;

    UserFeeling todayFeeling =
        await _calculateUserFeeling(rawStats, DateTime.now());

    await _planNotifications(todayFeeling);

    if (allUserFeeling.last.date.difference(DateTime.now()).inDays == 0)
      await DBProvider.db.updateUserFeeling(todayFeeling);
    else
      await DBProvider.db.insertUserFeeling(todayFeeling);

    List<UserFeeling> ufs = await DBProvider.db.getRecentFeelings();
    BezierChart data = transformInBezierChart(ufs);
//
    _inStatChart.add(data);
  }

  Future _planNotifications(UserFeeling todayFeeling) async {
    Objective o = await DBProvider.db.cachedCurrentObjective;
    int objectiveId = (o.id);

    List<Task> incompleteTasks =
        await DBProvider.db.getIncompleteTasks(objectiveId);

    // =============== TASK SINGOLI

    Task onceTask = incompleteTasks
        .firstWhere((task) => task.repetition == 'once', orElse: () {
      return null;
    });
    if (onceTask != null) {
      double daysLeftUntilMotivationDown =
          (todayFeeling.nextTaskTodoDaySpan - todayFeeling.inactivityDays)
              .truncateToDouble();

      print("days left until motivation down: $daysLeftUntilMotivationDown");
      DateTime motiLow = DateTime.now()
//      DateTime(DateTime.now().year, DateTime.now().month,
//              DateTime.now().day, 0, 0, 0)
          .add(Duration(days: daysLeftUntilMotivationDown.toInt()));

      int increasingGap = 1;

      // per 15 giorni
      // pianifico in ogni caso.

      List acceptableHours({bool onlyPositive = false}) {
        var h;
        if (onlyPositive)
          h = [1, 3, 5, 7, 9, 11, 13];
        else
          h = [-13, -9, -7, -5, -3, -1, 1, 3, 5, 7, 9, 11, 13];

        var hok = [];

        for (var hh in h) {
          if (DateTime.now().add(Duration(hours: hh)).hour < 23 &&
              DateTime.now().add(Duration(hours: hh)).hour > 8) {
            hok.add(hh);
          }
        }
        return hok;
      }

      bool thereIsNotificationTomorrow = false;
      // ======================== QUESTI SONO GLI SPARK
      Objective o = await DBProvider.db.cachedCurrentObjective;
      while (increasingGap < 6) {
        if (motiLow.isAfter(DateTime.now())) {
          MotiNotificationText spark = getSpark(onceTask.title, o.title);

          DateTime sparkTime = motiLow.add(Duration(
              hours: acceptableHours()[
                  Random.secure().nextInt(acceptableHours().length)]));

          if (sparkTime.isBefore(DateTime.now().add(Duration(days: 1))))
            thereIsNotificationTomorrow = true;

          await DBProvider.db.addMotiNotification(MotiNotification(
            title: spark.title,
            subtitle: spark.subtitle,
            repetition: 'once',
            priority:
                increasingGap == 0 ? NotiPriority.high : NotiPriority.high,
            // TODO
            date: sparkTime,
            classification: onceTask.classification,
            type: 'spark',
          ));
        }
        motiLow = motiLow.add(Duration(days: increasingGap++));
      }

      // QUESTI SONO I TRIGGER

      if (daysLeftUntilMotivationDown > 2) {
        motiLow = DateTime.now()
            .add(Duration(days: daysLeftUntilMotivationDown.toInt()));
        int increasingGap = 1;
//        motiLow = motiLow.add(Duration(
//            days:
//                -increasingGap++)); // ci penso sotto con una notifica ad alta priorità
        motiLow =
            motiLow.add(Duration(days: -increasingGap++)); // comincio da qua

        while (motiLow.isAfter(DateTime.now())) {
          print("faccio cose con $motiLow");
          MotiNotificationText trigger = getTrigger(onceTask.title, o.title);

          DateTime triggerTime = motiLow.add(Duration(
              hours: acceptableHours()[
                  Random.secure().nextInt(acceptableHours().length)]));

          if (triggerTime.isBefore(DateTime.now().add(Duration(days: 1))))
            thereIsNotificationTomorrow = true;

          await DBProvider.db.addMotiNotification(MotiNotification(
              title: trigger.title,
              subtitle: trigger.subtitle,
              repetition: 'once',
              priority: NotiPriority.low,
              date: triggerTime,
              classification: onceTask.classification,
              type: 'trigger'));
          motiLow = motiLow.add(Duration(days: -increasingGap++));
        }
        daysLeftUntilMotivationDown = 1;
      }

      // QUESTO è L'ULTIMO TRIGGER PRIMA DEL CALO DI MOTIVAZIONE.
      if (daysLeftUntilMotivationDown == 1 ||
          daysLeftUntilMotivationDown == 2 && !thereIsNotificationTomorrow) {
        MotiNotificationText trigger = getTrigger(onceTask.title, o.title);

        daysLeftUntilMotivationDown =
            (todayFeeling.nextTaskTodoDaySpan - todayFeeling.inactivityDays)
                .truncateToDouble();
        motiLow = DateTime.now()
            .add(Duration(days: daysLeftUntilMotivationDown.toInt() - 1));

        var h = acceptableHours(onlyPositive: true);

        if (h.length > 0) {
          await DBProvider.db.addMotiNotification(MotiNotification(
            title: trigger.title,
            subtitle: trigger.subtitle,
            repetition: 'once',
            priority: NotiPriority.low,
            // TODO vbb
            date: motiLow
                .add(Duration(hours: h[Random.secure().nextInt(h.length)])),
            classification: onceTask.classification,
            type: 'last trigger before spark',
          ));
        }
      }
    }

    Task dailyTask = incompleteTasks.firstWhere(
        (task) =>
            task.repetition == 'daily' &&
            DateTime.now().difference(task.completedDateSinceEpoch).inDays > 0,
        orElse: () {
      return null;
    });
    bool allDailyTodayDone = false;
    if (dailyTask == null) {
      dailyTask = incompleteTasks
          .firstWhere((task) => task.repetition == 'daily', orElse: () {
        return null;
      });
      if (dailyTask != null)
        allDailyTodayDone = true;
    }

    if (dailyTask != null) {
      var rt = getRepeatTrigger(dailyTask.title, o.title, dailyTask.completed);
      await DBProvider.db.addMotiNotification(MotiNotification(
          repetition: 'daily',
          priority: NotiPriority.low,
          title: rt.title,
          subtitle: rt.subtitle,
          date: allDailyTodayDone
              ? dailyTask.completedDateSinceEpoch
                  .add(Duration(days: 1, seconds: -30))  // se ho fatto tutti i daily oggi, ricordo domani
              : DateTime.now().add(Duration(hours: 1)), // altrimenti ricordo tra un'ora
          classification: dailyTask.classification,
          type: 'daily trigger'));
    }


    // WEEKLY =================================
    Task weeklyTask = incompleteTasks
        .firstWhere((task) => task.repetition == 'weekly' &&
        DateTime.now().difference(task.completedDateSinceEpoch).inDays > 7, orElse: () {
      return null;
    });

    bool allWeeklyDoneSince7DaysAgo = false;
    if (weeklyTask == null) {
      weeklyTask = incompleteTasks
          .firstWhere((task) => task.repetition == 'weekly', orElse: () {
        return null;
      });
      if (weeklyTask != null)
        allWeeklyDoneSince7DaysAgo = true;
    }


    if (weeklyTask != null) {
      var rt = getRepeatTrigger(weeklyTask.title, o.title, weeklyTask.completed);

      await DBProvider.db.addMotiNotification(MotiNotification(
          repetition: 'weekly',
          priority: NotiPriority.low,
          title: rt.title,
          subtitle: rt.subtitle,
          date: allWeeklyDoneSince7DaysAgo
              ? weeklyTask.completedDateSinceEpoch
                  .add(Duration(hours: -1, days: 7))    // se ho fatto tutti i weekly questa settimana, ricordo tra una settimana
              : DateTime.now().add(Duration(days: 1)),  // altrimenti tra un giorno
          classification: weeklyTask.classification,
          type: 'weekly trigger'));
    }
  }

  @override
  void dispose() {
    _statController.close();
  }


  Future<UserFeeling> getCurrentUserFeeling() async {
    UserFeeling uf = (await DBProvider.db.getFeelingsByDay(DateTime.now()));
    if(uf != null) {
      return uf;
    }
    return null;
  }

  Future<UserFeeling> _calculateUserFeeling(
      List<Stat> rawStats, DateTime date) async {
//    int initialAbility = 1;
//    int initialMotivation = 1;
//    int initialRisk = 0;
//    int initialDependency = 0;

    if (rawStats == null) rawStats = [];

    DateTime from = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime to = DateTime(date.year, date.month, date.day + 1, 0, 0, -1);
    Objective o = await DBProvider.db.cachedCurrentObjective;
    int objectiveId = (o.id);

//    Stat limit =
//        rawStats.firstWhere((Stat stat) => stat.type == 'MotiEventDateLimit');
    // List<Stat> mainStatMotivation = rawStats.where((Stat stat) => stat.type == 'MotiEventMainStatMotivation');
    // List<Stat> mainStatAbility = rawStats.where((Stat stat) => stat.type == 'MotiEventMainStatAbility');
    // List<Stat> mainStatDependency = rawStats.where((Stat stat) => stat.type == 'MotiEventMainStatDependency');
    // List<Stat> mainStatRisk = rawStats.where((Stat stat) => stat.type == 'MotiEventMainStatRisk');
    DateTime limitDate = o.predictedCompletionDate;
    print("limitDate $limitDate");

//    if (rawStats.length == 0) // TODO è relativamente sbagliato..
//      {
//  print("no data :(");
//  return UserFeeling(motivation: )
//    }
    startDate = o.createdDate;
    print("startDate $startDate");

    int daysLeftUntilObjectiveCompletion;
    var isOvertime = false;

    if (limitDate.isAfter(from)) {
      daysLeftUntilObjectiveCompletion =
          limitDate.difference(from).abs().inDays;
      isOvertime = false;
    } else {
      daysLeftUntilObjectiveCompletion =
          from.difference(startDate.add(Duration(days: 2))).inDays;
      isOvertime = true;
    }

    print("time left $daysLeftUntilObjectiveCompletion");

    List<Task> completedTasks =
        await DBProvider.db.getCompletedTasks(objectiveId);
    List<Task> incompleteTasks =
        await DBProvider.db.getIncompleteTasks(objectiveId);

    completedTasks.sort((t, u) =>
        t.completedDateSinceEpoch.compareTo(u.completedDateSinceEpoch));
    incompleteTasks.sort(
        (t, u) => t.creationDateSinceEpoch.compareTo(u.creationDateSinceEpoch));

    int incompletedDailyTasks = 0;
    int incompletedDailyLearnTasks = 0;
    int incompletedDailyRemindTasks = 0;
    int incompletedDailyStopTasks = 0;
    int completedDailyTasks = 0;
    int completedDailyLearnTasks = 0;
    int completedDailyRemindTasks = 0;
    int completedDailyStopTasks = 0;

    int incompletedWeeklyTasks = 0;
    int incompletedWeeklyLearnTasks = 0;
    int incompletedWeeklyRemindTasks = 0;
    int incompletedWeeklyStopTasks = 0;
    int completedWeeklyTasks = 0;
    int completedWeeklyLearnTasks = 0;
    int completedWeeklyRemindTasks = 0;
    int completedWeeklyStopTasks = 0;

    int learnOnceLeft = 0;
    int remindOnceLeft = 0;
    int stopOnceLeft = 0;

    Task lastCompleteOnceTask;

    for (Task task in incompleteTasks) {
      if (task.repetition == 'once') {
        if (task.classification == 'learn') learnOnceLeft++;
        if (task.classification == 'remind') remindOnceLeft++;
        if (task.classification == 'stop') stopOnceLeft++;
      }

      // controllo i task repeat
      if (task.repetition == 'daily') {
        if ((task.completed == 0 &&
                from.difference(task.creationDateSinceEpoch) >
                    Duration(hours: 24)) ||
            (task.completed > 0 &&
                from.difference(task.completedDateSinceEpoch) >
                    Duration(hours: 24))) {
          incompletedDailyTasks++;
          if (task.classification == 'learn') incompletedDailyLearnTasks++;
          if (task.classification == 'remind') incompletedDailyRemindTasks++;
          if (task.classification == 'stop') incompletedDailyStopTasks++;
        } else if (task.completed >= 0 &&
            from.difference(task.completedDateSinceEpoch).inDays == 0) {
          // se l'ho completato ieri
          completedDailyTasks++;

          if (task.classification == 'learn') completedDailyLearnTasks++;
          if (task.classification == 'remind') completedDailyRemindTasks++;
          if (task.classification == 'stop') completedDailyStopTasks++;
        }
      }
      if (task.repetition == 'weekly') {
        if ((task.completed == 0 &&
                from.difference(task.creationDateSinceEpoch) >
                    Duration(days: 7)) ||
            (task.completed > 0 &&
                from.difference(task.completedDateSinceEpoch) >
                    Duration(days: 7))) {
          if (task.classification == 'learn') incompletedWeeklyLearnTasks++;
          if (task.classification == 'remind') incompletedWeeklyRemindTasks++;
          if (task.classification == 'stop') incompletedWeeklyStopTasks++;
          incompletedWeeklyTasks++;
        } else if (task.completed >= 0 &&
            from.difference(task.completedDateSinceEpoch).inDays == 0) {
          // se l'ho completato ieri
          completedWeeklyTasks++;

          if (task.classification == 'learn') completedWeeklyLearnTasks++;
          if (task.classification == 'remind') completedWeeklyRemindTasks++;
          if (task.classification == 'stop') completedWeeklyStopTasks++;
        }
      }
    }

    print("incompletedaily: $incompletedDailyTasks");
    print("learn: $incompletedDailyLearnTasks");
    print("remind: $incompletedDailyRemindTasks");
    print("stop: $incompletedDailyStopTasks");

    print("completedaily: $completedDailyTasks");
    print("learn: $completedDailyLearnTasks");
    print("remind: $completedDailyRemindTasks");
    print("stop: $completedDailyStopTasks");

    print("incompleteweekly: $incompletedWeeklyTasks");
    print("learn: $incompletedWeeklyLearnTasks");
    print("remind: $incompletedWeeklyRemindTasks");
    print("stop: $incompletedWeeklyStopTasks");

    print("completeweekly: $completedWeeklyTasks");
    print("learn: $completedWeeklyLearnTasks");
    print("remind: $completedWeeklyRemindTasks");
    print("stop: $completedWeeklyStopTasks");

    // guardo quando è stato completato l'ultimo task
    for (Task task in completedTasks) {
      if (task.repetition == 'once') {
        if (lastCompleteOnceTask == null)
          lastCompleteOnceTask = task;
        else {
          if (lastCompleteOnceTask.completedDateSinceEpoch
              .isBefore(task.completedDateSinceEpoch)) {
            lastCompleteOnceTask = task;
          }
        }
      }
    }

    int howManyTasksCompletedToday = completedTasks
        .where((t) =>
            t.completedDateSinceEpoch.add(Duration(days: 1)).isAfter(from))
        .length;

    int howManyTasksOnceCompleted =
        completedTasks.where((t) => t.repetition == 'once').length;
    print("tasks once completed: $howManyTasksOnceCompleted");
    int howManyTasksOnceIncomplete =
        incompleteTasks.where((t) => t.repetition == 'once').length;
    print("tasks once incomplete: $howManyTasksOnceIncomplete");

    int howManyTaskOnceAll =
        howManyTasksOnceCompleted + howManyTasksOnceIncomplete;
    print("tasks once all: $howManyTaskOnceAll");

    // TODO controllare domani ;)
    double estimatedTaskDays =
        (daysLeftUntilObjectiveCompletion.toInt() / howManyTasksOnceIncomplete);
    print("estimatedTaskDays: $estimatedTaskDays");

    int tasksShouldDo = 1;
    if (estimatedTaskDays < 1 && daysLeftUntilObjectiveCompletion > 0) {
      tasksShouldDo = (1 / estimatedTaskDays).floor() + 1; // almeno 2.
    } else {
      tasksShouldDo = 1;
    }

    print("shoulddo: $tasksShouldDo");

    // var lastCompletionDate = lastCompleteOnceTask == null ? startDate : lastCompleteOnceTask.completedDateSinceEpoch;

    // bugged TODO
    // tempo che dovrebbe passare tra il completamento dell'ultimo task e il prossimo task.
    // var nextTaskTodoDaySpan;

    if (tasksShouldDo > 1)
      nextTaskTodoDaySpan = 1;
    else {
      nextTaskTodoDaySpan =
          daysLeftUntilObjectiveCompletion / howManyTasksOnceIncomplete;
    }

    print("i need to do the next task in $nextTaskTodoDaySpan");

    // var inactivityDays;
    if (lastCompleteOnceTask == null) {
      inactivityDays = to.difference(startDate).inDays;
      print("never done anything! inactivity days: $inactivityDays");
    } else {
      print("Last once completed: ${lastCompleteOnceTask.title}");
      inactivityDays =
          to.difference(lastCompleteOnceTask.completedDateSinceEpoch).inDays;
      print("inactivity days: $inactivityDays");
    }

    userBehind = false;

    if (inactivityDays >= nextTaskTodoDaySpan) {
      // user indietro ed immotivato!
      print(":(");
      userBehind = true;
    } else {
      print(":) ci sto lavorando");
    }

    Function f = (Task task) {
      // se si trova in quel giorno particolare.
      return task.completedDateSinceEpoch.difference(from).inDays == 0 &&
          to.difference(task.completedDateSinceEpoch).inDays == 0;
    };

    // è stato creato prima del limite più avanti nel tempo?
    Function f2 = (Task task) {
      return task.creationDateSinceEpoch.difference(from).inDays == 0 &&
          to.difference(task.creationDateSinceEpoch).inDays == 0;
    };

    completedTasksInDay = completedTasks.where(f).toList();

    var addedTasksInDay = completedTasks.where(f2).toList();
    addedTasksInDay.addAll(incompleteTasks.where(f2).toList());

    var addedSuggestedTasksInDay =
        addedTasksInDay.where((task) => task.suggested).length;
    var addedNewTasksInDay =
        addedTasksInDay.where((task) => !task.suggested).length;

    var deletedLearn = 0;
    var deletedRemind = 0;
    var deletedStop = 0;

    for (Stat stat in rawStats) {
      if (stat.type == 'MotiEventDeletedLearnTask') deletedLearn++;
      if (stat.type == 'MotiEventDeletedRemindTask') deletedRemind++;
      if (stat.type == 'MotiEventDeletedStopTask') deletedStop++;
    }

    print('deleted learn: $deletedLearn');
    print('deleted remind: $deletedRemind');
    print('deleted stop: $deletedStop');

    // la logicaaaaa
    UserFeeling previousDayFeelings =
        await DBProvider.db.getFeelingsByDay(from.add(Duration(seconds: -1)));
    var motivation = 0;
    var ability = 0;
    var addiction = 0;
    var risk = 0;

    bool hasJustStarted = false;

    if (previousDayFeelings == null)
      hasJustStarted = true;
    else {
      motivation = previousDayFeelings.motivation;
      ability = previousDayFeelings.ability;
      addiction = previousDayFeelings.addiction;
      risk = previousDayFeelings.risk;
    }

    print(addedNewTasksInDay);
    motivation += 1 * (addedNewTasksInDay > 0 ? 1 : 0);
    ability += 1 * (addedSuggestedTasksInDay > 0 ? 1 : 0);

    motivation += -1 * deletedRemind;
    ability += -1 * deletedLearn;

    addiction += 1 * deletedStop;
    risk += 1 * deletedStop;

    // complete task
    for (Task task in completedTasksInDay) {
      if (task.classification != 'stop') {
        ability += 1;
        motivation += 1;
        risk += -1;
      } else {
        addiction += -1;
      }
    }

    // no completion

    if (userBehind) {
      if (learnOnceLeft > remindOnceLeft && learnOnceLeft > stopOnceLeft) {
        ability += -2;
        motivation += -1;
      }
      if (remindOnceLeft > learnOnceLeft && remindOnceLeft > stopOnceLeft) {
        ability += -1;
        motivation += -2;
      }
      if (stopOnceLeft > remindOnceLeft && stopOnceLeft > learnOnceLeft) {
        risk += 1;
        addiction += 2;
      }
      // in caso di pareggi
      if (learnOnceLeft == remindOnceLeft &&
          remindOnceLeft == stopOnceLeft &&
          remindOnceLeft != 0) {
        risk += 1;
        addiction += 1;
        ability += -1;
        motivation += -1;
      } else if (learnOnceLeft == remindOnceLeft && learnOnceLeft != 0) {
        ability += -2;
        motivation += -2;
      } else if (learnOnceLeft == stopOnceLeft && learnOnceLeft != 0) {
        ability += -2;
        motivation += -1;
        risk += 1;
        addiction += 2;
      } else if (remindOnceLeft == stopOnceLeft && remindOnceLeft != 0) {
        motivation += -2;
        ability += -1;
        risk += 1;
        addiction += 2;
      }
    }

    var addedLearn = 0;
    var addedRemind = 0;
    var addedStop = 0;
    if (hasJustStarted) {
      for (Task task in addedTasksInDay) {
        if (task.classification == 'learn') addedLearn++;
        if (task.classification == 'remind') addedRemind++;
        if (task.classification == 'stop') addedStop++;
      }

      if (addedLearn >= addedRemind) {
        ability += 1;
        motivation += 2;
      } else {
        ability += 2;
        motivation += 1;
      }
      addiction += 4;
      risk += 4;
    }

    // bounds
    if (motivation > 5) motivation = 5;
    if (motivation < 1) motivation = 1;

    if (ability > 5) ability = 5;
    if (ability < 1) ability = 1;

    if (addiction > 5) addiction = 5;
    if (addiction < 1) addiction = 1;

    if (risk > 5) risk = 5;
    if (risk < 1) risk = 1;

    print("ability $ability");
    print("motivation $motivation");
    print("addiction $addiction");
    print("risk $risk");

    return UserFeeling(
      objectiveId: o.id,
      date: from,
      motivation: motivation,
      ability: ability,
      addiction: addiction,
      risk: risk,
      nextTaskTodoDaySpan: nextTaskTodoDaySpan,
      inactivityDays: inactivityDays,
    );
  }

  BezierChart transformInBezierChart(List<UserFeeling> allFeelings,
      {bool viewMoti = true}) {
    List<DataPoint<DateTime>> motivationPoints = [];
    List<DataPoint<DateTime>> abilityPoints = [];
    List<DataPoint<DateTime>> addictionPoints = [];
    List<DataPoint<DateTime>> riskPoints = [];
    //var xAxis = [];

    for (UserFeeling uf in allFeelings) {
      // xAxis.add(uf.date);
      motivationPoints
          .add(DataPoint(value: uf.motivation.toDouble(), xAxis: uf.date));
      abilityPoints
          .add(DataPoint(value: uf.ability.toDouble(), xAxis: uf.date));
      addictionPoints.add(DataPoint(value: uf.risk.toDouble(), xAxis: uf.date));
      riskPoints.add(DataPoint(value: uf.addiction.toDouble(), xAxis: uf.date));
    }

    var series;
    if (viewMoti)
      series = [
        BezierLine(
          label: "Motivation",
          data: motivationPoints,
          lineColor: Colors.blue[200],
        ),
        BezierLine(
          label: "Ability",
          lineColor: Colors.deepPurple[300],
          data: abilityPoints,
        )
      ];
    else
      series = [
        BezierLine(
          label: "Addiction",
          data: addictionPoints,
        ),
        BezierLine(
          label: "Risk",
          data: riskPoints,
        ),
      ];

    return BezierChart(
      fromDate: allFeelings.first.date,
      toDate: allFeelings.last.date,

      bezierChartScale: BezierChartScale.WEEKLY,
      // xAxisCustomValues: xAxis,
      series: series,
      config: BezierChartConfig(
        displayYAxis: true,
        startYAxisFromNonZeroValue: false,
        yAxisTextStyle: TextStyle(fontSize: 14.0, color: Colors.white),

        verticalIndicatorStrokeWidth: 2.0,
        verticalIndicatorColor: Colors.black12,
        showVerticalIndicator: true,
        snap: true,
        footerHeight: 75.0,
        contentWidth: 2000,
        // TODO
        // contentWidth: MediaQuery.of(context).size.width * 2,
        backgroundGradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[500],
            // Colors.blueGrey[800],
            TinyColor(Colors.purple[800]).darken(17).color
          ],
        ),
      ),
    );
  }

  MotiNotificationText getSpark(String title, String objTitle) {
    var titleLow = title.toLowerCase();
    var sparks = [
      MotiNotificationText(
          title: "$title!",
          subtitle: "You're a bit behind, are you ready to $titleLow? 😎"),
      MotiNotificationText(
          title: "$title!",
          subtitle: "There are many stars ⭐ you can unlock now!"),
      MotiNotificationText(
          title: "$title!",
          subtitle: "You are quite close to get a new star ⭐ Unlock it now!"),
      MotiNotificationText(
          title: "$title!", subtitle: "I bee-lieve in you! 🐝"),
      MotiNotificationText(
          title: "$title!",
          subtitle: "🏹 I know you can ${objTitle.toLowerCase()}!"),
      MotiNotificationText(
          title: "$title!", subtitle: "Feeling down? 😢 Try to $titleLow! 😊"),
      MotiNotificationText(
          title: "$title!",
          subtitle:
              "Why don't you try to $titleLow with a friend? 👨🏽‍🤝‍👨🏼"),
      MotiNotificationText(
          title: "$title!", subtitle: "$title now and take a picture! 📷"),
    ];

    var random = Random.secure().nextInt(sparks.length);

    return sparks[random];
  }

  MotiNotificationText getTrigger(String title, String objTitle) {
    var titleLow = title.toLowerCase();
    var sparks = [
      MotiNotificationText(
          title: "$title", subtitle: "It's time to $titleLow 😎"),
      MotiNotificationText(title: "$title", subtitle: "$title now! 🕐"),
      MotiNotificationText(
          title: "$title", subtitle: "Is it a good time now to $titleLow?"),
      MotiNotificationText(title: "$title", subtitle: "Remember to $titleLow."),
      MotiNotificationText(
          title: "$title",
          subtitle:
              "There's something that you need to do if you want to ${objTitle.toLowerCase()}."),
    ];

    var random = Random.secure().nextInt(sparks.length);

    return sparks[random];
  }

  MotiNotificationText getRepeatTrigger(
      String title, String objTitle, int completed) {
    var titleLow = title.toLowerCase();
    var triggers;
    if (completed == 0)
      triggers = [
        MotiNotificationText(
            title: "$title", subtitle: "There's always a first time 🐣"),
        MotiNotificationText(
            title: "$title",
            subtitle: "Wanna try something new? Try to $titleLow! 🚀"),
        MotiNotificationText(
            title: "$title",
            subtitle: "🔔 You told me to remind you to $titleLow."),
      ];
    else if (completed <= 2)
      triggers = [
        MotiNotificationText(
            title: "$title",
            subtitle: "Do you think it's a good time to $titleLow again?"),
        MotiNotificationText(
            title: "$title", subtitle: "Remember to $titleLow 😉"),
        MotiNotificationText(
            title: "$title",
            subtitle:
                "There's something that you need to do if you want to ${objTitle.toLowerCase()}."),
      ];
    else
      triggers = [
        MotiNotificationText(
            title: "$title",
            subtitle: "Hey champion! It's time to $titleLow again."),
        MotiNotificationText(
            title: "$title",
            subtitle:
                "Wow! You managed to $titleLow $completed times. Can you do better? 😉"),
        MotiNotificationText(
            title: "$title",
            subtitle:
                "I'll keep reminding you to $titleLow. You can always archive this task!"),
      ];
    var random = Random.secure().nextInt(triggers.length);

    return triggers[random];
  }
}

class MotiNotificationText {
  String title;
  String subtitle;

  MotiNotificationText({this.title, this.subtitle});
}
