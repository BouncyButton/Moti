import 'dart:async';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/model/MotiNotification.dart';
import 'package:fluffy_bunny/db/model/MotivationalMessage.dart';
import 'package:fluffy_bunny/db/model/MotivationalEvent.dart';
import 'package:fluffy_bunny/db/model/Star.dart';
import 'package:fluffy_bunny/db/model/Stat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/Task.dart';
import '../model/Objective.dart';

import '../Database.dart';

// https://www.freecodecamp.org/news/using-streams-blocs-and-sqlite-in-flutter-2e59e1f7cdce/

class MotivationalBloc implements BlocBase {
  // Create a broadcast controller that allows this stream to be listened
  // to multiple times. This is the primary, if not only, type of stream you'll be using.
  final _motivationController = StreamController<Widget>.broadcast();

  // Input stream. We add our notes to the stream using this variable.
  StreamSink<Widget> get _inMotivationalMessage => _motivationController.sink;

  // Output stream. This one will be used within our pages to display the notes.
  Stream<Widget> get motivationalMessage => _motivationController.stream;

  // Create a broadcast controller that allows this stream to be listened
  // to multiple times. This is the primary, if not only, type of stream you'll be using.
  final _motivationPriorityController = StreamController<Widget>.broadcast();

  // Input stream. We add our notes to the stream using this variable.
  StreamSink<Widget> get _inPriorityMotivationalMessage =>
      _motivationPriorityController.sink;

  Stream<Widget> get motivationalPriorityMessage =>
      _motivationPriorityController.stream;

  final _motivationalEventController =
      StreamController<List<MotivationalEvent>>.broadcast();

  StreamSink<List<MotivationalEvent>> get inNotifyEvent =>
      _motivationalEventController.sink;

  final _starsController = StreamController<List<Star>>.broadcast();

  StreamSink<List<Star>> get _inStars => _starsController.sink;

  Stream<List<Star>> get stars => _starsController.stream;

  FlutterLocalNotificationsPlugin noti;

  final _pendingNotificationsController =
      StreamController<List<MotiNotification>>.broadcast();

  StreamSink<List<MotiNotification>> get _inPendingNotifications =>
      _pendingNotificationsController.sink;

  Stream<List<MotiNotification>> get pendingNotifications =>
      _pendingNotificationsController.stream;

  List<MotivationalEvent> taskEvents = [];
  List<MotivationalEvent> starEvents = [];

  AppBloc appBloc;

