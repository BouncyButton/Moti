import 'dart:async';

import 'package:fluffy_bunny/StoryObjective.dart';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/model/Objective.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluffy_bunny/db/model/Task.dart';
import 'package:fluffy_bunny/FlutterEmoji.dart';
import 'package:fluffy_bunny/db/bloc/TaskBloc.dart';
import 'package:tinycolor/tinycolor.dart';

class TaskCard extends StatefulWidget {
  final int index;
  final SlidableController sc;
  final list;
  final Task task;
  final bool mock;

  TaskCardState state;

  TaskCard(
      {Key key, this.index, this.sc, this.list, this.task, this.mock = false})
      : super(key: key);

  get getSlidableState => sc.activeState;

  suggest() {}

  @override
  TaskCardState createState() {
    state = new TaskCardState(mock: this.mock);
    return state;
  }
}

class TaskCardState extends State<TaskCard> with TickerProviderStateMixin {
  TaskBloc _taskBloc;

  GlobalKey _key = GlobalKey();
  bool isBeingDeleted = false;
  bool isBeingCompleted = false;
  bool animationCompleted = false;

  bool mock = false;
  bool solved = false;
  AnimationController _ac;
  Animation<double> _animation;
  AnimationController acBounce;
  Animation<double> _animationBounceValue;

  @override
  void initState() {
    super.initState();
    if (this.mock) {
      _taskBloc = TaskBloc();

    }
    else
      _taskBloc = BlocProvider.of<AppBloc>(context).taskBloc;
  }

  TaskCardState({mock = false}) {
    // print(widget.task.emoji + " Creo task " + widget.task.title);

    _ac = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    _animation = CurvedAnimation(parent: _ac, curve: Curves.easeIn);

    _ac.addListener(_animationListener);

    acBounce = new AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);

    _animationBounceValue =
        CurvedAnimation(parent: acBounce, curve: Curves.decelerate);
    acBounce.addListener(() {
      if (_animationBounceValue.isCompleted) acBounce.reverse();
    });

