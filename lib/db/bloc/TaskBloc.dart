import 'dart:async';
import 'dart:io';
import 'package:fluffy_bunny/MotivationalController.dart';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/MotivationBloc.dart';
import 'package:fluffy_bunny/db/model/MotivationalEvent.dart';

import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/bloc/MotivationBloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/Task.dart';
import '../model/Objective.dart';

import '../Database.dart';

// https://www.freecodecamp.org/news/using-streams-blocs-and-sqlite-in-flutter-2e59e1f7cdce/

class TaskBloc implements BlocBase {
  // Create a broadcast controller that allows this stream to be listened
  // to multiple times. This is the primary, if not only, type of stream you'll be using.
  final _taskController = StreamController<List<Task>>.broadcast();

  // Input stream. We add our notes to the stream using this variable.
  StreamSink<List<Task>> get _inViewTasks => _taskController.sink;

  // Output stream. This one will be used within our pages to display the notes.
  Stream<List<Task>> get tasks => _taskController.stream;

  final _addTaskController = StreamController<Task>.broadcast();

  StreamSink<Task> get inAddTask => _addTaskController.sink;
  final _deleteTaskController = StreamController<Task>.broadcast();

  StreamSink<Task> get inDeleteTask => _deleteTaskController.sink;

  // per assicurarsi di non fare cose strane se un task non è stato ancora
  // cancellato (ovvero rimosso oppure completato, ovvero non più nella view
  // principale)
  final _taskDeletedController = StreamController<bool>.broadcast();

  StreamSink<bool> get _inDeleted => _taskDeletedController.sink;

  Stream<bool> get deleted => _taskDeletedController.stream;

  final _currentObjectiveController = StreamController<Objective>.broadcast();

  StreamSink<Objective> get _inObjective => _currentObjectiveController.sink;

  Stream<Objective> get currentObjective => _currentObjectiveController.stream;

  final _addObjectiveController = StreamController<Objective>.broadcast();
  final _completeTaskController = StreamController<Task>.broadcast();

  StreamSink<Task> get inCompleteNote => _completeTaskController.sink;

  final _addCompletedTaskController = StreamController<List<Task>>.broadcast();

  StreamSink<List<Task>> get _inAddCompletedTasks =>
      _addCompletedTaskController.sink;

  Stream<List<Task>> get completedTasks => _addCompletedTaskController.stream;

  final _eventsController = StreamController<List<MotivationalEvent>>();

  Stream<List<MotivationalEvent>> get events => _eventsController.stream;

  Sink<List<MotivationalEvent>> get _eventsProduced => _eventsController.sink;

  final _imDoneButtonController = StreamController<Widget>.broadcast();

  StreamSink<Widget> get _inImDone => _imDoneButtonController.sink;

  Stream<Widget> get imDoneButton => _imDoneButtonController.stream;

  final _totalStarController = StreamController<int>.broadcast();

  StreamSink<int> get _inTotalStars => _totalStarController.sink;

  Stream<int> get totalStars => _totalStarController.stream;

  final _totalTaskController = StreamController<int>.broadcast();

  StreamSink<int> get _inTotalTasks => _totalTaskController.sink;

  Stream<int> get totalTasks => _totalTaskController.stream;

  final _totalStoriesController = StreamController<int>.broadcast();

  StreamSink<int> get _inTotalStories => _totalStoriesController.sink;

  Stream<int> get totalStories => _totalStoriesController.stream;

  final _dayStreakController = StreamController<int>.broadcast();

  StreamSink<int> get _inDayStreak => _dayStreakController.sink;

  Stream<int> get dayStreak => _dayStreakController.stream;

  final _objectivesController = StreamController<List<Objective>>.broadcast();

  StreamSink<List<Objective>> get _inObjectives => _objectivesController.sink;

  Stream<List<Objective>> get objectives => _objectivesController.stream;

  bool _shouldSuggestNew = false;

  bool get shouldSuggestNew => _shouldSuggestNew;

  AppBloc appBloc;

  TaskBloc({this.appBloc}) {
    initDbIfFirstLaunch();

    refreshUI();

    // Listens for changes to the addNoteController and calls _handleAddNote on change
    _addTaskController.stream.listen(_handleAddTask);
    // _addCompletedTaskController.stream.listen(_handleAddCompletedTask);
    _deleteTaskController.stream.listen(_handleDeleteTask);
    _completeTaskController.stream.listen(_handleCompleteTask);
    _addObjectiveController.stream.listen(_handleAddObjective);
    // _imDoneButtonController.stream.listen(getImDoneButton);
  }

  void getImDoneButton() async {
    _inImDone.add(Container(child: Text("ksldahfj")));
  }

