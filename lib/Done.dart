import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fluffy_bunny/NiceButton.dart';
import 'package:fluffy_bunny/Awesome.dart';
import 'package:fluffy_bunny/TakePictureScreen.dart';
import 'package:fluffy_bunny/TryAgain.dart';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/bloc/TaskBloc.dart';
import 'package:fluffy_bunny/db/model/Objective.dart';
import 'package:fluffy_bunny/db/model/UserFeeling.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:fluffy_bunny/HeroDialogRoute.dart';
import 'package:bezier_chart/bezier_chart.dart';

class Done extends StatefulWidget {
  final PageController controller;
  final AppBloc bloc;

  const Done({Key key, this.controller, this.bloc}) : super(key: key);

  @override
  createState() => new DoneState();
}

class DoneState extends State<Done> {
  PageController controller;
  TaskBloc _taskBloc;
  Objective objective;

  @override
  void initState() {
    super.initState();
    _taskBloc = widget.bloc.taskBloc;
    init();
  }

  init() async {
    var o = await _taskBloc.getCurrentObjective();
    setState(() {
      objective = o;
    });
  }

  String lessMoti;
  String lessAbi;
  List<String> lessMotiList;

  List<String> lessAbiList;

  @override
  Widget build(BuildContext context) {

    lessMoti = "Sometimes, your objectives could seem impossible to achieve."
        "\nYou may feel unmotivated and uninspired, unable to even start doing anything."
        "\nThese are some strategies you can use:"
       ;

    lessAbi = "Sometimes, your objectives could seem impossible to achieve."
        "\nYou may be unable to figure out what's the most appropriate way to do it."
        "\n\nThese are some strategies you can use:"
        ;

    lessMotiList = [
      "Find a way to make an activity pleasurable: you can give yourself a reward each time that you complete a task. 🍬",
      "Think why you want to do this: is there anything that will make your life better? 😊",
      "You do not need to complete your tasks alone: find a friend, even online. 😉",
      "What would it happen to you if you don't complete this? 😣",
    ];

    lessAbiList = [
      "Review your objective. What do you need to complete it? Prefer a precise objective instead of a vague one. 🎯",
      "Can you break down it in multiple activities? Write down what you need to do until you have a clear picture of your strategy. ♟",
      "Plan your actions: reserve some time to spend towards the completion of your objective. ⌚",
      "A calendar can be useful to have a clear picture of what is going on 📆"
    ];

    return Scaffold(
        body: Hero(
          tag: "done",
          child: Material(
            child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      TinyColor(Colors.blue[800])
                          .darken(30)
                          .color,
                      Colors.blue[800],
                    ],
                    stops: [0.0, 1.0],
                  ),
                ), child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Stack(children: [
                        Card(
                          color: objective != null && objective.color != null
                              ? TinyColor(objective.color)
                              .desaturate(20)
                              .lighten(10)
                              .color
                              : Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: objective != null &&
                              objective.photoPath != null
                              ? ClipRRect(

                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.asset(
                                objective.photoPath,
                                height: 300,
                                width: 300,
                                fit: BoxFit.cover,
                              ))
                              : Container(
                            // TODO: if missing photo, let user take photo.
                              height: 300,
                              width: 300,
                              child: Center(child:
                              Text("Take a photo!", style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 20.0)),
                              )
                          ),
                        ),
                        Positioned(
                          child: CircleAvatar(
                            backgroundColor: Colors.yellow[800],
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                              ),
                              tooltip: 'Take a photo',
                              onPressed: () async {
                                final cameras = await availableCameras();
                                final firstCamera = cameras.first;

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
                          ),
                          right: 12.0,
                          top: 12.0,
                        )
                      ])),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                      child: Text(
                        "Have you reached your objective?",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      )),
                ),
                InkWell(
                    splashColor: Theme
                        .of(context)
                        .primaryColor
                        .withAlpha(30),
                    onTap: () {
                      setState(() {
                        _taskBloc.completeCurrentObjective();
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                duration: Duration(milliseconds: 200),
                                child: Awesome()));
                      });
                    },
                    child: NiceButton(
                        text: "I DID IT!",
                        textColor: Colors.white,
                        fillColor: Colors.green)),
                InkWell(
                  splashColor: Theme
                      .of(context)
                      .primaryColor
                      .withAlpha(30),
                  onTap: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  child: NiceButton(
                    text: "NOT YET...",
                    textColor: Colors.blue,
                  ),
                ),
                InkWell(
                  splashColor: Theme
                      .of(context)
                      .primaryColor
                      .withAlpha(30),
                  onTap: () async {
                    UserFeeling uf = await widget.bloc.statBloc
                        .getCurrentUserFeeling();
                    setState(() {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              duration: Duration(milliseconds: 200),
                              child: TryAgain(
                                text: uf.motivation >= uf.ability
                                    ? lessAbi
                                    : lessMoti,
                                textList: uf.motivation >= uf.ability ? lessAbiList : lessMotiList,
                                bloc: widget.bloc,
                                controller: controller,
                              )));
                    });
                  },
                  child: NiceButton(text: "I'LL TRY SOMETHING ELSE..."),
                ),
                SizedBox(
                  height: 24.0,
                )
              ],
            )),
          ),
        ));
  }
}