  MotivationalBloc({this.appBloc}) {
    getMotivationalMessage();

    // Listens for changes to the addNoteController and calls _handleAddNote on change
    _motivationalEventController.stream.listen(_handleMotivationalEvent);

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    noti = new FlutterLocalNotificationsPlugin();

    noti.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  getPendingNotifications() async {
    List<MotiNotification> mn = await DBProvider.db.retrieveNotifications();

    print('eccoti mn');

    List mn2 = await noti.pendingNotificationRequests();
    print("Scheduled notification length: ${mn2.length}");

    _inPendingNotifications.add(mn);
    return mn;
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  void planNotification(MotiNotification notification) async {
    DBProvider.db.addMotiNotification(notification);
  }

  replanNotifications() async {
    DBProvider.db.deletePendingNotifications();
    await noti.cancelAll();
    await appBloc.statBloc.getStats();
    await scheduleExistingNotifications();
  }

  scheduleExistingNotifications() async {
    List<MotiNotification> notificationList =
        await DBProvider.db.retrieveNotifications();
    for (MotiNotification notification in notificationList) {
      Time time = notification.preferredTime;
      Day day = notification.preferredDay;

      if (notification.repetition == 'daily') {
        var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
            'repeatDailyAtTime channel id',
            'repeatDailyAtTime channel name',
            'repeatDailyAtTime description',
            priority: Priority.Low);
        var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
        var platformChannelSpecifics = new NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await noti.showDailyAtTime(notification.id, notification.title,
            notification.subtitle, time, platformChannelSpecifics);
      } else if (notification.repetition == 'weekly') {
        var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
            'show weekly channel id',
            'show weekly channel name',
            'show weekly description',
            priority: Priority.Low);
        var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
        var platformChannelSpecifics = new NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await noti.showWeeklyAtDayAndTime(notification.id, notification.title,
            notification.subtitle, day, time, platformChannelSpecifics);
      } else if (notification.repetition == 'once') {
        var scheduledNotificationDateTime = notification.date;
        var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
            'your other channel id',
            'your other channel name',
            'your other channel description',
            priority: notification.priority == NotiPriority.low
                ? Priority.Low
                : Priority.High);
        var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
        NotificationDetails platformChannelSpecifics = new NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await noti.schedule(
            notification.id,
            notification.title,
            notification.subtitle,
            scheduledNotificationDateTime,
            platformChannelSpecifics,
            androidAllowWhileIdle: true);
      }
    }
  }

  // All stream controllers you create should be closed within this function
  @override
  void dispose() {
    _motivationalEventController.close();
  }

  void getStars() async {
    List<Star> stars = await DBProvider.db.getStars();
    _inStars.add(stars);
  }

  void getMotivationalMessage() async {
    MotivationalMessage message = _generateMessage();
    // add to the stream the final message
    _inMotivationalMessage.add(message.buildWidget());
    // checkAchievements();
  }

  void checkAchievements(/*List<MotivationalEvent> starsEvents*/) async {
//    if(starsEvents == null)
//      return;

    var eventTypes = (starEvents.map((e) => e.type)).toList();

    var eventStarTriggers = (starEvents.map((e) => e.triggerStarType)).toList();

    for (var e in eventStarTriggers) {
      if (e != '') {
        print("========================" + e);
        Stat completedStat = await DBProvider.db.getGenericStats(e);
        Star completedStar = await DBProvider.db.getGenericStar(e);
        print(completedStar.type);

        if (completedStar.type == 'error') {
          print('error star non trovata');
          continue;
        }

        if (completedStat.count == completedStar.currentLimit) {
          DBProvider.db.levelUp(completedStar);
          appBloc.levelUp(completedStar, completedStat);
          // TODO log stat
        }
      }
    }
  }

  MotivationalMessage _generateMessage() {
    // here we map
    var eventTypes = (taskEvents.map((e) => e.type)).toList();

    // priority ifs.

    if (eventTypes.contains(MotivationalEventType.tutorialActive) &&
        //(eventTypes.contains(MotivationalEventType.lastTask) ||
        (eventTypes.contains(MotivationalEventType.onlyRepeatableLeft) ||
            eventTypes.contains(MotivationalEventType.allDone))) {
      return MotivationalMessage.build(
          MotivationalMessageType.tutorialActiveLastStep);
    }

    if (eventTypes.contains(MotivationalEventType.tutorialActive)) {
      return MotivationalMessage.build(MotivationalMessageType.tutorialActive);
    }

    if (eventTypes.contains(MotivationalEventType.allEmpty)) {
      // should be a priority.
      return MotivationalMessage.build(MotivationalMessageType.allEmptyTodo);
    }

    if (eventTypes.contains(MotivationalEventType.allDone)) {
      // should be a priority.
      return MotivationalMessage.build(MotivationalMessageType.allDone);
    }

    if (eventTypes.contains(MotivationalEventType.lastTask)) {
      return MotivationalMessage.build(MotivationalMessageType.lastTask);
    }

    if (eventTypes.contains(MotivationalEventType.firstCompleted)) {
      return MotivationalMessage.build(MotivationalMessageType.firstCompleted);
    }

    if (eventTypes.contains(MotivationalEventType.secondCompleted)) {
      return MotivationalMessage.build(MotivationalMessageType.secondCompleted);
    }

    if (eventTypes.contains(MotivationalEventType.justAdded)) {
      return MotivationalMessage.build(MotivationalMessageType.justAdded);
    }

    if (eventTypes.contains(MotivationalEventType.keepAdding)) {
      return MotivationalMessage.build(MotivationalMessageType.keepAdding);
    }

    if (eventTypes.contains(MotivationalEventType.startDoing)) {
      return MotivationalMessage.build(MotivationalMessageType.startDoing);
    }

    if (eventTypes.contains(MotivationalEventType.notEmptyTodo)) {
      return MotivationalMessage.build(MotivationalMessageType.notEmptyTodo);
    }

    return MotivationalMessage.build(MotivationalMessageType.defaultMessage);
  }

  void _handleMotivationalEvent(List<MotivationalEvent> newEvents) async {
    // var eventTypes = (events.map((e) => e.type)).toList();

    // per ora non voglio eventi duplicati
    var newTaskEvents = newEvents
        .where((e) => e.changeTaskState)
        .toList(); //.removeWhere((e) => !e.changeTaskState);

    var newStarEvents = newEvents.where((e) => e.changeStarState).toList();

    if (newTaskEvents != null && newTaskEvents.length != 0) {
      taskEvents = newTaskEvents;
      getMotivationalMessage();
    }

    if (newStarEvents != null && newStarEvents.length != 0) {
      starEvents = newStarEvents;
      checkAchievements();
    }
  }
}
