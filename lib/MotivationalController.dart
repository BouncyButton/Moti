import 'package:fluffy_bunny/db/model/MotivationalEvent.dart';
import 'package:flutter/material.dart';

class MotivationalController {
  MotivationalModel model;

  MotivationalController() {
    model = new MotivationalModel();
  }

  void notifyEvent(MotivationalEvent event) {
    print(event.type);
    model.addEvent(event);
  }

  Widget getMotivationalElement() {
    return model.buildMotivationalElement();
  }
}

class MotivationalModel {
  List<MotivationalEvent> events = [];

  Widget buildMotivationalElement() {
    var eventTypes = (events.map((e) => e.type)).toList();

    if (eventTypes.contains(MotivationalEventType.allEmpty)) {
      return Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "🌦",
                  style: TextStyle(fontSize: 48.0),
                ),
              ),
              Text(
                "No items. Why don't you start now? ☔",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          )
      );
    }

    if (eventTypes.contains(MotivationalEventType.notEmptyTodo)) {
      return Center(
        child: Container(
          // height: 200,
          child: Column(
            children: <Widget>[
              Center(
                  child: Text(
                    "✈",
                    style: TextStyle(fontSize: 48.0),
                  )),
              Center(
                child: Text(
                  "Do something!",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            ],
          ),
        ),
      );
    }
    return Center(
      child: Container(
        // height: 200,
        child: Column(
          children: <Widget>[
            Center(
                child: Text(
                  "✈",
                  style: TextStyle(fontSize: 48.0),
                )),
            Center(
              child: Text(
                "Do something!",
                style: TextStyle(color: Colors.black54),
              ),
            )
          ],
        ),
      ),
    );

  }

  void addEvent(MotivationalEvent event) {

    if(event.type == MotivationalEventType.notEmptyTodo) {
      events.removeWhere((element) => element.type == MotivationalEventType.allEmpty);
      events.removeWhere((element) => element.type == MotivationalEventType.notEmptyTodo);
    }

    events.add(event);
  }
}
