import 'dart:io';

import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/model/Objective.dart';
import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:fluffy_bunny/HeroDialogRoute.dart';
import 'package:fluffy_bunny/StoryObjective.dart';

class History extends StatefulWidget {
  final PageController controller;
  final AppBloc bloc;

  const History({Key key, this.controller, this.bloc}) : super(key: key);

  @override
  createState() => new HistoryState();
}

class HistoryState extends State<History> {
  PageController controller;

  @override
  void initState() {
    widget.bloc.taskBloc.getObjectives();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var sb = StreamBuilder<List<Objective>>(
      stream: widget.bloc.taskBloc.objectives,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Widget> w = [];
          for (var el in snapshot.data) {
            w.add(_createHistoryEntry(StoryObjective(
                title: el.title,
                subtitle: "",
                dateStart: el.createdDate,
                photoPath: el.photoPath,
                color: el.color)));
          }
          return GridView.count(
            crossAxisCount: 2,
            children: w,
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );

    return Scaffold(
        appBar:
            AppBar(title: Text("Stories"), backgroundColor: Colors.blue[800]),
        body: Container(
          color: Colors.blue[600],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(color: Colors.white, elevation: 1.0, child: sb),
          ),
        ));
  }

  Widget _createHistoryEntry(StoryObjective objective) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {},
        child: Container(
          decoration: new BoxDecoration(
            color: objective.color,
            image: objective.image == null
                ? null
                : new DecorationImage(
                    fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.3), BlendMode.dstATop),
                    image: objective.image,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  objective.date ?? '',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Text(
                  objective.title ?? '',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0, right: 5.0),
                child: Text(
                  objective.subtitle ?? '',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white70, fontSize: 12.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
