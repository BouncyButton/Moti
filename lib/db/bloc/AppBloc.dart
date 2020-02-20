import 'dart:async';

import 'package:fluffy_bunny/LevelUpScreen.dart';
import 'package:fluffy_bunny/db/Database.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/bloc/MotivationBloc.dart';
import 'package:fluffy_bunny/db/bloc/StatBloc.dart';
import 'package:fluffy_bunny/db/bloc/TaskBloc.dart';
import 'package:fluffy_bunny/db/model/Star.dart';
import 'package:fluffy_bunny/db/model/Stat.dart';
import 'package:flutter/material.dart';

class AppBloc implements BlocBase {
  MotivationalBloc _moti;
  TaskBloc _task;
  StatBloc _stat;

  AppBloc () {
    _moti = MotivationalBloc(appBloc: this);
    _task = TaskBloc(appBloc: this);
    _stat = StatBloc(appBloc: this);

    // inserire qua i listen.
    // es:
    // _task.inStream.listen(_evenCounter.sink.add);
    // significa che chiamo automaticamente la add come callback a seguito
    // di un add nell'instream.

    // instrado gli eventi (stream) di task a moti (nel sink)
    _task.events.listen(_moti.inNotifyEvent.add);

    // eventi propri
    _landingPageController.stream.listen(_handleLandingPage);

    checkFirstLaunch();

  }

  checkFirstLaunch() async {

    return DBProvider.db.isFirstLaunch().then((value) {
      if(value) {
        _inLandingPage.add(true);
      } else {
        _inLandingPage.add(false);
      }
    });

  }

  MotivationalBloc get motivationalBloc => _moti;
  TaskBloc get taskBloc => _task;
  StatBloc get statBloc => _stat;

  final _landingPageController = StreamController<bool>.broadcast();
  StreamSink<bool> get _inLandingPage => _landingPageController.sink;
  Stream<bool> get landingPage => _landingPageController.stream;
  bool _isLandingPage;
  bool get isLandingPage => _isLandingPage;


  final _levelUpController = StreamController<List<dynamic>>.broadcast();
  StreamSink<List<dynamic>> get _inLevelUp => _levelUpController.sink;
  Stream<List<dynamic>> get levelUpDialog => _levelUpController.stream;


  final _tooltipController = StreamController<String>.broadcast();
  StreamSink<String> get _inTooltip => _tooltipController.sink;
  Stream<String> get tooltipScreen => _tooltipController.stream;

  @override
  void dispose() {
    print("Appbloc disposed!!");
  }

  void _handleLandingPage(bool value) {
    _isLandingPage = value;
  }

  void endLandingPage() {
    _inLandingPage.add(false);
    _task.initDbIfFirstLaunch();
    // _task.refreshUI();
  }

  void startLandingPage() {
    _inLandingPage.add(true);
  }

  void levelUp(Star star, Stat stat) {
    _inLevelUp.add([star, stat]);
  }

  void tooltip(String type) {
    _inTooltip.add(type);
  }




}