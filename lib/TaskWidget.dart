import 'package:fluffy_bunny/History.dart';
import 'package:fluffy_bunny/MotivationalController.dart';
import 'package:fluffy_bunny/TaskPage.dart';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/MotivationBloc.dart';
import 'package:fluffy_bunny/db/bloc/TaskBloc.dart';
import 'package:flutter/material.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TaskWidget extends StatefulWidget {
  final PageController controller;

  const TaskWidget({Key key, this.controller}) : super(key: key);

  @override
  createState() => new TaskWidgetState();
}

class TaskWidgetState extends State<TaskWidget> {
  PageController controller;


  @override
  Widget build(BuildContext context) {
    return TaskPage(controller: widget.controller);
  }
}