  refreshUI() async {
    await getCurrentObjective(getCached: false);
    await getTasks();
    await getCompletedTasks();
    await getTotalStars();
    await getTotalTasks();
    await getTotalStories();
    await getDaysStreak();
  }

  // All stream controllers you create should be closed within this function
  @override
  void dispose() {
    _taskController.close();
    _addTaskController.close();
    _deleteTaskController.close();
    _completeTaskController.close();
    _currentObjectiveController.close();
    _eventsController.close();
  }

  reInitAppDB() async {
    DBProvider.db.removeAll();
    // initDbIfFirstLaunch();
  }

  initDbIfFirstLaunch() async {
    // DBProvider.db.removeAll();

    DBProvider.db.isFirstLaunch().then((value) async {
      if (value) {
        // _inLandingPage.add(true);
        print(
            "***********************************************  PRIMO LANCIO *********");

        //_objectiveChosen
        DBProvider.db.removeAll();
//
//
//        await DBProvider.db.newObjective(Objective(
//            title: "Create your new objective",
//            subtitle: "Tap 🖊 to choose a title!",
//            predictedCompletionDate: DateTime.now().add(Duration(days: 3)),
//            createdDate: DateTime.now(),
//            isActive: true,
//            isTutorial: false));
//


//
//
        var obj = await _handleAddObjective(Objective(
          createdDate: DateTime.now(),
          predictedCompletionDate: DateTime.now().add(Duration(days: 3)),
          isTutorial: false,
          subtitle: "... or whatever you want",
          title: "Exercise",
          isActive: true,
          // id : 1
        ));
//
//        // getCurrentObjective();
//
//        int tutorialId = obj.id;
//
//        _handleAddTask(
//          Task(
//            completed: 0,
//            color: Colors.blue,
//            subtitle: "You should drink 8 glasses a day.",
//            title: "Drink a glass of water",
//            emoji: "🥤",
//            repetition: "once",
//            classification: "remind",
//            objectiveId: tutorialId,
//            rowNumber: 1,
//            creationDateSinceEpoch: DateTime.now(),
//          ),
//          refresh: false,
//          unloggedInsert: true,
//        );
//
//        _handleAddTask(
//          Task(
//            completed: 0,
//            color: Colors.blue,
//            subtitle: "Focus on your breath for 30 seconds.",
//            title: "Close your eyes and relax",
//            emoji: "🧘",
//            repetition: "once",
//            classification: "learn",
//            objectiveId: tutorialId,
//            rowNumber: 2,
//            creationDateSinceEpoch: DateTime.now(),
//          ),
//          refresh: false,
//          unloggedInsert: true,
//        );
//
//        _handleAddTask(
//          Task(
//            completed: 0,
//            color: Colors.blue,
//            // dovrebbe essere sennò tipo "metti a posto qualcosa"?
//            subtitle: "I promise you will feel better.",
//            title: "Jump!",
//            emoji: "🐇",
//            //🐸
//            classification: "learn",
//            repetition: "once",
//            objectiveId: tutorialId,
//            rowNumber: 3,
//            creationDateSinceEpoch: DateTime.now(),
//          ),
//          refresh: false,
//          unloggedInsert: true,
//        );
//
//        _handleAddTask(
//          Task(
//            completed: 0,
//            color: Colors.blue,
//            // dovrebbe essere sennò tipo "metti a posto qualcosa"?
//            subtitle:
//                "Use tasks as steps that you need to do (one or more times) to complete your objective.",
//            title: "Choose a task",
//            emoji: "💡",
//            repetition: "daily",
//            classification: "remind",
//            objectiveId: tutorialId,
//            rowNumber: 4,
//            creationDateSinceEpoch: DateTime.now(),
//          ),
//          refresh: false,
//          unloggedInsert: true,
//        );
//
//        _handleAddTask(
//          Task(
//              completed: 0,
//              color: Colors.blue,
//              subtitle: "Choose something memorable 😊",
//              title: "Take a photo",
//              repetition: "once",
//              classification: "learn",
//              emoji: "📷",
//              objectiveId: tutorialId,
//              creationDateSinceEpoch: DateTime.now(),
//              rowNumber: 5),
//          refresh: false,
//          unloggedInsert: true,
//        );

        // review gaggi

//        _handleAddTask(
//          Task(
//            completed: 0,
//            color: Colors.blue,
//            subtitle: "Finish the tutorial.",
//            title: "Choose your own objective!",
//            emoji: "🚩",
//            classification: "remind",
//            repetition: "once",
//            objectiveId: tutorialId,
//            rowNumber: 6,
//            creationDateSinceEpoch: DateTime.now(),
//          ),
//          refresh: false,
//          unloggedInsert: true,
//        );

        /*

        _handleAddTask(
            Task(
              completed: false,
              color: Colors.green,
              subtitle: "Finish the tutorial",
              title: "Choose your own objective!",
              emoji: "🚩",
              repetition: "once",
              objectiveId: tutorialId,
              rowNumber: 8,
              creationDateSinceEpoch: DateTime.now(),
            ),
            refresh: false);
        _handleAddTask(
            Task(
              completed: false,
              color: Colors.lightBlue,
              subtitle: "I'll help you. ☺",
              title: "Open the app daily",
              emoji: "0",
              repetition: "repeat",
              objectiveId: tutorialId,
              rowNumber: 7,
              creationDateSinceEpoch: DateTime.now(),
            ),
            refresh: false);
        _handleAddTask(
            Task(
              completed: false,
              color: Colors.blue,
              subtitle: "You will find all your memories there.",
              title: "Open the Stories tab",
              repetition: "once",
              emoji: "📚",
              objectiveId: tutorialId,
              rowNumber: 6,
              creationDateSinceEpoch: DateTime.now(),
            ),
            refresh: false);
        _handleAddTask(
            Task(
              completed: false,
              color: Colors.pinkAccent,
              subtitle: "Look at those shiny stars! ⭐",
              title: "Open the achievement tab",
              repetition: "once",
              emoji: "🎖",
              objectiveId: tutorialId,
              rowNumber: 5,
              creationDateSinceEpoch: DateTime.now(),
            ),
            refresh: false);
        _handleAddTask(
            Task(
                completed: false,
                color: Colors.green,
                subtitle: "Smile 😁",
                title: "Take a photo",
                repetition: "once",
                emoji: "📷",
                objectiveId: tutorialId,
                rowNumber: 4),
            refresh: false);
        _handleAddTask(
            Task(
              completed: false,
              color: Colors.deepPurple,
              subtitle: "Just swipe up!",
              title: "Create a new task",
              repetition: "once",
              emoji: "💡",
              objectiveId: tutorialId,
              rowNumber: 3,
              creationDateSinceEpoch: DateTime.now(),
            ),
            refresh: false);
        _handleAddTask(
            Task(
              completed: false,
              color: Colors.redAccent,
              subtitle: "Scroll me to the left. 👈",
              title: "Delete a task",
              emoji: "💥",
              repetition: "once",
              objectiveId: tutorialId,
              rowNumber: 2,
              creationDateSinceEpoch: DateTime.now(),
            ),
            refresh: false);
        _handleAddTask(
            Task(
              completed: false,
              color: Colors.green,
              title: "Complete your first task",
              subtitle: "👉 Scroll me to the right. ",
              emoji: "🐣",
              repetition: "once",
              objectiveId: tutorialId,
              rowNumber: 1,
              creationDateSinceEpoch: DateTime.now(),
            ),
            refresh: false);

        */
        // _inLandingPage.add(true);

        refreshUI();
        getCurrentObjective(getCached: false);
      } else {
        // _inLandingPage.add(false);
      }
    });
  }