    this.mock = mock;
    // _ac.forward();
  }

  @override
  void dispose() {
    print("Resetto controller bounce");

    acBounce.reset();
    acBounce.dispose();
    super.dispose();
  }

  void _animationListener() {
    // aggiorna il valore di altezza
//    if (this.mounted) {
//      setState(() {});
//    }
    // se ho completato
    if (_animation.isCompleted) {
      print("animazione finita");

      if (isBeingCompleted) {
        // completo il task
        if (!mock) _taskBloc.inCompleteNote.add(widget.task);
      } else {
        // cancello il task tramite il bloc
        if (!mock) _taskBloc.inDeleteTask.add(widget.task);
      }
      // ricevo dallo stream in output la notifica che è stato cancellato.
      _taskBloc.deleted.listen((deleted) {
        if (deleted) {
          _taskBloc.getTasks();
          if (this.mounted) {
            /// se avessi messo il setState si sarebbe triggerato il build e
            /// avrebbe dato un fastidioso effetto "flicker" dove alla fine
            /// dell'animazione la card ritornava per un frame.

            isBeingDeleted = false;
            isBeingCompleted = false;
          }
        }
      });
    }
  }

  void removeListener() {
    _ac.removeListener(_animationListener);
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    if (isBeingDeleted) {
      _ac.reset();
      _ac.forward();
    }
    // jump();
//    if(widget.task.title == 'Drink a glass of water') {
//      const oneSec = const Duration(seconds: 2);
//      new Timer.periodic(oneSec, (Timer t) {
//        if (mounted)
//          setState(() {});
//        else
//          t.cancel();
//      });
//    }
    super.didUpdateWidget(oldWidget);
  }

  doAsyncStuffForSuggestions() async {
    if ((await _taskBloc.getCurrentObjective()).isTutorial &&
        widget.index == 0) {
      Future.delayed(
          Duration(
            milliseconds: 1500,
          ), () async {
        if (mounted) await acBounce.forward();
      });
    }
  }

  jump() async {
    if (!mounted) return;
    if (widget.task.title == 'Drink a glass of water' &&
        (widget.sc.isSlideOpen == null || !widget.sc.isSlideOpen) &&
        widget.task.subtitle == 'You should drink 8 glasses a day.') {
      acBounce.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 3500)).then((_) async {
          if (!mounted) {
            return;
          }
          if ((await _taskBloc.getCurrentObjective()).isTutorial &&
              widget.index == 0) jump();
        });
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: () async {
        print("tapped card ${widget.task.title}");

        // TODO importare libreria e usare fix https://stackoverflow.com/questions/47296617/how-to-modify-plugins-dart-code-flutter
        //if(!widget.sc.isSlideOpen)

        if ((await _taskBloc.getCurrentObjective()).isTutorial)
          acBounce.forward();
      },
      child: Tooltip(
        message: "Swipe to the left and right",
        child: new Card(
          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0),side: BorderSide(color: widget.task.color)),
          color: Colors.greenAccent,
          child: AnimatedBuilder(
              animation: acBounce,
              builder: (_, child) {
                return Padding(
                  padding:
                      EdgeInsets.only(left: _animationBounceValue.value * 35),
                  child: new Slidable(
                    controller: widget.sc,
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.4,
                    showAllActionsThreshold: 0.5,
                    child: AnimatedBuilder(
                        animation: _ac,
                        builder: (_, child) {
                          return isBeingDeleted
                              ? new Container(
                                  height: isBeingDeleted
                                      ? (75 * (1 - _animation.value))
                                      : 75,
                                  color: isBeingCompleted
                                      ? Colors.greenAccent
                                      : Colors.red,
                                )
                              : new Container(
                                  color: Colors.white,
                                  // height: 75 * (1 - _animation.value),
                                  // ho bisogno di row/expanded per non fargli fare overflow.
//                            decoration: BoxDecoration(
//                              gradient: LinearGradient(
//                                  begin: Alignment.topCenter,
//                                  end: Alignment.bottomCenter,
//                                  colors: [
//                                    TinyColor(widget.task.color).lighten(35).desaturate(13).color,
//                                    TinyColor(widget.task.color).lighten(22).color,
//                              ],
//                              stops: [0.5,1])
//                            ),
                                  child: new ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 0.0),
                                    leading: _getLeadingIcon(widget.task),
                                    title: Wrap(
                                      direction: Axis.horizontal,
                                      children: <Widget>[
                                        Padding(
                                          //padding: const EdgeInsets.all(8.0),
                                          padding:
                                              const EdgeInsets.only(top: 1.3),

                                          child: Text(
                                              widget.task.repetition == 'daily'
                                                  ? "(Daily) "
                                                  : widget.task.repetition ==
                                                          'weekly'
                                                      ? "(Weekly) "
                                                      : "",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black54,
                                                  fontSize: 14.0)),
                                        ),
                                        Text(
                                          widget.task.title,
                                          softWrap: true,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.2,
                                              fontSize: 16.0,
                                              color: Color(0xff232F34)),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 1.3),
                                          child: Text(
                                              " — ${widget.task.completed > 0 ? "completed " + formatDate(widget.task.completedDateSinceEpoch, capitalized: false) : "" + formatDate(widget.task.creationDateSinceEpoch, capitalized: false)}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black54,
                                                  fontSize: 14.0)),
                                        )
                                      ],
                                    ),
                                    subtitle: widget.task.repetition !=
                                                    'once' &&
                                                widget.task.completed >= 1 ||
                                            widget.task.subtitle == ''
                                        ? null
                                        : new Text(
                                            widget.task.subtitle,
                                            softWrap: true,
                                          ),
                                  ),
                                );
                        }),
                    actions: <Widget>[
                      new IconSlideAction(
                        caption: 'Done',
                        color: Colors.greenAccent,
                        icon: Icons.check_circle_outline,
                        onTap: () => !mock
                            ? _completeTask(widget.list[widget.index])
                            : _completeTask(widget.task),
                      ),
                    ],
                    secondaryActions: <Widget>[
                      new IconSlideAction(
                        caption:
                            widget.task.completed >= 1 ? 'Archive' : 'Delete',
                        color: Colors.red,
                        icon: widget.task.completed >= 1
                            ? Icons.archive
                            : Icons.delete_forever,
                        onTap: () => !mock
                            ? _deleteTask(
                                widget.list[widget.index], widget.index)
                            : _deleteTask(widget.task, null),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  void _completeTask(Task task) async {
    setState(() {
      if (mock && task.repetition == 'once') {
        isBeingCompleted = true;
        isBeingDeleted = true;

        _ac.forward();
        solved = true;
        return;
      }
      if (task.repetition == 'once') {
        isBeingDeleted = true;
        isBeingCompleted = true;
        _ac.forward();
      } else {
        // _taskBloc.tooltipScreen(task);

        _taskBloc.inCompleteNote.add(widget.task);
        _taskBloc.getTasks();
      }
    });
  }

  void _deleteTask(Task task, int index) async {
    // Add the note id to the delete note stream. This triggers the function
    // we set in the listener.

    // Wait for `deleted` to be set before popping back to the main page. This guarantees there's no
    // mismatch between what's stored in the database and what's being displayed on the page.
    // This is usually only an issue with more database heavy actions, but it's a good thing to
    // add regardless.

    print(widget.task.emoji +
        " Cancello task " +
        widget.task.title +
        " index: " +
        index.toString());

    setState(() {
      isBeingDeleted = true;
    });

    _ac.forward();

//
//    try {
//      await Future.delayed(Duration(milliseconds: 500), () {
//        _ac.addListener(_animationListener);
//
//        _ac.forward().orCancel.whenComplete(() {
//          // non penso sia il modo corretto per farlo. però funzionicchia. speriamo bene.
//          // _ac.removeListener(_animationListener);
//          _taskBloc.inDeleteTask.add(task);
//          _taskBloc.deleted.listen((deleted) {
//            if (deleted) {
//              _taskBloc.getTasks();
//            }
//          });
//          // _ac.addListener(_animationListener);
//          // _ac.dispose();
//          // dispose();
//        });
//      });
//    } on TickerCanceled {
//      print("tickerCanceled");
//    }
  }
}

Widget _getLeadingIcon(Task task) {
  //if (repetition == "daily" || repetition == 'weekly') {

  if (task.emoji == '') {
    List<String> words = task.title.split(" ");

    var parser = EmojiParser();

    parser.addEmojiAssociation("plank", "💪");
    parser.addEmojiAssociation("jogging", "🏃‍");
    parser.addEmojiAssociation("walk", "🚶‍");
    parser.addEmojiAssociation("gardening", "🌼");
    parser.addEmojiAssociation("study", "📚");
    parser.addEmojiAssociation("exercise", "🏋️");
    parser.addEmojiAssociation("craft", "🎁");
    parser.addEmojiAssociation("relax", "🧘‍");
    parser.addEmojiAssociation("bike", "🚴‍");
    parser.addEmojiAssociation("dance", "💃");
    parser.addEmojiAssociation("draw", "🖍");
    parser.addEmojiAssociation("drawing", "🖼");
    parser.addEmojiAssociation("origami", "🙌");
    parser.addEmojiAssociation("buy", "💰");
    parser.addEmojiAssociation("butterfly", "🦋");
    parser.addEmojiAssociation("flexagon", "💠");
    parser.addEmojiAssociation("crane", "🦢");
    parser.addEmojiAssociation("avocado", "🥑");
    parser.addEmojiAssociation("bean", "🌱");
//    parser.addEmojiAssociation("learn", "👩‍");
//    parser.addEmojiAssociation("plank", "💪");
//    parser.addEmojiAssociation("plank", "💪");
//    parser.addEmojiAssociation("plank", "💪");

    for (String word in words) {
      if (word.length > 1 && parser.hasName(word.toLowerCase())) {
        task.emoji = parser.get(word.toLowerCase()).code;
        break;
      }
    }
  }

  bool shouldRemember = false;

  if (task.repetition == 'daily' &&
      task.completed == 0 &&
      DateTime.now().difference(task.creationDateSinceEpoch).inDays > 0)
    shouldRemember = true;

  if (task.repetition == 'daily' &&
      task.completed != 0 &&
      DateTime.now().difference(task.completedDateSinceEpoch).inDays > 0)
    shouldRemember = true;

  if (task.repetition == 'weekly' &&
      task.completed == 0 &&
      DateTime.now().difference(task.creationDateSinceEpoch).inDays > 6)
    shouldRemember = true;

  if (task.repetition == 'weekly' &&
      task.completed != 0 &&
      DateTime.now().difference(task.completedDateSinceEpoch).inDays > 6)
    shouldRemember = true;

  if (task.title == 'Drink a glass of water' &&
      task.subtitle == 'You should drink 8 glasses a day.') {
    shouldRemember = true;
  }

  return Stack(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),

        child: CircleAvatar(
          backgroundColor: _getLighterColor(task.color),
          //Color.fromRGBO(255, 255, 255, 0.5),
          child: new Text(task.emoji),
          foregroundColor: Colors.black87,
        ),

//          child: CircleAvatar(
//            backgroundColor: _getLighterColor(color), //Color.fromRGBO(255, 255, 255, 0.5),
//            child: Padding(
//              padding: const EdgeInsets.all(3.0),
//              child: Column(
//                children: <Widget>[
//                  new Text(
//                    centerText,
//                    style: TextStyle(color: Colors.black87),
//                  ),
//                  new Text(
//                    centerText == "1" ? "time" : "times",
//                    style: TextStyle(fontSize: 10.0),
//                  ),
//                ],
//              ),
//            ),
//            foregroundColor: Colors.black87,
//          ),
      ),
//      Positioned(
//        bottom: 0.0,
//        right: 0.0,
//        child: Opacity(
//            opacity: repetition == 'once' ? 0 : 1,
//            child: Column(
//              children: <Widget>[
//                CircleAvatar(
//                  radius: 8.0,
//                  child: Icon(
//                    Icons.repeat,
//                    size: 12.0,
//                    color: Colors.black,
//                  ),
//                  backgroundColor: Colors.white,
//                ),
//                // Text(repetition),
//              ],
//            )),
//      ),
      Positioned(
        top: 0.0,
        left: 0.0,
        child: Opacity(
            opacity: task.completed == 0 ? 0 : 1,
            child: CircleAvatar(
              radius: 8.0,
              child: Text(
                task.completed.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12.0),
              ),
              backgroundColor: Colors.green,
            )),
      ),
      Positioned(
        top: 3.0,
        right: 5.0,
        child: Opacity(
            opacity: shouldRemember ? 1 : 0,
            child: CircleAvatar(
              radius: 6.0,
              child: Text(
                "!",
                style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w800),
              ),
              backgroundColor: Colors.red,
            )),
      ),
      Positioned(
        bottom: 0.0,
        left: 0.0,
        child: Opacity(
            opacity: 1,
            child: CircleAvatar(
              radius: 8.0,
              child: Icon(
                task.classification == 'remind'
                    ? Icons.alarm
                    : task.classification == 'learn'
                        ? Icons.timeline
                        : task.classification == 'stop'
                            ? Icons.not_interested
                            : null,
                size: 12.0,
                color: Colors.black,
              ),
              backgroundColor: Colors.white,
            )),
      ),
    ],
  );
  //}

  /*else if (repetition == "once") {
    return Container(
//      height: 50.0,
//      decoration: new BoxDecoration(
//        color: Colors.orange,
//        shape: BoxShape.circle,
//      ),
      child: CircleAvatar(

        backgroundColor: _getLighterColor(color), //Color.fromRGBO(255, 255, 255, 0.5),
        child: new Text(centerText),
        foregroundColor: Colors.black87,
      ),
    );

  }*/
}

Color _getLighterColor(Color color) {
  return TinyColor(color).lighten(35).saturate(20).color;
}
