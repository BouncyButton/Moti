import 'dart:math';

import 'package:fluffy_bunny/TaskCard.dart';
import 'package:fluffy_bunny/db/model/Task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

fullscreenTooltip(
  BuildContext context, {
  double w,
  double fromTop,
  double fromLeft,
  double fromRight,
  double fromBottom,
  String title,
  String subtitle,
  double topTitle,
  double leftTitle,
  double bottomTitle,
  bool animation = false,
  bool skippable = true,
  bool animationArchive = false,
}) async {
  return Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      //barrierDismissible: true,
      pageBuilder: (BuildContext context, _, __) {
        return AnimatedBGWidget(
          w: w,
          fromTop: fromTop,
          fromLeft: fromLeft,
          fromRight: fromRight,
          fromBottom: fromBottom,
          title: title,
          subtitle: subtitle,
          topTitle: topTitle,
          leftTitle: leftTitle,
          bottomTitle: bottomTitle,
          skippable: skippable,
          animation: animation,
          animationArchive: animationArchive,
        );
      }));
//        context: context,
//        builder: (BuildContext context) {
//          return Opacity(
//            opacity: 1,
//            child: Padding(
//              padding: const EdgeInsets.all(5.0),
//              child: Stack(
//                children: <Widget>[
//                  Positioned(
//                    top: -100.0,
//                    left: -100.0,
//                    child: Card(
//                      color: Colors.transparent,
//                      shape: CircleBorder(
//                          side: BorderSide(width: 250.0, color: Colors.blue)),
//                      // shape: CircleBorder(),
//                      child: Padding(
//                        padding: const EdgeInsets.all(400.0),
//                        child: Container(
//                          child: Text("slkjdhfdfgdfgdfgdfgdfgdfgdfgdfg"),
//                        ),
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//            ),
//          );
//        });
//
//    await showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return Container(
//            color: Theme.of(context).primaryColor,
//            child: Center(child: Text("secondo")),
//          );
//        });
}

class AnimatedBGWidget extends StatefulWidget {
  var w;
  var fromTop;
  var title;
  var fromLeft;
  var topTitle;
  var leftTitle;
  var skippable;
  var subtitle;
  var fromRight;
  var fromBottom;
  var bottomTitle;
  var animation;
  var animationArchive;

  AnimatedBGWidget(
      {this.w,
      this.fromTop,
      this.fromLeft,
      this.fromRight,
      this.fromBottom,
      this.title,
      this.subtitle,
      this.topTitle,
      this.leftTitle,
      this.bottomTitle,
      this.animation = false,
      this.animationArchive = false,
      this.skippable = true});

  _AnimatedBGState createState() => _AnimatedBGState(
      w: w,
      fromTop: fromTop,
      fromLeft: fromLeft,
      fromRight: fromRight,
      fromBottom: fromBottom,
      title: title,
      subtitle: subtitle,
      topTitle: topTitle,
      leftTitle: leftTitle,
      bottomTitle: bottomTitle,
      skippable: skippable,
      animation2: animation,
      animationArchive: animationArchive);
}