  void _handleDeleteTask(Task task) async {
    await DBProvider.db.deleteTask(task);

    // gestisco gli eventi
    if (task.completed == 0 &&
        DateTime.now().difference(task.creationDateSinceEpoch).inHours >= 24)
      _eventsProduced.add([MotivationalEventTaskDeletedChanged()]);

    // Set this to true in order to ensure a note is deleted
    // before doing anything else
    _inDeleted.add(true);

    await appBloc.motivationalBloc.replanNotifications();
  }

  void _handleCompleteTask(Task task) async {
    task.completed = task.completed + 1;
    task.completedDateSinceEpoch = DateTime.now();

    if (task.repetition == 'once') {
      await DBProvider.db.completeTask(task);
      _inDeleted.add(true);
    } else {
      await DBProvider.db.completeTask(task);
    }
    SystemSound.play(SystemSoundType.click);


    if (task.emoji.contains('🐇')) {
      _eventsProduced.add([
        MotivationalEventTaskCompletedChanged(),
        MotivationalEventDayStreakChanged(),
        MotivationalEventJumpChanged()
      ]);
    } else {
      _eventsProduced.add([
        MotivationalEventTaskCompletedChanged(),
        MotivationalEventDayStreakChanged()
      ]);
    }
    await getCompletedTasks();
    await getTotalTasks();
    await getTotalStories();
    await getDaysStreak();
    // await getTasks(); // TODO

    // hack: il componente delle foto si crea un taskbloc da zero e appbloc non è istanziato.
    // in quel caso le notifiche non saranno ripianificate, ma dato che parliamo del tutorial
    // non mi preoccupo troppo (il tutorial verrà presumibilmente completato quando l'utente fa una foto)

    if (appBloc != null)
      tooltipScreen(task);

    if (appBloc != null)
      await appBloc.motivationalBloc.replanNotifications();

    return;
  }

