import 'package:fluffy_bunny/MotivationalController.dart';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/bloc/MotivationBloc.dart';
import 'package:fluffy_bunny/db/bloc/TaskBloc.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tinycolor/tinycolor.dart';
import 'package:fluffy_bunny/db/model/Task.dart';
import 'package:fluffy_bunny/TaskAdderPage.dart';

class TaskAdder extends StatefulWidget {
  final PageController controller;
  var repeat = false;
  Color color = Colors.blueAccent;
  final AppBloc bloc;

  TaskAdder({Key key, this.controller, this.bloc}) : super(key: key) {
    print(this.controller);
  }

  @override
  createState() => new TaskAdderState();
}

class TaskAdderState extends State<TaskAdder> {
  final _formKey = GlobalKey();
  Task _taskToAdd = new Task();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          widget.controller.animateToPage(0,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
          return false;
        },
        child: TaskAdderPage(
          controller: widget.controller,
        ));
  }
}