class _AnimatedBGState extends State<AnimatedBGWidget>
    with TickerProviderStateMixin {
  Animation<double> animation;
  AnimationController ctrl;

  var fromTop;
  var leftTitle;
  var subtitle;
  var w;
  var topTitle;
  var bottomTitle;
  var fromRight;
  var title;
  var fromLeft;
  var skippable;
  var fromBottom;
  var animation2;
  var animationArchive;
  static var oldLeft;
  static var oldRight = 0;
  static var oldTop;
  static var oldBottom = 0;
  SlidableController sc;
  SlidableState slidableState;

  _AnimatedBGState({
    this.w,
    this.fromTop,
    this.fromLeft,
    this.fromRight,
    this.fromBottom,
    this.title,
    this.subtitle,
    this.topTitle,
    this.leftTitle,
    this.bottomTitle,
    this.skippable = true,
    this.animation2 = false,
    this.animationArchive = false,
  });

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = CurvedAnimation(parent: ctrl, curve: Curves.easeIn);

    sc = SlidableController();
    //sc.activeState = SlidableState();
    //slidableState = SlidableState();
    //sc.activeState = slidableState;
//    WidgetsBinding.instance.addPostFrameCallback((_) {
//      if (animation2) {
//        print("provo ad APRIREEEE");
//        sc.activeState?.open();
//      }
//    });

    // controller.addListener(() {print(animation.value);} );
//      ..addStatusListener((status) {
//        if (status == AnimationStatus.completed) {
//          controller.reverse();
//        } else if (status == AnimationStatus.dismissed) {
//          controller.forward();
//        }
//      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => AnimatedBG(
      controller: ctrl,
      animation: animation,
      w: w,
      fromTop: fromTop,
      fromLeft: fromLeft,
      fromRight: fromRight,
      fromBottom: fromBottom,
      title: title,
      subtitle: subtitle,
      topTitle: topTitle,
      leftTitle: leftTitle,
      skippable: skippable,
      bottomTitle: bottomTitle,
      animation2: animation2,
      animationArchive: animationArchive,
      sc: sc);

  @override
  void dispose() {
    ctrl.dispose();

    super.dispose();
  }
}

class AnimatedBG extends AnimatedWidget {
  // static final _opacityTween = Tween<double>(begin: 0.5, end: 1);
  Tween<double> _sizeTween;

  //double width2;
  double fromTop;
  double fromLeft;
  double fromRight;
  double fromBottom;
  String title;
  String subtitle;
  double topTitle;
  double bottomTitle;
  double leftTitle;
  bool skippable;

  var width;
  static const factor = 20;
  static const double borderPercentage = (1 - 1 / factor);
  double padding;

  AnimationController controller;
  SlidableController sc;

  bool animation2;
  bool animationArchive;
  TaskCard mockCard;

  AnimatedBG(
      {Key key,
      Animation<double> animation,
      double w,
      double fromTop,
      double fromLeft,
      double fromRight,
      double fromBottom,
      double bottomTitle,
      String title,
      String subtitle,
      double topTitle,
      double leftTitle,
      double startTween,
      double endTween,
      SlidableController sc,
      bool skippable = true,
      bool animation2 = false,
        bool animationArchive = false,
      AnimationController controller})
      : super(key: key, listenable: animation) {
    this.width = w;
    //this.width2 = w;
    this.fromBottom = fromBottom;
    this.fromLeft = fromLeft;
    this.fromRight = fromRight;
    this.fromTop = fromTop;
    this.title = title;
    this.subtitle = subtitle;
    this.skippable = skippable;
    this.topTitle = topTitle;
    this.bottomTitle = bottomTitle;
    this.leftTitle = leftTitle;
    this.controller = controller;
    this.animation2 = animation2;
    this.animationArchive = animationArchive;
    this.sc = sc;
    padding = width * factor;

    _sizeTween = Tween<double>(begin: 0.99, end: 1);
//    _leftTween = Tween<double>(begin: oldLeft, end: fromLeft);
//    _rightTween = Tween<double>(begin: oldLeft, end: fromLeft);
//    _topTween = Tween<double>(begin: oldLeft, end: fromLeft);
//    _bottomTween = Tween<double>(begin: oldLeft, end: fromLeft);
    controller.forward();
  }

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;

    TaskCard mockCard = TaskCard(
      sc: sc,
      mock: true,
      task: Task(
        title: "Run outside 👉",
        emoji: "🏃‍",
        completed: 0,
        color: Colors.blue,
        repetition: 'once',
        creationDateSinceEpoch: DateTime.now(),
      ),
    );
    TaskCard mockCardArchive = TaskCard(
      sc: sc,
      mock: true,
      task: Task(
        title: "Empty a bottle of water 👈",
        emoji: "💧",
        completed: 3,
        color: Colors.green,
        repetition: 'daily',
        creationDateSinceEpoch: DateTime.now(),
          completedDateSinceEpoch: DateTime.now(),
      ),
    );