  List<MotivationalEvent> decideMotivationalEvents(
      List<Task> tasks, List<Task> completed, Objective o) {
    List<MotivationalEvent> events = [];

    if ((tasks.length == 0 && completed.length >= 1))
      events.add(MotivationalEventAllDone());

    if (tasks.where((task) => task.repetition != 'once').length ==
            tasks.length &&
        completed.length >= 1)
      events.add(MotivationalEventOnlyRepeatableLeft());

    if (tasks /*.where((task) => task.repetition == 'once')*/ .length == 1 &&
        completed.length >= 1) events.add(MotivationalEventLastTask());

    if (o.isTutorial &&
        tasks.where((task) => task.repetition == 'once').length == 1)
      events.add(MotivationalEventLastTask());

    if (o.isTutorial) events.add(MotivationalEventTutorialActive());

    if (completed.length == 1) events.add(MotivationalEventFirstCompleted());

    if (completed.length == 2) events.add(MotivationalEventSecondCompleted());

    if (tasks.length == 1 && completed.length == 0)
      events.add(MotivationalEventJustAdded());

    if (tasks.length >= 2 && tasks.length <= 3 && completed.length == 0)
      events.add(MotivationalEventKeepAdding());

    if (tasks.length >= 4 && completed.length == 0 && !o.isTutorial)  // patched TODO
      events.add(MotivationalEventStartDoing());

    if (tasks.length == 0 && completed.length == 0)
      events.add(MotivationalEventAllEmpty());

    if (tasks.length > 0 && completed.length > 0)
      events.add(MotivationalEventNotEmptyTodo());

    return events;
  }

  getTasks() async {
    debugPrint("getTasks()");
    Objective o = await getCurrentObjective();
    // getTotalStars();
    // TODO fare cache e refresharla ogni volta che assegnerei.
    // in questo modo decidemoti() recupera dallo stato del blocco.
    // e if null, si fa lui il refresh.
    // Retrieve all the incomplete tasks from the database for that objective.
    List<Task> tasks = await DBProvider.db.getIncompleteTasks(o.id);
    List<Task> completed = await DBProvider.db.getCompletedTasks(o.id);

    for (Task task in tasks) {
      // TODO inserire logica per
      if (task.repetition != 'once' && task.completed >= 1) {
        task.color = Colors.green;
      } else if (task.classification == 'remind') {
        task.color = Colors.blue;
      } else if (task.classification == 'stop') {
        task.color = Colors.red;
      } else if (task.classification == 'learn') {
        task.color = Colors.deepPurple;
      }
    }

    // gestisco gli eventi
    List<MotivationalEvent> currentStateEvents =
        decideMotivationalEvents(tasks, completed, o);
    _eventsProduced.add(currentStateEvents);

    // gestisco il suggerimento del bounce
    // TODO se userHasEverConfirmed && userHasEverDeleted

    int userConfirmedTimes =
        await DBProvider.db.getGenericStats('completedTasks').then((val) {
      return val.count;
    });
    int userDeletedTimes =
        await DBProvider.db.getGenericStats('deletedTasks').then((val) {
      return val.count;
    });
    int userAddedTimes =
        await DBProvider.db.getGenericStats('addedTasks').then((val) {
      return val.count;
    });

    // print("UserConfirmed: $userConfirmedTimes");
    // print("UserDeletions: $userDeletedTimes");

//
//    if (o.isTutorial && completed.length == 2 ||
//        (!o.isTutorial && tasks.length == 0))
    if (o.isTutorial && tasks.length > 0 && tasks.first.title.contains('Add')
//            userConfirmedTimes == 1 &&
//            userDeletedTimes == 1 &&
//            userAddedTimes == 0 /*&& tasks.length == 6 */
//
        ||
        (!o.isTutorial && tasks.length == 0))
      _shouldSuggestNew = true;
    else
      _shouldSuggestNew = false;

    // se è passato un giorno, aggiorno
    // if(DateTime.now() lastStatUpdate )

    // Add all of the tasks to the stream so we can grab them later from our pages
    _inViewTasks.add(tasks);
  }

  Future<Objective> getCurrentObjective({bool getCached = true}) async {
    Objective objective =
        await DBProvider.db.getLatestObjective(getCached: getCached);
    _inObjective.add(objective);
    return objective;
  }

