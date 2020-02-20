import 'dart:async';

import 'package:camera/camera.dart';
import 'package:fluffy_bunny/AlertDialog.dart';
import 'package:fluffy_bunny/LevelUpScreen.dart';
import 'package:fluffy_bunny/MotivationalController.dart';
import 'package:fluffy_bunny/NiceButton.dart';
import 'package:fluffy_bunny/Done.dart';
import 'package:fluffy_bunny/Shaker.dart';
import 'package:fluffy_bunny/TakePictureScreen.dart';
import 'package:fluffy_bunny/TaskCard.dart';
import 'package:fluffy_bunny/FullscreenTooltip.dart';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/model/MotiNotification.dart';
import 'package:fluffy_bunny/db/model/MotivationalMessage.dart';
import 'package:fluffy_bunny/db/model/MotivationalEvent.dart';
import 'package:fluffy_bunny/db/model/Objective.dart';
import 'package:fluffy_bunny/db/model/Star.dart';
import 'package:fluffy_bunny/db/model/Stat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:fluffy_bunny/Stars.dart';
import 'package:fluffy_bunny/Stats.dart';
import 'package:fluffy_bunny/History.dart';
import 'package:fluffy_bunny/db/bloc/TaskBloc.dart';
import 'package:fluffy_bunny/db/bloc/MotivationBloc.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

import 'db/model/Task.dart';

class TaskPage extends StatefulWidget {
  final PageController controller;

  const TaskPage({
    Key key,
    this.controller,
  }) : super(key: key);

  @override
  createState() => new TaskPageState();
}

class TaskPageState extends State<TaskPage> with TickerProviderStateMixin {
  // PageController controller;
  bool _slideOpen = false;
  SlidableController slidableController;
  TaskBloc _taskBloc;
  MotivationalBloc _motivationalBloc;
  AppBloc _appBloc;
  int incompleteTasksSize;
  int completedTasksSize;
  bool isTutorial;
  int _bounces = 0;
  Color objectiveColor = Colors.amber[50];
  bool makeImDoneButtonVisibleInTutorial = false;

  AnimationController _acBounce;
  Animation<double> _animationBounceValue;

  bool stopAnimating = false;
  StreamSubscription levelUpSubscription;
  StreamSubscription tooltipSubscription;
  bool repeatableTaskSuggestionSeen = false;

  Color bgAppBarColor =
      TinyColor(Color(0xff213277)).lighten(0).saturate(0).color;

  // Color pickerColor = TinyColor(Color(0xff213277)).lighten(0).saturate(0).color;

  @override
  void dispose() {
    // non si fa dispose sulle animazioni senza resettarle!
    print("disposing bounce");
    // _acBounce.removeListener(animationListener);
    _acBounce.reset();
    _acBounce.dispose();

    stopAnimating = true;

    // a quanto pare è necessario... ma non capisco perche su questa sub
    // il contesto fosse null... anche se probabilmente è sensato che lo fosse.
    levelUpSubscription.cancel();
    tooltipSubscription.cancel();
    super.dispose();
  }

  jump() async {
    if (!mounted) return;
    _acBounce.forward().then((_) {
      if (!mounted) return;
      _acBounce.reverse().then((_) {
        if (!mounted) return;
        _bounces += 2;
        _acBounce.forward().then((_) {
          if (!mounted) return;
          _acBounce.reverse().then((_) {
            if (!mounted) return;
            Future.delayed(const Duration(milliseconds: 2000)).then((_) {
              if (!mounted) return;
              _bounces = 0;
              if (_taskBloc.shouldSuggestNew && !stopAnimating) jump();
            });
          });
        });
      });
    });
  }

  /*
  animationListener() async {
    debugPrint('animationListener $_bounces');
    if (_animationBounceValue.isCompleted && _bounces == 0) _acBounce.reverse();

    if (_animationBounceValue.isDismissed && _bounces == 0) {
      _bounces += 2;
      _acBounce.forward();
    }

    if (_animationBounceValue.isCompleted && _bounces == 2) {
      _acBounce.reverse();
    }

    if (_animationBounceValue.isDismissed && _bounces == 2) {
      await Future.delayed(const Duration(milliseconds: 2000)).then((_) {
        _bounces = 0;
        // ricomincio se devo

        if (_taskBloc.shouldSuggestNew && !stopAnimating) _acBounce.forward();
      });
    }
  }
*/
  @override
  void didUpdateWidget(TaskPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _appBloc = BlocProvider.of<AppBloc>(context);
    _taskBloc = _appBloc.taskBloc;
    _motivationalBloc = _appBloc.motivationalBloc;
    incompleteTasksSize = 0;
    completedTasksSize = 0;
    isTutorial = false;

    _acBounce = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);