    Future.delayed(
        Duration(
          milliseconds: 1000,
        ), () async {
      if (animation2 && mockCard != null && mockCard.state != null) {
        if (mockCard.state.mounted) await mockCard.state.acBounce.forward();
        //await mockCard.state.acBounce.forward();
      }

      // mockCardArchive.state.acBounce.reverse();

    });

    return GestureDetector(
      onTap: () async {
        Navigator.pop(context, 'continue');
      },
      child: Opacity(
        opacity: 1,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: fromTop == null ? null : -padding + fromTop,
                left: fromLeft == null ? null : -padding + fromLeft,
                right: fromRight == null ? null : -padding + fromRight,
                bottom: fromBottom == null ? null : -padding + fromBottom,
                child: Card(
                  color: Colors.transparent,
                  shape: CircleBorder(
                      // cresce verso l'interno!
                      side: BorderSide(
                          width: (padding *
                                  borderPercentage *
                                  _sizeTween.evaluate(animation))
                              .truncateToDouble() /*(pow((animation.value), 1/10))*/,
                          color: Colors.blue)),
                  // shape: CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Container(
                      child: Text(""),
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: topTitle,
                  left: 0,
                  bottom: bottomTitle,
                  child: Visibility(
                    visible: true, //animation.isCompleted,
                    child: Material(
                        color: Colors.blue,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.82,
                            child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                color: Colors.blue[800],
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        title,
                                        softWrap: true,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 32.0,
                                            fontWeight: FontWeight.w200),
                                      ),
                                      SizedBox(height: 10.0),
                                      Text(
                                        subtitle,
                                        softWrap: true,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        )),
                  )),
              Positioned(
                  bottom: MediaQuery.of(context).size.height / 3.0,
                  child: Visibility(
                    visible: animation2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Material(
                          child: Container(
                        height: 65.0,
                        width: MediaQuery.of(context).size.width - 16.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                  bottom: 10.0,
                                  left:
                                      MediaQuery.of(context).size.width / 2.0 -
                                          28.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "😊",
                                      style: TextStyle(fontSize: 24.0),
                                    ),
                                  )),
                              mockCard,
                            ],
                          ),
                        ),
                      )),
                    ),
                  )),
              Positioned(
                  top: MediaQuery.of(context).size.height / 2.5,
                  child: Visibility(
                    visible: animationArchive,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Material(
                          child: Container(
                        height: 65.0,
                        width: MediaQuery.of(context).size.width - 16.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                  bottom: 10.0,
                                  left:
                                      MediaQuery.of(context).size.width / 2.0 -
                                          28.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "😊",
                                      style: TextStyle(fontSize: 24.0),
                                    ),
                                  )),
                              mockCardArchive,
                            ],
                          ),
                        ),
                      )),
                    ),
                  )),
              Positioned(
                  bottom: 0,
                  width: MediaQuery.of(context).size.width,
                  child: Visibility(
                    visible: true, //animation.isCompleted,
                    child: Material(
                        color: Colors.blue[800],
                        child: Card(
                          elevation: 0,
                          shape: Border(),
                          color: Colors.blue[800],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "Tap anywhere to continue",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        )),
                  )),
              !skippable
                  ? Positioned(child: Container())
                  : Positioned(
                      top: 40,
                      right: 20,
                      child: Visibility(
                        visible: true, //animation.isCompleted,
                        child: Material(
                            color: Colors.blue,
                            child: GestureDetector(
                              onTap: () {
                                print("skipped");
                                Navigator.pop(context, 'skip');
                              },
                              child: Card(
                                elevation: 5,
                                //shape: Border(),
                                color: Colors.blue,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    "Skip",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16.0),
                                  ),
                                ),
                              ),
                            )),
                      ))
            ],
          ),
        ),
      ),
    );
  }
}