  Future<int> getTotalStars() async {
    int result = await DBProvider.db.getTotalStarsGathered();
    if (result != null) _inTotalStars.add(result);
    return result;
  }

  Future<int> getTotalTasks() async {
    int result = await DBProvider.db.getTotalTasksCompleted();
    if (result == null) result = 0;

    _inTotalTasks.add(result);
    return result;
  }

  Future<int> getTotalStories() async {
    int result = await DBProvider.db.getTotalStoriesCompleted();
    if (result == null) result = 0;

    _inTotalStories.add(result);
    return result;
  }

  Future<int> getDaysStreak() async {
    int result = await DBProvider.db.getDaysStreak();
    if (result == null) result = 0;

    _inDayStreak.add(result);
    return result;
  }

  getCompletedTasks() async {
    // update current obj
    Objective o = await getCurrentObjective();

    // Retrieve all the incomplete tasks from the database for that objective.
    List<Task> list = await DBProvider.db.getCompletedTasks(o.id);

    // Add all of the tasks to the stream so we can grab them later from our pages
    _inAddCompletedTasks.add(list);
  }

  getObjectives() async {
    // Retrieve all the incomplete tasks from the database for that objective.
    List<Objective> list = await DBProvider.db.getObjectives();

    // Add all of the tasks to the stream so we can grab them later from our pages
    _inObjectives.add(list);
  }

  void _handleAddTask(Task task,
      {bool refresh = true, bool unloggedInsert = false}) async {
    Objective o = await getCurrentObjective();
    if (o.isTutorial && (task.subtitle == "" || task.subtitle == null)) {
      task.subtitle = "Recently added tasks are added on top.";
      Task chooseTask =
          await DBProvider.db.getTaskByName(o.id, 'Add');
      _handleCompleteTask(chooseTask);
    }

    // Create the note in the database
    await DBProvider.db.newTask(task, unloggedInsert: unloggedInsert);

    // create event
    if (!unloggedInsert) {
      _eventsProduced.add([MotivationalEventTaskAddedChanged()]);
      await appBloc.motivationalBloc.replanNotifications();
    }
    if (task.repetition == 'daily') {
//      appBloc.motivationalBloc.noti.showDailyAtTime(id, title, body, notificationTime, notificationDetails)
    }

    // Retrieve all the notes again after one is added.
    // This allows our pages to update properly and display the
    // newly added note.
    if (refresh) await refreshUI();
  }

  _handleAddObjective(Objective objective) async {
    // Create the objective in the database
    await DBProvider.db.newObjective(objective);
    Objective o = await getCurrentObjective(getCached: false);

    if (o.isTutorial)
      _eventsProduced.add([
        MotivationalEventObjectiveCompletedChanged(),
        MotivationalEventTutorialCompletedChanged()
      ]);
    else
      _eventsProduced.add([MotivationalEventObjectiveCompletedChanged()]);

    return o;
  }

  _handleAddPhoto(Objective objective) async {
    // Create the objective in the database
    await DBProvider.db.updateObjective(objective);
    _eventsProduced.add([MotivationalEventPhotoAddedChanged()]);

    return await getCurrentObjective(getCached: false);
  }

  void completeTask(Task task) async {}

  restartCurrentObjective() async {
    await DBProvider.db.deleteCurrentObjective();
    await DBProvider.db.newObjective(Objective(
        title: "Create your new objective",
        subtitle: "Tap 🖊 to choose a title!",
        createdDate: DateTime.now(),
        isActive: true,
        isTutorial: false));
    // TODO okay?

    await refreshUI();
    await appBloc.motivationalBloc.replanNotifications();

  }

  void completeCurrentObjective() async {
    await DBProvider.db.completeCurrentObjective();
    await DBProvider.db.newObjective(Objective(
        title: "Create your new objective",
        subtitle: "Tap 🖊 to choose a title!",
        createdDate: DateTime.now(),
        isActive: true,
        isTutorial: false));

    Objective o = await getCurrentObjective();

    if (o.isTutorial)
      _eventsProduced.add([
        MotivationalEventObjectiveCompletedChanged(),
        MotivationalEventTutorialCompletedChanged()
      ]);
    else
      _eventsProduced.add([MotivationalEventObjectiveCompletedChanged()]);

    await refreshUI();

//    _eventsProduced.add([MotivationalEventTutorialCompletedChanged(), MotivationalEventObjectiveCompletedChanged()]);
  }

  void updateObjective(Objective objective) async {
    await DBProvider.db.updateObjective(objective);
    getCurrentObjective(getCached: false);
  }