    _animationBounceValue =
        CurvedAnimation(parent: _acBounce, curve: Curves.easeOutQuad);

    print("added listener");
    //  _acBounce.addListener(animationListener);
    if (_taskBloc.shouldSuggestNew) jump();

    // faccio partire
    // if (_taskBloc.shouldSuggestNew) _acBounce.forward();

    levelUpSubscription = _appBloc.levelUpDialog.listen(levelUpScreen);
    tooltipSubscription = _appBloc.tooltipScreen.listen(tooltipScreen);
  }

  void levelUpScreen(var arr) {
    Star star = arr[0];
    Stat stat = arr[1];

    print(star.toJson());

    LevelUpScreen(star: star, stat: stat).showDialog(context, this);
  }

  void tooltipScreen(String type) async {
//    if(context == null)
//      return;

    print("tooltip screen $type");
    if (type == 'daily' && !repeatableTaskSuggestionSeen) {
      repeatableTaskSuggestionSeen = true;
      await Future.delayed(Duration(milliseconds: 250));
      await fullscreenTooltip(context,
          title: 'Repeatable tasks',
          fromBottom: 0,
          fromLeft: MediaQuery.of(context).size.width / 2.0,
          leftTitle: 45,
          topTitle: 55,
          w: 400,
          subtitle:
              'You can confirm Daily tasks whenever you need to.\nWhen you\'re done, you can dismiss them by selecting Archive on the right.',
          skippable: false,
          animationArchive: true);
    }
  }

  TaskPageState() {
    slidableController = SlidableController(
        onSlideIsOpenChanged: handleSlideIsOpenChanged,
        onSlideAnimationChanged: (_) {});

    //slidableController.activeState?.open();
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {
      _slideOpen = isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    _taskBloc.getCompletedTasks();
    _taskBloc.getCurrentObjective(getCached: false);
    _taskBloc.getTasks();
    _taskBloc.getTotalTasks();
    _taskBloc.getTotalStars();
    _taskBloc.getTotalStories();
    _taskBloc.getDaysStreak();
    // diamo vita all'app.

    /*
    var popupStarStream = StreamBuilder<Widget>(
      stream: _motivationalBloc.starAchieved,
      builder:
          (BuildContext context, AsyncSnapshot<StarAchievedWidget> snapshot) {
        if (snapshot.hasData) {
          return AlertDialog();
        } else {
          return null;
        }
      },
    );
    */

    /*
    var overlayStream = StreamBuilder<List<dynamic>>(
      stream: _appBloc.levelUpDialog,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.hasData) {


          Star star = snapshot.data[0];
          Stat stat = snapshot.data[1];

          print(star.toJson());

          print ( 'hello its me your best dialog levelup');
          print(star.type);
          print(stat.count);
          Future.microtask(() => LevelUpScreen(star: star, stat: stat).showDialog(context));


          return Positioned(top: -10, left: -10, child: Container());
        } else {
          return Positioned(top: -10, left: -10, child: Container());
        }
      },
    );*/

    var toCompleteStream = StreamBuilder<List<Task>>(
        stream: _taskBloc.tasks,
        builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
          if (_taskBloc.shouldSuggestNew) jump(); //_acBounce.forward();

          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              if (isTutorial)
                makeImDoneButtonVisibleInTutorial = true;
              else
                makeImDoneButtonVisibleInTutorial = false;

              // aggiorno la progressbar

              incompleteTasksSize = 0;

              _taskBloc.getCompletedTasks();

              return SliverList(delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                if (index > 0) return null;

//                widget.motivationalController.notifyEvent(
//                    MotivationalEvent(type: MotivationalEventType.emptyTodo));
                return null;
                // return widget.motivationalController.getMotivationalElement();
              }));
            } else {
              List<Task> tasks = snapshot.data;

              if (isTutorial &&
                  tasks.where((task) => task.repetition != 'once').length ==
                      tasks.length)
                makeImDoneButtonVisibleInTutorial = true;
              else
                makeImDoneButtonVisibleInTutorial = false;

              incompleteTasksSize = tasks.length;
              // aggiorno la progressbar
              _taskBloc.getCompletedTasks();
              // print("Task da completare: " + snapshot.data.length.toString());

              return SliverList(delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                if (index >= snapshot.data.length) return null;

                Widget child;
//                if (index == 0) {

                if (isTutorial) {
                  child = ShakeAnimation(
                      child: TaskCard(
                        index: index,
                        sc: slidableController,
                        list: tasks,
                        task: tasks[index],
                      ),
                      sc: slidableController,
                      index: index,
                      repeat: tasks[index].repetition);
                } else {
                  child = TaskCard(
                    index: index,
                    sc: slidableController,
                    list: tasks,
                    task: tasks[index],
                  );
                }

                return Container(
                    // height: 80,
                    child: child);
              }));
            }
          }
          // If the data is loading in, display a progress indicator
          // to indicate that. You don't have to use a progress
          // indicator, but the StreamBuilder has to return a widget.

          return SliverList(delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            if (index > 0) return null;

            incompleteTasksSize = 0;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }));
        });

    var completedStream = StreamBuilder<List<Task>>(
      stream: _taskBloc.completedTasks,
      builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            completedTasksSize = 0;

            return SliverList(
                delegate: SliverChildListDelegate(
                    [_createProgressBar(context, 0, incompleteTasksSize)]));
          } else {
            List<Task> completedTasks = snapshot.data;
            // completedTasksSize = completedTasks.length;

            completedTasksSize = completedTasks
                .map((v) => v.completed)
                .reduce((v, el) => v + el);

            print(
                "Completed tasks: $completedTasksSize/${completedTasksSize + incompleteTasksSize}");

            return SliverList(
                delegate: SliverChildListDelegate([
              _createProgressBar(context, completedTasksSize,
                  completedTasksSize + incompleteTasksSize)
            ]));
          }
        }
        completedTasksSize = 0;
        return SliverList(
            delegate: SliverChildListDelegate(
                [_createProgressBar(context, 0, incompleteTasksSize)]));
      },
    );

    var motivationalStream = StreamBuilder<Widget>(
        stream: _motivationalBloc.motivationalMessage,
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.hasData) {
            Widget message = snapshot.data;
            return SliverList(
                delegate: SliverChildListDelegate([
              message,
            ]));
          }

          return SliverList(
            delegate: SliverChildListDelegate([]),
          );
        });

    var imDoneButton = StreamBuilder<List<Task>>(
        stream: _taskBloc.tasks,
        builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
          if (snapshot.hasData) {
            // List<Task> tasks = snapshot.data;

            _taskBloc.getCurrentObjective();

            return SliverList(
                delegate: SliverChildListDelegate([
              Visibility(
                visible: makeImDoneButtonVisibleInTutorial ||
                    (!isTutorial &&
                        (incompleteTasksSize > 0 || completedTasksSize > 0)),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
//                    child: Hero(
//                      tag: "done",
//                      child: Material(
//                        shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(100.0)),
                  child: InkWell(
                    splashColor: Theme.of(context).primaryColor.withAlpha(30),
                    onTap: () {
                      setState(() {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                duration: Duration(milliseconds: 400),
                                child: Done(
                                  bloc: _appBloc,
                                )));
                      });
                    },
                    child: NiceButton(
                      text: "I'M DONE!",
                      textColor: Colors.blue,
                    ),
                    //),
                    //),
                  ),
                )),
              )
            ]));
          }

          return SliverList(
            delegate: SliverChildListDelegate([]),
          );
        });

    var pendingNotifications = StreamBuilder<List<MotiNotification>>(
      stream: _motivationalBloc.pendingNotifications,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Widget> w = [];
          List notis = snapshot.data;
          notis.sort((n, m) => n.date.compareTo(m.date));

          for (MotiNotification el in notis) {
            w.add(Container(
                height: 75,
                child: Card(
                    child: Text(
                        "${el.type} Notification '${el.title}' (${el.subtitle}) planned at ${el.date} with ${el.priority} priority and ${el.repetition} repetition"))));
          }

          if (snapshot.data.length == 0)
            w.add(Container(
                height: 100,
                child: Card(child: Text("No notifications planned"))));

          return Container(
            height: 350,
            child: ListView(
              children: w,
            ),
          );
        } else {
          return Container(); // CircularProgressIndicator();
        }
      },
    );

    var sliverAppBarStream = StreamBuilder<Objective>(
      stream: _taskBloc.currentObjective,
      builder: (BuildContext context, AsyncSnapshot<Objective> snapshot) {
        Objective objective = snapshot.data;
        if (!snapshot.hasData)
          objective = Objective(title: "Loading...", subtitle: "");

        // are u happy now
        this.bgAppBarColor = objective.color;

        var widgets;
        var firstHalfTitle;
        var secondHalfTitle;
        bool longTitle;

        if (objective.title.length > 20) {
          longTitle = true;
          // print("il titolo è un po'  lungo");

          firstHalfTitle = "";
          secondHalfTitle = "";
          var splitted = objective.title.split(" ");
          var i = 0;
          while (firstHalfTitle.length < objective.title.length / 2) {
            firstHalfTitle += splitted[i] + " ";
            i++;
          }
          //print(firstHalfTitle);
          while (i < splitted.length) {
            secondHalfTitle += splitted[i] + " ";
            i++;
          }
          //print(secondHalfTitle);
        } else {
          longTitle = false;
          // print("il titolo non è così lungo");
          // creo i widgets

        }

        // TODO controllare gli aggiornamenti
//        print("L'obiettivo corrente è tutorial? " +
//            objective.isTutorial.toString());

        isTutorial = objective.isTutorial;

        if (isTutorial == null)
          isTutorial = false; // patched (it's bugged sometimes)

        return SliverAppBar(
            backgroundColor: bgAppBarColor,

//            TinyColor(Theme.of(context).primaryColorDark)
//                .darken(6)
//                .saturate(22)
//                .color,
//           bottom: PreferredSize(preferredSize: Size(20.0,20.0),child:Text("wtf?")) ,
            pinned: true,
            expandedHeight: 250.0,
            automaticallyImplyLeading: false,
//            leading: PreferredSize(
//              child: Container(),
//              preferredSize: Size(1.0, 1.0), // here the desired height
//            ),
            titleSpacing: 0.0,
            floating: false,
            // hackpadding bottom
            bottom: PreferredSize(
              preferredSize: Size(20.0, 65.0),
              child: Text(''),
            ),
            flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              var subtitleVisible = true;
              if (longTitle && constraints.biggest.height <= 150.0)
                subtitleVisible = false;

              // creo i widgets
              if (longTitle)
                widgets = [
                  SizedBox(
                    height: 28.0,
                  ),
                  Text(
                    firstHalfTitle,
                  ),
                  Text(
                    secondHalfTitle,
                  ),
                ];
              else
                widgets = <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    objective.title,
                    maxLines: 2,
                  ),
                ];

              widgets.add(Visibility(
                visible: subtitleVisible,
                child: Text(
                  objective.subtitle,
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ));

              var image;
              if (objective.photoPath != null) {
                image = Image.asset(
                  objective.photoPath,
                  fit: BoxFit.cover,
                );
              }
              return FlexibleSpaceBar(
                background: objective.photoPath == null
                    ? null
                    : Opacity(
                        opacity: 0.3,
                        child: image,
                      )
                /*Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          image,
                          Container(
                            height: image.height,
                            width: image.width,
                            child: Opacity(
                              opacity: 0.5,
                              child: Container(
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),*/
                ,
                title: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widgets,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(),
                    )
                  ],
                ),
              );
            }),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.build),
                tooltip: 'Debug features',
                onPressed: () async {
//                  _motivationalBloc
//                      .getPendingNotifications();

                  await _motivationalBloc.replanNotifications();
                  await _motivationalBloc.getPendingNotifications();
                  setState(() {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            duration: Duration(milliseconds: 100),
                            child: Container(
                              color: Colors.white,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    RaisedButton(
                                        child: Text("Delete DB"),
                                        onPressed: () async {
                                          // TODO wtf

                                          Navigator.pop(context);
                                          await _taskBloc.reInitAppDB();
                                          await _taskBloc.refreshUI();

                                          await _taskBloc.appBloc
                                              .checkFirstLaunch();

                                          await _taskBloc.refreshUI();
                                        }),
                                    RaisedButton(
                                        child: Text("Force UI update"),
                                        onPressed: () {
                                          _taskBloc.refreshUI();
                                          Navigator.pop(context);
                                        }),
                                    RaisedButton(
                                        child: Text("View Landing Page"),
                                        onPressed: () {
                                          Navigator.pop(context);

                                          _appBloc.startLandingPage();
                                        }),
                                    RaisedButton(
                                      child: Text("+1 day"),
                                      onPressed: () async {
                                        await _taskBloc.moveAllDaysBackByOne();

                                        await _motivationalBloc
                                            .scheduleExistingNotifications();

                                        await _motivationalBloc
                                            .getPendingNotifications();
                                      },
                                    ),
                                    RaisedButton(
                                      child: Text("Replan notifications"),
                                      onPressed: () async {
                                        await _motivationalBloc
                                            .replanNotifications();
                                        await _motivationalBloc
                                            .getPendingNotifications();
                                      },
                                    ),

                                    /*
                                    RaisedButton(
                                      child: Text("Show notification in 5s"),
                                      onPressed: () async {
                                        var noti =
                                            _appBloc.motivationalBloc.noti;
                                        var scheduledNotificationDateTime =
                                            new DateTime.now()
                                                .add(new Duration(seconds: 5));
                                        var androidPlatformChannelSpecifics =
                                            new AndroidNotificationDetails(
                                                'low no vibration channel',
                                                'low no vibration channel name',
                                                'low no vibration channel desc',
                                                priority: Priority.Low);
                                        var iOSPlatformChannelSpecifics =
                                            new IOSNotificationDetails();
                                        NotificationDetails
                                            platformChannelSpecifics =
                                            new NotificationDetails(
                                                androidPlatformChannelSpecifics,
                                                iOSPlatformChannelSpecifics);
                                        await noti.schedule(
                                            0,
                                            'scheduled title',
                                            'scheduled body',
                                            scheduledNotificationDateTime,
                                            platformChannelSpecifics,
                                            androidAllowWhileIdle: true);
                                      },
                                    ),
                                    */
                                    pendingNotifications,
                                  ],
                                ),
                              ),
                            )));
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit title',
                onPressed: () {
                  print('Edit!');
                  TextEditingController controller = TextEditingController();
                  TextFieldAlertDialog d = TextFieldAlertDialog(
                      startDate: objective.predictedCompletionDate,
                      objTitle: objective.title,
                      startColor: objective.color,
                      controller: controller,
                      notificationEnabled: objective.notificationEnabled);

                  controller.addListener(() {
                    if (d.finished) {
                      //  print("aggiorno titolo");
                      if (objective.predictedCompletionDate != d.selectedDate) {
                        objective.predictedCompletionDate = d.selectedDate;
                        objective.hasUserSelectedDate = true;
                      }
                      if (objective.color != d.selectedColor) {
                        objective.color = d.selectedColor;
                        bgAppBarColor = objective.color;
                      }

                      if (controller.text != "") {
                        objective.title = controller.text;
                        if (objective.title != "Create your new objective" ||
                            objective.title != "Complete the tutorial")
                          objective.subtitle = "";
                      }
                      _taskBloc.updateObjective(objective);
                    }
                  });
                  d.displayDialog(context);
                },
              ),
              Visibility(
                visible: false, //objective.photoPath != null,
                child: IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share',
                  onPressed: () async {
                    print('Share');
                    if (objective.photoPath != null) {
                      final ByteData bytes1 =
                          await rootBundle.load(objective.photoPath);
                      await Share.file('Share to a friend', 'file.png',
                          bytes1.buffer.asUint8List(), '*/*',
                          text:
                              "I'm working hard to ${objective.title.toLowerCase()}! 💪 You can use Moti to improve yourself, too 😉: play.google.com/MotiApp");
                    }
                    //_taskBloc.appBloc.checkFirstLaunch();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.photo_camera),
                tooltip: 'Take a photo',
                onPressed: () async {
                  print('Photo!');

                  final cameras = await availableCameras();
                  final firstCamera = cameras.first;

                  Objective objective = await _taskBloc.getCurrentObjective();

                  setState(() {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                            child: TakePictureScreen(
                              camera: firstCamera,
                              objective: objective,
                            )));
                  });
                },
              ),
            ]);
      },
    );

    return Stack(
      children: [
        // Main View!
        Container(
            child: Card(
          child: Container(
              decoration: BoxDecoration(
                  gradient: RadialGradient(
                      center: Alignment(0.0, 1.1),
                      radius: 0.9,
                      stops: [
                    0,
                    1
                  ],
                      colors: [
                    Colors.white,
                    Colors.grey[200],

//                            TinyColor(Theme.of(context).primaryColor)
//                                .lighten(20).saturate(20)
//                                .color
                  ])),
              child: CustomScrollView(slivers: <Widget>[
                sliverAppBarStream,
                completedStream,
                toCompleteStream,
                motivationalStream,
                imDoneButton,
                SliverList(
                    delegate: SliverChildListDelegate([
                  Container(
                    height: 75,
                  ),
                ])),
                // padding, sostanzialmente
              ])),
        )),

        // swipe-up stuff

        AnimatedBuilder(
            animation: _acBounce,
            builder: (_, child) {
              return Positioned(
                bottom:
                    _animationBounceValue.value * (_bounces == 0 ? 20 : 15) -
                        40,
                left: 10.0,
                right: 10.0,
                child: Card(
                  elevation: 8.0,
                  //color: Colors.lightBlue[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),

                  child: InkWell(
                    splashColor: Theme.of(context).primaryColor.withAlpha(30),
                    onTap: () {
                      setState(() {
                        widget.controller.animateToPage(1,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber[50],
                            //TinyColor(bgAppBarColor).desaturate(30).lighten(55).color,
                            // Colors.lightBlue[100],
                          ],
                          stops: [
                            0.5,
                            //  0.8,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(7.0),
                            // child: Icon(Icons.add_circle_outline, size:30.0)
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text("Swipe up to create a new task",
                                style: TextStyle(color: Colors.black87)),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(Icons.keyboard_arrow_up, size: 20.0)),
                          SizedBox(
                            height: 35.0,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        // stars
        Positioned(
          bottom: 80.0,
          right: -10.0,
          child: Opacity(
            opacity: _slideOpen ? 0.25 : 1,
            child: IgnorePointer(
              ignoring: _slideOpen,
              child: Card(
                elevation: 2.0,
                color: Colors.yellow[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Tooltip(
                  message: "Stars",
                  child: InkWell(
                    splashColor: Theme.of(context).primaryColor.withAlpha(30),
                    onTap: () {
                      if (!_slideOpen) {
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Stars(bloc: _appBloc)),
                          );
                        });
                      }
                    },
                    child: Container(
//                decoration: BoxDecoration(
//                  gradient: LinearGradient(
//                    colors: [
//                      Colors.blueAccent[800],
//                      // Colors.lightBlue[100],
//                    ],
//                    stops: [
//                      0.5,
//                      //  0.8,
//                    ],
//                    begin: Alignment.topCenter,
//                    end: Alignment.bottomCenter,
//                  ),
//                  borderRadius: BorderRadius.circular(16.0),
//                ),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: <Widget>[
                                StreamBuilder(
                                  stream: BlocProvider.of<AppBloc>(context)
                                      .taskBloc
                                      .totalStars,
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      String output = snapshot.data.toString();
                                      return Text(
                                        output,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0),
                                      );
                                    } else {
                                      return SizedBox(
                                          height: 16.0,
                                          width: 16.0,
                                          child: CircularProgressIndicator());
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
//                    Padding(
//                        padding: const EdgeInsets.all(5.0),
//                        child: Icon(Icons.keyboard_arrow_up, size: 20.0)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
//
//        // history
//        Positioned(
//          bottom: 130.0,
//          right: -10.0,
//          child: Opacity(
//            opacity: _slideOpen ? 0.25 : 1,
//            child: Card(
//              color: Colors.blue[800],
//
//              elevation: 2.0,
//              //color: Colors.lightBlue[100],
//              shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.circular(8.0),
//              ),
//
//              child: InkWell(
//                splashColor: Colors.blue.withAlpha(30),
//                onTap: () {
//                  setState(() {
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(builder: (context) => History()),
//                    );
//                  });
//                },
//                child: Container(
////                decoration: BoxDecoration(
////                  gradient: LinearGradient(
////                    colors: [
////                      Colors.white,
////                      // Colors.lightBlue[100],
////                    ],
////                    stops: [
////                      0.5,
////                      //  0.8,
////                    ],
////                    begin: Alignment.topCenter,
////                    end: Alignment.bottomCenter,
////                  ),
////                  borderRadius: BorderRadius.circular(16.0),
////                ),
//                  child: Column(
//                    children: <Widget>[
//                      Padding(
//                        padding: const EdgeInsets.all(4.0),
//                        child: Row(
//                          children: <Widget>[
////                            Padding(
////                              padding: const EdgeInsets.only(left: 8.0, right: 4.0),
////                              child: Text("37", style: TextStyle(color: Colors.white)),
////                            ),
//                            Padding(
//                              padding:
//                                  const EdgeInsets.only(right: 4.0),
//                              child: Icon(Icons.book, color: Colors.white),
//                            )
//                          ],
//                        ),
//                      ),
//                      Padding(
//                        padding: const EdgeInsets.only(bottom: 10.0),
//                        child: Text("Stories", style: TextStyle(color: Colors.white)),
//                      )
////                    Padding(
////                        padding: const EdgeInsets.all(5.0),
////                        child: Icon(Icons.keyboard_arrow_up, size: 20.0)),
//                    ],
//                  ),
//                ),
//              ),
//            ),
//          ),
//        ),

        Positioned(
          bottom: 130.0,
          right: -10.0,
          child: Opacity(
            opacity: _slideOpen ? 0.25 : 1,
            child: IgnorePointer(
              ignoring: _slideOpen,
              child: Card(
                elevation: 2.0,
                color: Colors.blue[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Tooltip(
                  message: "Stories",
                  child: InkWell(
                    splashColor: Theme.of(context).primaryColor.withAlpha(30),
                    onTap: () {
                      setState(() {
                        if (!_slideOpen) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => History(
                                      bloc: _appBloc,
                                    )),
                          );
                        }
                      });
                    },
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: <Widget>[
                                //Text("", style: TextStyle(color: Colors.white)),
                                Row(
                                  children: <Widget>[
                                    StreamBuilder(
                                      stream: _taskBloc.totalStories,
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.hasData) {
                                          return Text(snapshot.data.toString(),
                                              style: TextStyle(
                                                  color: Colors.white));
                                        } else {
                                          return SizedBox(
                                              height: 16.0,
                                              width: 16.0,
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      },
                                    ),

//                                  Text("4",
//                                      style: TextStyle(color: Colors.white)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0),
                                      child:
                                          Icon(Icons.book, color: Colors.white),
                                    )
//                                  Text(
//                                    "Stories",
//                                    style: TextStyle(color: Colors.white, fontSize: 12.0),
//                                  )
                                  ],
                                ),
                              ],
                            ),
                          ),
//                    Padding(
//                        padding: const EdgeInsets.all(5.0),
//                        child: Icon(Icons.keyboard_arrow_up, size: 20.0)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // stats
        Positioned(
          bottom: 180.0,
          right: -10.0,
          child: Opacity(
            opacity: _slideOpen ? 0.25 : 1,
            child: IgnorePointer(
              ignoring: _slideOpen,
              child: Card(
                elevation: 2.0,
                color: Colors.purple[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Tooltip(
                  message: "Statistics",
                  child: InkWell(
                    splashColor: Theme.of(context).primaryColor.withAlpha(30),
                    onTap: () async {
                      // await fullscreenTooltip(context, 300, 400, 80, "Tutte cose", "Molte altre cose molto utili");
                      setState(() {
                        if (!_slideOpen) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Stats(
                                      bloc: _appBloc,
                                    )),
                          );
                        }
                      });
                    },
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: <Widget>[
                                //Text("", style: TextStyle(color: Colors.white)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0),
                                  child: Column(
                                    children: <Widget>[
                                      Icon(
                                        Icons.equalizer,
                                        color: Colors.white,
                                      ),
//                                  Text(
//                                    "Stats",
//                                    style: TextStyle(color: Colors.white),
//                                  )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
//                    Padding(
//                        padding: const EdgeInsets.all(5.0),
//                        child: Icon(Icons.keyboard_arrow_up, size: 20.0)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // overlayStream,
      ],
    );
  }
}

Widget _createProgressBar(var context, var min, var max) {
  return new Stack(children: <Widget>[
    new Column(
      children: <Widget>[
        new Container(
          color: Colors.blueGrey,
          height: 10.0,
          width: MediaQuery.of(context).size.width,
        ),
        new Container(
          // elevation: 0.0,
          // color: Colors.white,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 0.0),

                  child: StreamBuilder(
                    stream:
                        BlocProvider.of<AppBloc>(context).taskBloc.dayStreak,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        String output = snapshot.data.toString();
                        return Column(
                          children: <Widget>[
                            Text(
                              output,
                              style: TextStyle(
                                  shadows: [
                                    Shadow(
                                      // bottomLeft
                                        offset: Offset(0.75, 0.75),
                                        color: Colors.black45),
                                  ],

                                  color: Colors.black87, fontSize: 24.0),
                            ),
                            Text(
                              output == '1' ? " day streak" : " days streak",
                              style: TextStyle(color: Colors.black54),
                              softWrap: true,
                            )
                          ],
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
//                  child: Column(
//                    children: <Widget>[
//                      Text(
//                        "8",
//                        style: TextStyle(color: Colors.black87, fontSize: 24.0),
//                      ),
//                      Text(
//                        " days streak",
//                        style: TextStyle(color: Colors.black54),
//                      )
//                    ],
//                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 0.0),
                  child: StreamBuilder(
                    stream:
                        BlocProvider.of<AppBloc>(context).taskBloc.totalTasks,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        String output = snapshot.data.toString();
                        return Column(
                          children: <Widget>[
                            Text(
                              output,
                              style: TextStyle(
                                  shadows: [
                                    Shadow(
                                      // bottomLeft
                                        offset: Offset(0.75, 0.75),
                                        color: Colors.black45),
                                  ],

                                  color: Colors.black87, fontSize: 24.0),
                            ),
                            Text(
                              output == '1'
                                  ? " task completed"
                                  : " tasks completed",
                              style: TextStyle(color: Colors.black54),
                              softWrap: true,
                            )
                          ],
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 0.0),
                  child: max == null
                      ? CircularProgressIndicator()
                      : Column(
                          children: <Widget>[
//
                            Text(
                              (max - min).toString() + "",
                              style: TextStyle(
                                  shadows: [
                                    Shadow(
                                        // bottomLeft
                                        offset: Offset(0.75, 0.75),
                                        color: Colors.black45),
                                  ],
                                  color: TinyColor(Colors.amber[700])
                                      .desaturate(5)
                                      .darken(5)
                                      .color,
                                  fontSize: 24.0),
                            ),
//
//                            Stack(
//                              children: <Widget>[
//                                // Stroked text as border.
//                                Text(
//                                  (max - min).toString() + "",
//                                  style: TextStyle(
//                                    fontSize: 24.0,
//                                    foreground: Paint()
//                                      ..style = PaintingStyle.stroke
//                                      ..strokeWidth = 1.5
//                                      ..color = Colors.black,
//                                  ),
//                                ),
//                                // Solid text as fill.
//                                Text(
//                                  (max - min).toString() + "",
//                                  style: TextStyle(
//                                    fontSize: 24.0,
//                                    color: Colors.amber[700],
//                                  ),
//                                ),
//                              ],
//                            )

                            Text(
                              (max - min) == 1 ? " item left" : "items left",
                              style: TextStyle(color: Colors.black54),
                              softWrap: true,
                            )
                          ],
                        ),
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
        new Card(
          color: Colors.blueGrey[400],
          elevation: 0.0,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 4.0,
                ),
                Text(
                  "Completed tasks ($min)",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    new Container(
        color: Colors.greenAccent,
        height: 10.0,
        width: MediaQuery.of(context)
                .size
                // coccoliamo l'utente e diamo un po' di barra verde all'inizio.
                .width *
            (min + 1) /
            ((max == null || max == 0 ? 1 : max) + 1))
  ]);
}

//
//    Column(
//      children: <Widget>[
//        new ListTile(
//          title: new Text("\t$min/$max done"),
//        ),
//        FractionallySizedBox(
//          widthFactor: min/max,
//          child:
//            Container(
//              height: 10.0, color: Colors.greenAccent,
//            ),
//        ),
//        FractionallySizedBox(
//          widthFactor: 1-min/max,
//          child:
//            Container()
//        )
//
//      ],
//    ),
