import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:fluffy_bunny/HeroDialogRoute.dart';
import 'package:bezier_chart/bezier_chart.dart';

class Stats extends StatefulWidget {
  final PageController controller;
  final AppBloc bloc;

  const Stats({Key key, this.controller, this.bloc}) : super(key: key);

  @override
  createState() => new StatsState();
}

class StatsState extends State<Stats> {
  PageController controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var sb = StreamBuilder<BezierChart>(
        stream: widget.bloc.statBloc.statChart,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          side: BorderSide(
                              width: 0.0, color: Colors.transparent)),
                      elevation: 15,
                      // margin: EdgeInsets.all(8.0),
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Container(
                                // color: Colors.purpleAccent[100],
                                // height: MediaQuery.of(context).size.height / 2.5,
                                width:
                                    MediaQuery.of(context).size.width + 100.0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[

                                    Container(
                                      child: snapshot.data,
                                      height: 280,
                                    ),
                                  ],
                                )),
                          ),
                          Positioned(
                              bottom: 10.0,
                              right: 20.0,
                              child: Text("Day",
                                  style: TextStyle(color: Colors.white))),
                          Positioned(
                              top: 10.0,
                              left: 20.0,
                              child: Text("Motivation/Ability",
                                  style: TextStyle(color: Colors.white)))
                        ],
                      ) /*sample2(context)*/),
                ),
                Visibility(
                  visible: widget.bloc.statBloc.inactivityDays != null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Visibility(
                          visible: widget.bloc.statBloc.userBehind,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 24.0),
                            child: Container(
                                child: Text(
                              "You are behind on your schedule! Start doing something to improve your Motivation. 🚀",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.white70),
                            )),
                          )),
                      Visibility(
                          visible: widget.bloc.statBloc.inactivityDays == 0 &&
                              !(DateTime.now()
                                      .difference(
                                          widget.bloc.statBloc.startDate)
                                      .inDays ==
                                  0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 24.0),
                            child: Container(
                                child: Text(
                              "You did something today, so your Motivation has been increased! 💪",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.white70),
                            )),
                          )),
                      Visibility(
                          visible: widget.bloc.statBloc.inactivityDays == 0 &&
                              DateTime.now()
                                      .difference(
                                          widget.bloc.statBloc.startDate)
                                      .inDays ==
                                  0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 24.0),
                            child: Container(
                                child: Text(
                              "You just started a new objective. Adding tasks can help you to boost your Motivation. 😉",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.white70),
                            )),
                          )),
                      Visibility(
                          visible: widget.bloc.statBloc.inactivityDays == 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 24.0),
                            child: Container(
                                child: Text(
                              "You haven't done anything today. Why don't start now?",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.white70),
                            )),
                          )),
                      Visibility(
                          visible: widget.bloc.statBloc.inactivityDays > 1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 24.0),
                            child: Container(
                                child: Text(
                              "You haven't completed any unplanned task for ${widget.bloc.statBloc.inactivityDays} days.",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.white70),
                            )),
                          )),
                      Visibility(
                          visible:
                              widget.bloc.statBloc.completedTasksInDay.length ==
                                  1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 24.0),
                            child: Container(
                                child: Text(
                              "You completed a task today and you got +1 Motivation and +1 Ability. 🎉",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.white70),
                            )),
                          )),
                      Visibility(
                          visible:
                              widget.bloc.statBloc.completedTasksInDay.length >
                                  1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 24.0),
                            child: Container(
                                child: Text(
                              "You're on fire! 🔥\n"
                              "You completed ${widget.bloc.statBloc.completedTasksInDay.length} tasks today, so you got tons of Motivation and Ability!",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.white70),
                            )),
                          )),
                    ],
                  ),
                ),
//                  RaisedButton(
//                    onPressed: () {
//                      widget.bloc.statBloc.getStats();
//                    },
//                    child: Text("Refresh"),
//                  )
              ],
            );
          } else
            return Padding(
              padding: const EdgeInsets.all(50.0),
              child: Center(child: CircularProgressIndicator()),
            );
        });

    widget.bloc.statBloc.getStats();

    return Scaffold(
        appBar: AppBar(
            title: Text("Statistics"), backgroundColor: Colors.purple[800]),
        body: Container(
            color: TinyColor(Colors.purple[800]).darken(17).color, child: sb));
  }
}