  void addPhoto(Objective objective, String path) async {
    objective.photoPath = path;
    await DBProvider.db.updateObjective(objective);
    _eventsProduced.add([MotivationalEventPhotoAddedChanged()]);

    if (objective.isTutorial) {
      Task photoTask =
          await DBProvider.db.getTaskByName(objective.id, 'Take a photo');
      if (photoTask.completed == 0) _handleCompleteTask(photoTask);
    }
  }

  tooltipScreen(Task task) async {
    Objective o = await getCurrentObjective();

    if (o.isTutorial && task.completed == 1) appBloc.tooltip(task.repetition);
  }

  moveAllDaysBackByOne() async {
    await DBProvider.db.goBackInTimeByOneDay();
  }

  doSlideExample() async {}

  setCurrentTutorialObjective(String objectiveChosen) async {
    DBProvider.db.removeAll();

    ////////////////////////// EXERCISE ///////////////////////////////////

    if (objectiveChosen == 'exercise') {

//      await DBProvider.db.newObjective(Objective(
//          title: "Create your new objective",
//          subtitle: "Tap 🖊 to choose a title!",
//          createdDate: DateTime.now(),
//          isActive: true,
//          isTutorial: false));
//      // TODO okay?


      await DBProvider.db.newObjective(Objective(
        createdDate: DateTime.now(),
        predictedCompletionDate: DateTime.now().add(Duration(days: 3)),
        isTutorial: true,
        title: "Start exercising",
        subtitle: "Follow the instructions!",
        isActive: true,
        // id : 1
      ));

      Objective obj = await DBProvider.db.getLatestObjective();
      int tutorialId = obj.id;

      _handleAddTask(
        Task(
          completed: 0,
          color: Colors.blue,
          subtitle: "You should drink 8 glasses a day.",
          title: "Drink a glass of water",
          emoji: "🥤",
          repetition: "once",
          classification: "remind",
          objectiveId: tutorialId,
          rowNumber: 1,
          creationDateSinceEpoch: DateTime.now(),
        ),
        refresh: false,
        unloggedInsert: true,
      );

      _handleAddTask(
        Task(
          completed: 0,
          color: Colors.blue,
          title: "Find adequate clothing",
          subtitle: "You need to be able to move freely 🕊",
          emoji: "👕",
          repetition: "once",
          classification: "remind",
          objectiveId: tutorialId,
          rowNumber: 2,
          creationDateSinceEpoch: DateTime.now(),
        ),
        refresh: false,
        unloggedInsert: true,
      );

      _handleAddTask(
        Task(
          completed: 0,
          color: Colors.blue,
          title: "Walk for 15 minutes",
          subtitle: "Is there anything interesting nearby?",
          emoji: "🐇",
          //🐸
          classification: "remind",
          repetition: "once",
          objectiveId: tutorialId,
          rowNumber: 3,
          creationDateSinceEpoch: DateTime.now(),
        ),
        refresh: false,
        unloggedInsert: true,
      );



      _handleAddTask(
        Task(
          completed: 0,
          color: Colors.blue,
          // dovrebbe essere sennò tipo "metti a posto qualcosa"?
          subtitle:
          "Tasks are steps that you need to do (one or more times) to complete your objective.",
          title: "Add a new exercise",
          emoji: "💡",
          repetition: "daily",
          classification: "learn",
          objectiveId: tutorialId,
          rowNumber: 4,
          creationDateSinceEpoch: DateTime.now(),
        ),
        refresh: false,
        unloggedInsert: true,
      );


      _handleAddTask(
        Task(
            completed: 0,
            color: Colors.blue,
            subtitle: "Use the button in the upper right corner.",
            title: "Take a photo",
            repetition: "once",
            classification: "learn",
            emoji: "📷",
            objectiveId: tutorialId,
            creationDateSinceEpoch: DateTime.now(),
            rowNumber: 5),
        refresh: false,
        unloggedInsert: true,
      );
//
//      _handleAddTask(
//        Task(
//            completed: 0,
//            color: Colors.blue,
//            subtitle: "Reducing sugar in your diet can be useful to your health.",
//            title: "Avoid drinking soda for today",
//            repetition: "once",
//            classification: "stop",
//            emoji: "🎃",
//            objectiveId: tutorialId,
//            creationDateSinceEpoch: DateTime.now(),
//            rowNumber: 5),
//        refresh: false,
//        unloggedInsert: true,
//      );


    }

    ////////////////////////// MEDITATE ///////////////////////////////////

    if (objectiveChosen == 'meditate') {
      var obj = await _handleAddObjective(Objective(
        createdDate: DateTime.now(),
        predictedCompletionDate: DateTime.now().add(Duration(days: 3)),
        isTutorial: true,
        title: "Learn to meditate",
        subtitle: "Follow the instructions!",
        isActive: true,
        // id : 1
      ));

      int tutorialId = obj.id;

      _handleAddTask(
        Task(
          completed: 0,
          color: Colors.blue,
          title: "Drink a glass of water",
          subtitle: "You should drink 8 glasses a day.",
          emoji: "🥤",
          repetition: "once",
          classification: "remind",
          objectiveId: tutorialId,
          rowNumber: 1,
          creationDateSinceEpoch: DateTime.now(),
        ),
        refresh: false,
        unloggedInsert: true,
      );

      _handleAddTask(
        Task(
          completed: 0,
          color: Colors.blue,
          title: "Create a comfortable area",
          subtitle: "Avoid distractions. Get some cushions. Lit a scented candle if you want. 😊",
          emoji: "🕯",
          repetition: "once",
          classification: "learn",
          objectiveId: tutorialId,
          rowNumber: 2,
          creationDateSinceEpoch: DateTime.now(),
        ),
        refresh: false,
        unloggedInsert: true,
      );

      _handleAddTask(
        Task(
          completed: 0,
          color: Colors.blue,
          title: "Close your eyes and relax",
          subtitle: "Focus on your breath for 5 minutes.",
          emoji: "🐇",
          repetition: "once",
          classification: "learn",
          objectiveId: tutorialId,
          rowNumber: 3,
          creationDateSinceEpoch: DateTime.now(),
        ),
        refresh: false,
        unloggedInsert: true,
      );

      _handleAddTask(
        Task(
          completed: 0,
          color: Colors.blue,
          // dovrebbe essere sennò tipo "metti a posto qualcosa"?
          subtitle: "Tasks are steps that you need to do (one or more times) to complete your objective.",
          title: "Add a new exercise",
          emoji: "💡",
          //🐸
          classification: "remind",
          repetition: "daily",
          objectiveId: tutorialId,
          rowNumber: 4,
          creationDateSinceEpoch: DateTime.now(),
        ),
        refresh: false,
        unloggedInsert: true,
      );

      _handleAddTask(
        Task(
            completed: 0,
            color: Colors.blue,
            subtitle: "Use the button in the upper right corner.",
            title: "Take a photo",
            repetition: "once",
            classification: "learn",
            emoji: "📷",
            objectiveId: tutorialId,
            creationDateSinceEpoch: DateTime.now(),
            rowNumber: 5),
        refresh: false,
        unloggedInsert: true,
      );
    }
//
//    //////////////////////////////// BISCOTTI ///////////////////////////////
//    if (objectiveChosen == 'cookies') {
//      var obj = await _handleAddObjective(Objective(
//        createdDate: DateTime.now(),
//        predictedCompletionDate: DateTime.now().add(Duration(days: 3)),
//        isTutorial: true,
//        title: "Make cookies",
//        subtitle: "Follow the instructions!",
//        isActive: true,
//        // id : 1
//      ));
//
//      int tutorialId = obj.id;
//
//      _handleAddTask(
//        Task(
//          completed: 0,
//          color: Colors.blue,
//          subtitle: "avocado1",
//          title: "avocado1",
//          emoji: "🧘",
//          repetition: "once",
//          classification: "learn",
//          objectiveId: tutorialId,
//          rowNumber: 2,
//          creationDateSinceEpoch: DateTime.now(),
//        ),
//        refresh: false,
//        unloggedInsert: true,
//      );
//
//      _handleAddTask(
//        Task(
//          completed: 0,
//          color: Colors.blue,
//          subtitle: "meditate2",
//          title: "Drink a glass of water",
//          emoji: "🥤",
//          repetition: "once",
//          classification: "remind",
//          objectiveId: tutorialId,
//          rowNumber: 1,
//          creationDateSinceEpoch: DateTime.now(),
//        ),
//        refresh: false,
//        unloggedInsert: true,
//      );
//
//      _handleAddTask(
//        Task(
//          completed: 0,
//          color: Colors.blue,
//          // dovrebbe essere sennò tipo "metti a posto qualcosa"?
//          subtitle: "I promise you will feel better.",
//          title: "Jump!",
//          emoji: "🐇",
//          //🐸
//          classification: "learn",
//          repetition: "once",
//          objectiveId: tutorialId,
//          rowNumber: 3,
//          creationDateSinceEpoch: DateTime.now(),
//        ),
//        refresh: false,
//        unloggedInsert: true,
//      );
//
//      _handleAddTask(
//        Task(
//          completed: 0,
//          color: Colors.blue,
//          // dovrebbe essere sennò tipo "metti a posto qualcosa"?
//          subtitle:
//              "Use tasks as steps that you need to do (one or more times) to complete your objective.",
//          title: "Choose a task",
//          emoji: "💡",
//          repetition: "daily",
//          classification: "remind",
//          objectiveId: tutorialId,
//          rowNumber: 4,
//          creationDateSinceEpoch: DateTime.now(),
//        ),
//        refresh: false,
//        unloggedInsert: true,
//      );
//
//      _handleAddTask(
//        Task(
//            completed: 0,
//            color: Colors.blue,
//            subtitle: "Choose something memorable 😊",
//            title: "Take a photo",
//            repetition: "once",
//            classification: "learn",
//            emoji: "📷",
//            objectiveId: tutorialId,
//            creationDateSinceEpoch: DateTime.now(),
//            rowNumber: 5),
//        refresh: false,
//        unloggedInsert: true,
//      );
//    }
    //////////////////////////////// AVOCADO ///////////////////////////////
//    if (objectiveChosen == 'avocado') {
//      var obj = await _handleAddObjective(Objective(
//        createdDate: DateTime.now(),
//        predictedCompletionDate: DateTime.now().add(Duration(days: 3)),
//        isTutorial: true,
//        title: "Plant an avocado tree",
//        subtitle: "Follow the instructions!",
//        isActive: true,
//        // id : 1
//      ));
//
//      int tutorialId = obj.id;
//
//      _handleAddTask(
//        Task(
//          completed: 0,
//          color: Colors.blue,
//          subtitle: "avocado1",
//          title: "avocado1",
//          emoji: "🧘",
//          repetition: "once",
//          classification: "learn",
//          objectiveId: tutorialId,
//          rowNumber: 2,
//          creationDateSinceEpoch: DateTime.now(),
//        ),
//        refresh: false,
//        unloggedInsert: true,
//      );
//
//      _handleAddTask(
//        Task(
//          completed: 0,
//          color: Colors.blue,
//          subtitle: "meditate2",
//          title: "Drink a glass of water",
//          emoji: "🥤",
//          repetition: "once",
//          classification: "remind",
//          objectiveId: tutorialId,
//          rowNumber: 1,
//          creationDateSinceEpoch: DateTime.now(),
//        ),
//        refresh: false,
//        unloggedInsert: true,
//      );
//
//      _handleAddTask(
//        Task(
//          completed: 0,
//          color: Colors.blue,
//          // dovrebbe essere sennò tipo "metti a posto qualcosa"?
//          subtitle: "I promise you will feel better.",
//          title: "Jump!",
//          emoji: "🐇",
//          //🐸
//          classification: "learn",
//          repetition: "once",
//          objectiveId: tutorialId,
//          rowNumber: 3,
//          creationDateSinceEpoch: DateTime.now(),
//        ),
//        refresh: false,
//        unloggedInsert: true,
//      );
//
//      _handleAddTask(
//        Task(
//          completed: 0,
//          color: Colors.blue,
//          // dovrebbe essere sennò tipo "metti a posto qualcosa"?
//          subtitle:
//              "Use tasks as steps that you need to do (one or more times) to complete your objective.",
//          title: "Choose a task",
//          emoji: "💡",
//          repetition: "daily",
//          classification: "remind",
//          objectiveId: tutorialId,
//          rowNumber: 4,
//          creationDateSinceEpoch: DateTime.now(),
//        ),
//        refresh: false,
//        unloggedInsert: true,
//      );
//
//      _handleAddTask(
//        Task(
//            completed: 0,
//            color: Colors.blue,
//            subtitle: "Choose something memorable 😊",
//            title: "Take a photo",
//            repetition: "once",
//            classification: "learn",
//            emoji: "📷",
//            objectiveId: tutorialId,
//            creationDateSinceEpoch: DateTime.now(),
//            rowNumber: 5),
//        refresh: false,
//        unloggedInsert: true,
//      );
//    }

    if (objectiveChosen == 'new') {
      restartCurrentObjective();
    }
  }

//  void startObjective() async {
//    Objective o = new Objective(
//      title: "",
//      subtitle: "",
//      isTutorial: false,
//      createdDate: DateTime.now()
//    );
//    await DBProvider.db.newObjective(o);
//  }

//  void deleteTask(int index, {int objectiveId = 1}) async {
//
//    // recupero lo stream
//    getTasks();
//    // ora accedo ai tasks
//    List<Task> list = tasks.;
//
//    // prendo l'elemento
//    Task toRemove = list[index];
//
//    await DBProvider.db.deleteTask(toRemove);
//
//  }
}
