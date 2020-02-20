import 'package:fluffy_bunny/AlertDialog.dart';
import 'package:fluffy_bunny/ChooseTutorialObjective.dart';
import 'package:fluffy_bunny/MotivationalController.dart';
import 'package:fluffy_bunny/NiceButton.dart';
import 'package:fluffy_bunny/TaskWidget.dart';
import 'package:fluffy_bunny/FullscreenTooltip.dart';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/bloc/MotivationBloc.dart';
import 'package:fluffy_bunny/db/model/Star.dart';
import 'package:fluffy_bunny/db/model/Stat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tinycolor/tinycolor.dart';
import 'todo.dart';
import 'TaskPage.dart';
import 'TaskAdder.dart';
import 'package:path/path.dart';
import 'package:fluffy_bunny/DotsIndicator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  PageController tutorialPageController =
      PageController(initialPage: 0, keepPage: false);
  PageController taskPageController = PageController(
    initialPage: 0,
    keepPage: false,
  );
  MotivationalController mc = MotivationalController();

  // CustomController overlayController = CustomController();

  @override
  createState() => new MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    // voglio solo portrait.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);


    var _appBloc = AppBloc();

    var tw = TaskWidget(
      controller: widget.taskPageController, /* bloc: _appBloc*/
    );
    var ta = TaskAdder(
      controller: widget.taskPageController, /* bloc: _appBloc*/
    );

    var initialStream = StreamBuilder<bool>(
      stream: _appBloc.landingPage,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data) {
            print('LANDING PAGE ============================================');

            return new PageView(
              // SERVE! Maledetto pagestorage...
              key: Key('LandingPage'),
              controller: widget.tutorialPageController,
              // scrollDirection: Axis.horizontal,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    widget.tutorialPageController.animateToPage(1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut);
                  },
                  child: Material(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                TinyColor(Colors.blue[800]).darken(30).color,
                                Colors.blue[800],
                              ],
                              stops: [0.45, 1.2],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28.0, vertical: 64.0),
                            child: Card(
                              elevation: 0.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(48.0)),
                              color: Color(0x44ffffff),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Center(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(top: 100.0),
                                      child: Text(
                                        "Moti",
                                        softWrap: true,
                                        //textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w200,
                                            color: Colors.white,
                                            fontSize: 54.0),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Text(
                                        "Improve your motivation\nto achieve your objectives",
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w200,
                                            color: Colors.white,
                                            fontSize: 18.0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 32.0),
                                  Row(
                                    children: <Widget>[
                                      Expanded(child: Container()),
                                      Center(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white70,
                                                  ),
                                                  SizedBox(width: 6.0),
                                                  Text(
                                                    "Choose an objective",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Colors.white,
                                                        fontSize: 14.0),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white70,
                                                  ),
                                                  SizedBox(width: 6.0),
                                                  Text(
                                                    "Find what you need to do",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Colors.white,
                                                        fontSize: 14.0),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white70,
                                                  ),
                                                  SizedBox(width: 6.0),
                                                  Text(
                                                    "Track your progress",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Colors.white,
                                                        fontSize: 14.0),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white70,
                                                  ),
                                                  SizedBox(width: 6.0),
                                                  Text(
                                                    "Personalize your own story",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Colors.white,
                                                        fontSize: 14.0),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Container()),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            width: MediaQuery.of(context).size.width,
                            child: Visibility(
                              visible: true, //animation.isCompleted,
                              child: Opacity(
                                opacity: 1.0,
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
                                            style: TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.tutorialPageController.animateToPage(2,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut);
                  },
                  child: Material(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue[800],
                            Colors.yellow[800],
                          ],
                          stops: [0.45, 1.2],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28.0, vertical: 64.0),
                        child: Card(
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(48.0)),
                          color: Color(0x44ffffff),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 100.0),
                                  child: Text(
                                    "How?",
                                    softWrap: true,
                                    //textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w200,
                                        color: Colors.white,
                                        fontSize: 54.0),
                                  ),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    "I'll help you 😉",
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w200,
                                        color: Colors.white,
                                        fontSize: 18.0),
                                  ),
                                ),
                              ),
                              SizedBox(height: 32.0),
                              Row(
                                children: <Widget>[
                                  Expanded(child: Container()),
                                  Center(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white70,
                                              ),
                                              SizedBox(width: 6.0),
                                              Text(
                                                "Useful tips & suggestions",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.white,
                                                    fontSize: 14.0),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white70,
                                              ),
                                              SizedBox(width: 6.0),
                                              Text(
                                                "Daily reminders tailored for you",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.white,
                                                    fontSize: 14.0),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white70,
                                              ),
                                              SizedBox(width: 6.0),
                                              Text(
                                                "Based on psychological techniques",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.white,
                                                    fontSize: 14.0),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white70,
                                              ),
                                              SizedBox(width: 6.0),
                                              Text(
                                                "Create your personal journal",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.white,
                                                    fontSize: 14.0),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white70,
                                              ),
                                              SizedBox(width: 6.0),
                                              Text(
                                                "Share your story",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.white,
                                                    fontSize: 14.0),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Material(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue[800],
                            Color(0xffa9d4f4),
                          ],
                          stops: [0.0, 1.0],
                        ),
                      ),

                      //color: Colors.blue,
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Text(
                                "Tutorial",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48.0,
                                    fontWeight: FontWeight.w200),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Text(
                                "Let's start!\nLet me guide you through this tutorial.",
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 28.0),
                              child: Text(
                                "Follow the instructions\nand complete your first story!",
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          Center(
                            child: InkWell(
                              splashColor:
                                  Theme.of(context).primaryColor.withAlpha(30),
                              child: NiceButton(
                                text: "I'M READY!",
                                textColor: Colors.blue,
                              ),
                              onTap: () async {
                                _appBloc.endLandingPage();
                                _appBloc.taskBloc.refreshUI();

                                await tutorialSequence(context);

                                // fare un setState qua è assolutamente sbagliato.
                                // setState(() {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 200),
                                        child: ChooseTutorialObjective(
                                          bloc: _appBloc,
                                        )));

//                                result = await fullscreenTooltip(context,
//                                    w: 2, fromTop: -100, fromLeft: -100, topTitle: 180,
//                                  title: "It's your turn now!",
//                                  subtitle: "Try to complete the first task! 🥤", skippable:  false
//                                );

                                // widget.controller.animateToPage(0, duration: Duration(milliseconds: 0), curve: Curves.easeOut);
                              },
                            ),
                          ),
                          SizedBox(height: 80.0),
                        ],
                      ),
                    ),
                  ),
                ),
                /*
                GestureDetector(
                  onTap: () {
                    tutorialPageController.animateToPage(1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut);
                  },
                  child: Material(
                    child: Container(
                      // width: MediaQuery.of(context).size.width,
                      color: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(64.0),
                              child: Text("Ciao!",
                                  style: TextStyle(
                                      fontSize: 24.0, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    tutorialPageController.animateToPage(2,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut);
                  },
                  child: Material(
                    child: Container(
                        // width: MediaQuery.of(context).size.width,
                        color: Colors.green,
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Ciao!",
                              style: TextStyle(
                                  fontSize: 24.0, color: Colors.white),
                            ),
                          ],
                        )),
                  ),
                ),
                GestureDetector(
                  onTap: () { },
                  child: Material(
                    child: Container(
                        // width: MediaQuery.of(context).size.width,
                        color: Colors.blue,
                        child: Center(
                            child: Column(
                          children: <Widget>[
                            Text("Ciao!",
                                style: TextStyle(
                                    fontSize: 24.0, color: Colors.white)),
                            NiceButton(
                              text: "FINE!",

                            )
                          ],
                        ))),
                  ),
                ),

                */
              ],
            );
            // return DotsIndicator();
          } else {
            // widget.controller = PageController(initialPage: 0);

            print('TASK PAGE ==============================================');

            // widget.controller.animateToPage(0, duration: Duration(milliseconds: 0), curve: Curves.easeOut);
            return PageView(
//              physics: BouncingScrollPhysics(),
              key: Key('TaskPage'),
              controller: widget.taskPageController,
              children: <Widget>[
                tw,
                ta,
                // Container(color: Colors.blueAccent),
              ],
              scrollDirection: Axis.vertical,
              onPageChanged: (int value) {
                print("Changed page $value");
                _appBloc.taskBloc.getCurrentObjective(getCached: false);
                _appBloc.taskBloc.getTasks();
                _appBloc.taskBloc.getCompletedTasks();
                // FocusScope.of(context).requestFocus(new FocusNode());
              },
            );
          }
        } else {
          return Container(
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );

    return MaterialApp(
        title: 'Moti',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          brightness: Brightness.light,
          accentColor: Colors.yellow[700],
        ),
        home: BlocProvider(bloc: _appBloc, child: initialStream));
  }

  tutorialSequence(var context) async {
    await Future.delayed(Duration(milliseconds: 250));

    var result = await fullscreenTooltip(context,
        w: 150,
        fromTop: 200,
        fromLeft: 150,
        title: "Objective",
        subtitle:
            "You have a single objective active at a time.\nAn objective can be something complex, but precise.",
        bottomTitle: 60,
        leftTitle: 60);

    if (result == 'skip') return;

    await Future.delayed(Duration(milliseconds: 250));

    result = await fullscreenTooltip(context,
        w: 50,
        fromBottom: -50,
        fromRight: -50,
        title: "Tasks",
        subtitle:
            "Your main objective is composed by some tasks: you can interact with them by sliding to the left and to the right.",
        topTitle: 110,
        leftTitle: 60,
        animation: true);

    if (result == 'skip') return;

    await Future.delayed(Duration(milliseconds: 250));

    result = await fullscreenTooltip(
      context,
      w: 55,
      fromBottom: 93,
      fromRight: 23,
      title: "Achievements",
      subtitle: "You can track your accomplishments down here.",
      topTitle: 200,
      leftTitle: 60,
      // bottomTitle: 200,
    );
    if (result == 'skip') return;
    await Future.delayed(Duration(milliseconds: 250));
//
    result = await fullscreenTooltip(context,
        w: 52,
        fromBottom: 145,
        fromRight: 22,
        title: "Stories",
        subtitle:
            "You will find all your older objectives here. You can even use it as a journal!",
        topTitle: 175,
        leftTitle: 60);
    if (result == 'skip') return;

    await Future.delayed(Duration(milliseconds: 250));

    result = await fullscreenTooltip(context,
        w: 50,
        fromBottom: 197,
        fromRight: 20,
        title: "Stats",
        subtitle: "You can view all your statistics here.",
        topTitle: 150,
        leftTitle: 60);
    if (result == 'skip') return;

//    await Future.delayed(Duration(milliseconds: 250));
//
//    result = await fullscreenTooltip(context,
//        w: 50,
//        fromBottom: -50,
//        fromRight: -50,
//        title: "Are you ready?",
//        subtitle:
//            "I've prepared some activities for you, and I think you will love them! 💖 \nPick your favorite!",
//        topTitle: 140,
//        leftTitle: 60);
//    if (result == 'skip') return;
  }
}
