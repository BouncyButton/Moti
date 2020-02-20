import 'package:flutter/material.dart';

abstract class MotivationalMessage {

  static MotivationalMessage build(MotivationalMessageType type) {

    if (type == MotivationalMessageType.tutorialActiveLastStep)
      return GenericMotivationalMessage(
        emoji: "👇",
        text: "When you're satisfied, you can end the current objective scrolling down here",
      );
    if (type == MotivationalMessageType.lastTask)
      return GenericMotivationalMessage(
        emoji: "🚗",
        text: "You're almost there!",
      );
    if (type == MotivationalMessageType.allDone)
      return GenericMotivationalMessage(
        emoji: "👍",
        text: "Good job! Anything left?",
      );
    if (type == MotivationalMessageType.tutorialActive)
      return GenericMotivationalMessage(
        emoji: "😀",
        text: "Follow the instructions above!",
      );
    if (type == MotivationalMessageType.allEmptyTodo)
      return MotivationalMessageAllEmptyTodo();
    if (type == MotivationalMessageType.notEmptyTodo)
      return MotivationalMessageNotEmptyTodo();
    if (type == MotivationalMessageType.firstCompleted)
      return GenericMotivationalMessage(
        emoji: "🐥",
        text: "Great!"
      );
    if (type == MotivationalMessageType.secondCompleted)
      return GenericMotivationalMessage(
        emoji: "🐤",
        text: "Another one done!"
      );
    if (type == MotivationalMessageType.justAdded)
      return GenericMotivationalMessage(
        emoji: "✒️",
        text: "You had a wonderful idea!"
      );
    if (type == MotivationalMessageType.keepAdding)
      return GenericMotivationalMessage(
        emoji: "🗒",
        text: "Try to find out at least 4 tasks that you need to do."
      );
    if (type == MotivationalMessageType.startDoing)
      return GenericMotivationalMessage(
        emoji: "💪",
        text: "Great!\nWhat do you think you're the most skilled at?\nStart with that!"
      );
    return MotivationalMessageDefaultMessage();
  }

  Widget buildWidget();
}

enum MotivationalMessageType {
  allEmptyTodo,
  notEmptyTodo,
  defaultMessage,
  firstCompleted,
  secondCompleted,
  justAdded,
  keepAdding,
  startDoing,
  tutorialActive,
  tutorialActiveLastStep,
  lastTask,
  allDone,
}

class GenericMotivationalMessage extends MotivationalMessage {
  //final String emoji;
  //final String text;
  final String emoji;
  final String text;
  final String description;

  GenericMotivationalMessage({this.emoji, this.text, this.description});

  @override
  Widget buildWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          children: <Widget>[
            Center(
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: 48.0),
                )),
            SizedBox(height: 8.0,),
            Center(
              child: Text(
                text,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            )
          ],
        ),
      ),
    );
  }
}



class MotivationalMessageAllEmptyTodo extends MotivationalMessage {
  @override
  Widget buildWidget() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              "🌦",
              style: TextStyle(fontSize: 48.0),
            ),
          ),
          Text(
            "No items. Why don't you start now?",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    ));
  }
}

class MotivationalMessageNotEmptyTodo extends MotivationalMessage {
  @override
  Widget buildWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          children: <Widget>[
            Center(
                child: Text(
              "🛩",
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
}

class MotivationalMessageDefaultMessage extends MotivationalMessage {
  @override
  Widget buildWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Container(
          // height: 200,
          child: Column(
            children: <Widget>[
              Center(
                  child: Text(
                "🌍",
                style: TextStyle(fontSize: 48.0),
              )),
              Center(
                child: Text(
                  "Hello world!",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
