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

class ChooseTutorialObjective extends StatefulWidget {
  final PageController controller;
  final AppBloc bloc;

  const ChooseTutorialObjective({Key key, this.controller, this.bloc})
      : super(key: key);

  @override
  createState() => new ChooseTutorialObjectiveState();
}

class ChooseTutorialObjectiveState extends State<ChooseTutorialObjective> {
  PageController controller;
  TaskBloc _taskBloc;
  Objective objective;
  String _objectiveChosen = 'unselected';

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(body: Builder(builder: (BuildContext context) {
        return Material(
          child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
//                TinyColor(Colors.blue[800]).darken(30).color,
                    Colors.blue,
                  ],
                  stops: [
                    //0.0,
                    1.0
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 40.0, horizontal: 16.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Container()),
                          GestureDetector(
                            onTap: () {
                              print("skipped");
                              Navigator.pop(context, 'skip');
                              _taskBloc.restartCurrentObjective();
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
                          ),
                        ],
                      ),
                    ),
                    Card(
                      color: Colors.blue[800],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "It's your turn now!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.w200),
                            ),
                            Text(

                              "Pick an objective, or press Skip to choose your own.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w200,),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        color: Colors.blue[800],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          children: <Widget>[
                            createObjectiveChoice("Learn to meditate",
                                "30 minutes", "meditate", "🧘"),
//                      createObjectiveChoice(
//                          "Make cookies", "30 minutes", "cookies", "🍪"),
                            createObjectiveChoice("Start exercising", "1 hour",
                                "exercise", "🏃‍"),
//                      createObjectiveChoice(
//                          "Plant an avocado tree", "30 days", "avocado", "🥑"),
//                          createObjectiveChoice(
//                              "Let me choose!", "?", "new", "💡"),
                          ],
                        ),
                      ),
                    ),
                    _objectiveChosen == 'unselected'
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: InkWell(
                                splashColor: Theme.of(context)
                                    .primaryColor
                                    .withAlpha(30),
                                onTap: () async {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Select an objective or press Skip"),
                                  ));

                                },
                                child: NiceButton(
                                    text: "LET'S DO THIS!",
                                    textColor: Colors.grey,
                                    fillColor: Colors.white)),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: InkWell(
                                splashColor: Theme.of(context)
                                    .primaryColor
                                    .withAlpha(30),
                                onTap: () async {
                                  // setState(() {
                                  await _taskBloc.setCurrentTutorialObjective(
                                      _objectiveChosen);
                                  Navigator.of(context).pop();
                                  // await _taskBloc.refreshUI();
                                  // });
                                },
                                child: NiceButton(
                                    text: "LET'S DO THIS!",
                                    textColor: Colors.white,
                                    fillColor: Colors.green)),
                          ),
                  ],
                ),
              )),
        );
      })),
    );
  }

  Widget createObjectiveChoice(
      String title, String subtitle, String obj, String emoji) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ChoiceChip(
        selected: _objectiveChosen == obj,
        onSelected: (bool selected) {
          setState(() {
            _objectiveChosen = obj;
          });
        },
        label: Column(
          children: <Widget>[
            SizedBox(
              height: 2.0,
            ),
            Text(emoji),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Text(title,
                  style: TextStyle(
                      color: TinyColor(Colors.blue[900]).darken(30).color,
                      fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Text(subtitle,
                  style: TextStyle(
                      color: TinyColor(Colors.blue[900]).darken(30).color,
                      fontWeight: FontWeight.w400)),
            ),
            SizedBox(
              height: 2.0,
            )
          ],
        ),
        selectedColor: TinyColor(Colors.green).lighten(30).color,
      ),
    );
  }
}
