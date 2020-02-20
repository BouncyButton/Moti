import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tinycolor/tinycolor.dart';

class TextFieldAlertDialog {
  TextEditingController controller;

  final String objTitle;
  bool finished = false;
  DateTime selectedDate;
  Color selectedColor;
  DateTime startDate;
  Color startColor;
  String first;
  String second;

  bool notificationEnabled;

  TextFieldAlertDialog(
      {this.objTitle, this.startDate, this.startColor, this.controller, this.notificationEnabled}) {
    if (this.controller == null) controller = TextEditingController();
    selectedColor = startColor;
  }

  displayDialog(BuildContext context) async {
    controller.addListener(() {});

    var dialog = showDialog(
        context: context,
        builder: (context) {
          var descriptions = getDescription();

          return AlertDialog(
            title: Text('Choose objective'),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[

                      Expanded(
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: 30,
                          maxLengthEnforced: true,
                          textAlign: TextAlign.right,
                          controller: controller,
                          decoration: InputDecoration(
                              hintText: "Exercise, smoke less, skydiving..."),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 0.0, top: 0.0, left: 18.0),
                        child: Tooltip(
                          message: "Select objective color",
                          child: InkWell(
                            onTap: () async {
                              // hacks
                              await _selectColor(context, startColor);
                              Navigator.of(context).pop();
                              await displayDialog(context);

                              // Navigator.of(context).pop();
                            },
                            child: CircleAvatar(
                              radius: 24.0,
                              backgroundColor: selectedColor,
                              child: Icon(Icons.color_lens, color: Colors.white),
                              // label: Text("  ", style: TextStyle(fontSize: 28.0),),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: 22.0),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(child: Container()),

                      Column(
                        children: <Widget>[
                          Text(descriptions[0], style: TextStyle(fontSize: 14.0)),
                          Text(
                            descriptions[1],
                            style: TextStyle(fontSize: 20.0),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Expanded(child: Container()),
                      Tooltip(
                        message: "Change predicted completion date",
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            await _selectDate(context, startDate);
                            startDate = selectedDate;
                            Navigator.of(context).pop();
                            await displayDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  this.finished = true;
                  controller.text = objTitle;
                  controller.notifyListeners(); //eh oh
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('OK'),
                onPressed: () {
                  this.finished = true;
                  controller.notifyListeners(); //eh oh

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });

    if (objTitle != 'Create your new objective') {
      controller.text = objTitle;
    }

    return dialog;
  }

  List<String> getDescription() {
    selectedDate = startDate;
    var first;
    var second;
    var days = selectedDate.difference(DateTime.now()).inDays;
    if (days < -1) {
      first = 'I am';
      second = '${-days} days late';
    }
    if (days == -1) {
      first = 'I am';
      second = '${-days} day late';
    }
    if (days == 0) {
      first = 'I have no days left!';
      second = '$days days left';
    }
    if (days == 1) {
      first = 'I should complete this by';
      second = 'tomorrow';
    }
    if (days > 1) {
      first = 'I should complete this in';
      second = '$days days';
    }
    return [first, second];
  }

  Future<Null> _selectDate(BuildContext context, DateTime startDate) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2030));
    if (picked != null) this.selectedDate = picked;
    // _taskBloc.updateObjective(objective);
  }

  Future<Null> _selectColor(BuildContext context, Color startColor) async {
    final Color pickedColor = await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
              actions: <Widget>[
                new FlatButton(
                  child: new Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
              title: Text('Pick a color for your objective'),
              content: SingleChildScrollView(
                  child: BlockPicker(
                availableColors: [
                  TinyColor(Colors.red).darken(20).color,
                  TinyColor(Colors.pink).darken(20).color,
                  TinyColor(Colors.purple).darken(20).color,
                  TinyColor(Colors.deepPurple).darken(20).color,
                  Color(0xff213277),
                  TinyColor(Colors.blue).darken(20).color,
                  TinyColor(Colors.lightBlue).darken(20).color,
                  TinyColor(Colors.cyan).darken(20).color,
                  TinyColor(Colors.teal).darken(20).color,
                  TinyColor(Colors.green).darken(20).color,
                  TinyColor(Colors.lightGreen).darken(20).color,
                  TinyColor(Colors.lime).darken(20).color,
                  TinyColor(Colors.yellow).darken(35).color,
                  TinyColor(Colors.amber).darken(20).color,
                  TinyColor(Colors.orange).darken(20).color,
                  TinyColor(Colors.deepOrange).darken(20).color,
                  TinyColor(Colors.brown).darken(20).color,
                  TinyColor(Colors.grey).darken(20).color,
                  TinyColor(Colors.blueGrey).darken(20).color,
                  TinyColor(Colors.black).darken(20).color,
                ],
                pickerColor: startColor,
                onColorChanged: (Color c) {
                  if (c != null) this.selectedColor = c;
                },
              )));
        });

    if (pickedColor != null) this.selectedColor = pickedColor;
    // _taskBloc.updateObjective(objective);
  }
}
