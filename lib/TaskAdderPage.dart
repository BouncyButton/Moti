import 'package:fluffy_bunny/CustomScrollPhysics.dart';
import 'package:fluffy_bunny/Suggestion.dart';
import 'package:fluffy_bunny/SuggestionTree.dart';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:flutter/material.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/bloc/TaskBloc.dart';
import 'dart:math';
import 'package:tinycolor/tinycolor.dart';
import 'package:fluffy_bunny/db/model/Task.dart';

class TaskAdderPage extends StatefulWidget {
  final PageController controller;

  TaskAdderPage({Key key, this.controller}) : super(key: key);

  @override
  createState() => new TaskAdderPageState();
}

class TaskAdderPageState extends State<TaskAdderPage> {
  // PageController controller;
  final _formKey = GlobalKey<FormState>();
  Task _taskToAdd = new Task();
  var repeat = false;
  Color color = TinyColor(Colors.blue).lighten(30).color;
  TaskBloc _taskBloc;

  var willClose = true;
  var willOpen = false;
  var isOpen = false;

  String _taskType = 'remind';
  String _taskFrequency = 'once';

  String suggestionSelected = '';

  FocusNode keyboardFocusNode;

  ScrollController scrollController;
  SuggestionTree tree;
  List<Suggestion> suggestionsSelected = [];
  Suggestion changedSuggestion;
  var changedKey;

  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _taskToAdd.objectiveId = 1; // TODO
    _taskToAdd.color = color;
    _taskBloc = BlocProvider.of<AppBloc>(context).taskBloc;
    keyboardFocusNode = FocusNode();
    scrollController = ScrollController();
    tree = SuggestionTree();
  }

  void pageViewListener() {
    /// widget.controller.page cambia da 0 a 1.
    /// mi interessa che:
    /// a) l'utente riceva la tastiera in entrata nello schermo il prima
    ///    possibile (ovvero superati i 0.5)
    /// b) l'utente non faccia dismiss a seguito di un drag che non vada <0.5.

    // print(widget.controller.page);

    // la pagina verrà chiusa
    if (widget.controller.page < 0.5) {
      // se ero aperto
      if (isOpen) {
        // tolgo la tastiera di mezzo

        // ma che cavolo di bug è TODO
        if (context != null)
          FocusScope.of(context).requestFocus(new FocusNode());
        isOpen = false;
      }
      // evito di chiudere mille volte la tastiera
    }

    // se la pagina verrà aperta
    if (widget.controller.page >= 0.5) {
      // se non ero già aperto
      if (!isOpen) {
        // metti il focus

        if (context != null) {
          FocusScope.of(context).requestFocus(keyboardFocusNode);
          isOpen = true;
        } else {
          // il widget è probabilmente dirty.
          widget.controller.removeListener(pageViewListener);
        }
      } else {
        // non devo fare nulla.
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(pageViewListener);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.addListener(pageViewListener);

    ScrollController sc = ScrollController();

    return new Scaffold(
      body: new GestureDetector(
          onTap: () {
            print("tapped TaskAdder");
            // tolgo il focus alla keyboard
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            // controller: scrollController,
            physics: NeverScrollableScrollPhysics(),
            //scrollController.position.pixels != 0 ? CustomScrollPhysics() : NeverScrollableScrollPhysics(),
            child: new Container(
              height: MediaQuery.of(context).size.height,
              //color: Colors.lightBlue[100],

              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [
                    0,
                    1
                  ],
                      colors: [
                    Colors.lightBlue[100],
                    Colors.deepPurple[200],
                  ])),

              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
              // transform: Matrix4.translationValues(0.0,-5.0,0.0),
              child: Stack(
                children: <Widget>[
                  // ciccia.
                  Form(
                    key: _formKey,
                    child: Card(
                      color: Colors.amber[50],
                      elevation: 15.0,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 26.0),

                          Text("I want to..."),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 10.0,
                                ),
                                ChoiceChip(
                                  selected: _taskType == 'remind',
                                  // avatar: _taskType == 'remind' ? Icon(Icons.check_circle) : Icon(Icons.check_circle_outline),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _taskType =
                                          'remind'; //selected ? 'remind' : null;
                                      color = TinyColor(Colors.blue)
                                          .lighten(30)
                                          .color;
                                      _taskToAdd.color = Colors.blue;
                                    });
                                  },
                                  // avatar: Icon(Icons.alarm),
                                  label: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 2.0,
                                      ),
                                      Icon(Icons.alarm),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 3.0),
                                        child: Text("Remember to",
                                            style: TextStyle(
                                                color:
                                                    TinyColor(Colors.blue[900])
                                                        .darken(30)
                                                        .color,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                      SizedBox(
                                        height: 2.0,
                                      )
                                    ],
                                  ),
                                  selectedColor:
                                      TinyColor(Colors.blue).lighten(30).color,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                ChoiceChip(
                                  selected: _taskType == 'learn',
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _taskType =
                                          'learn'; //selected ? 'learn' : null;
                                      color = TinyColor(Colors.deepPurple)
                                          .lighten(30)
                                          .color;
                                      _taskToAdd.color = Colors.deepPurple;
                                    });
                                  },
                                  label: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3.0),
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 2.0,
                                        ),
                                        Icon(Icons.timeline),
                                        Text("Learn to",
                                            style: TextStyle(
                                                color: TinyColor(
                                                        Colors.deepPurple[900])
                                                    .darken(30)
                                                    .color,
                                                fontWeight: FontWeight.w500)),
                                        SizedBox(
                                          height: 2.0,
                                        )
                                      ],
                                    ),
                                  ),
                                  selectedColor: Colors.deepPurple[200],
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                ChoiceChip(
                                  selected: _taskType == 'stop',
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _taskType =
                                          'stop'; //selected ? 'stop' : null;
                                      color = Colors.red[200];
                                      _taskToAdd.color = Colors.red[200];
                                    });
                                  },
                                  label: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3.0),
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 2.0,
                                        ),
                                        Icon(Icons.not_interested),
                                        Text("Stop to",
                                            style: TextStyle(
                                                color:
                                                    TinyColor(Colors.grey[900])
                                                        .darken(30)
                                                        .color,
                                                fontWeight: FontWeight.w500)),
                                        SizedBox(
                                          height: 2.0,
                                        )
                                      ],
                                    ),
                                  ),
                                  selectedColor: Colors.red[200],
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                          ),

                          // Textbox
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 15.0),
                            child: Card(
                              color: TinyColor(color).lighten(10).color,
                              child: TextFormField(
                                textCapitalization: TextCapitalization.sentences,
                                // autofocus: true,
                                controller: textController,
                                focusNode: keyboardFocusNode,
                                style: TextStyle(fontSize: 24.0),
                                decoration: InputDecoration(

                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 2.0,
                                            color: TinyColor(color)
                                                .darken(20)
                                                .color)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: TinyColor(color)
                                                .darken(20)
                                                .color)),
                                    labelStyle: TextStyle(
                                        fontSize: 20.0,
                                        color:
                                            TinyColor(color).darken(55).color),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 15.0),
                                    labelText: 'Describe your task.'),
                                maxLines: 1,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter a description.';
                                  }
                                  return null;
                                },
                                onSaved: (value) => setState(() {
                                  var splitted = value.split(" ");
                                  var title = '';

                                  _taskToAdd.title = value;
                                }),
                              ),
                            ),
                          ),

                          SizedBox(height: 8.0),
                          Text("I need to do this..."),

                          // TASK FREQUENCY
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ChoiceChip(
                                selected: _taskFrequency == 'once',
                                onSelected: (bool selected) {
                                  setState(() {
                                    _taskFrequency =
                                        'once'; //selected ? 'once' : null;
                                  });
                                },
                                label: Text("Just once",
                                    style: TextStyle(
                                        color: TinyColor(Colors.blue[900])
                                            .darken(30)
                                            .color,
                                        fontWeight: FontWeight.w500)),
                                selectedColor: TinyColor(color).color,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              ChoiceChip(
                                selected: _taskFrequency == 'daily',
                                onSelected: (bool selected) {
                                  setState(() {
                                    _taskFrequency =
                                        'daily'; //selected ? 'daily' : null;
                                  });
                                },
                                label: Text("Daily",
                                    style: TextStyle(
                                        color: TinyColor(Colors.deepPurple[900])
                                            .darken(30)
                                            .color,
                                        fontWeight: FontWeight.w500)),
                                selectedColor: color,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              ChoiceChip(
                                selected: _taskFrequency == 'weekly',
                                onSelected: (bool selected) {
                                  setState(() {
                                    _taskFrequency =
                                        'weekly'; // selected ? 'weekly' : null;
                                  });
                                },
                                label: Text("Weekly",
                                    style: TextStyle(
                                        color: TinyColor(Colors.grey[900])
                                            .darken(30)
                                            .color,
                                        fontWeight: FontWeight.w500)),
                                selectedColor: color,
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 0.0),
                            child: Divider(),
                          ),

                          Center(
                              child: Text(
                            "Having troubles? Try to...",
                            textAlign: TextAlign.center,
                            softWrap: true,
                          )),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 2.0 -
                                          28.0,
                                  // width: MediaQuery.of(context).size.width - 95.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: SingleChildScrollView(
                                      child: Wrap(
                                        alignment: WrapAlignment.start,

                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
//                                    direction: Axis.horizontal,
//                                    spacing: 3.0,
                                        children: _generateSuggestions(),

                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                // width: 64.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                                  child: Tooltip(
                                    message: "Add new task",
                                    child: RawMaterialButton(
                                      elevation: 8.0,
//                                  icon: Icon(Icons.check),
//                                  tooltip: "Add task",
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Center(child: Column(
                                            children: <Widget>[
                                              SizedBox(height: 4.0,),
                                              Icon(Icons.check),
                                              Text("Add", style: TextStyle(fontSize: 12.0),),
                                            ],
                                          )),
                                        ),
                                      ),
                                      shape: CircleBorder(),
                                      fillColor: Colors.amber,
                                      onPressed: () {
                                        _addTask();

                                        widget.controller.animateToPage(0,
                                            duration: Duration(milliseconds: 500),
                                            curve: Curves.ease);

                                        print("Aggiungi!");
                                      },
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          //),

                          // SUGGESTIONS

                          /*Wrap(
                              direction: Axis.horizontal,

                            ),*/

                          // OLD OPTIONS

                          /*
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: _getLighterColor(color),
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(children: <Widget>[
                                        Expanded(child: Divider()),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32.0),
                                          child: Text("Options"),
                                        ),
                                        Expanded(child: Divider()),
                                      ]),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: ChoiceChip(
                                            label: Text("Repeat"),
                                            avatar: Icon(Icons.repeat),
                                            padding: EdgeInsets.all(5.0),
                                            selected: repeat,
                                            onSelected: (var value) {
                                              setState(() {
                                                repeat = !repeat;
                                              });
                                              print(value);
                                            },
                                            selectedColor: Colors.white,
                                            labelStyle: repeat
                                                ? TextStyle(color: Colors.black)
                                                : TextStyle(
                                                    color: Colors.black38),
                                            shape: repeat
                                                ? RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0),
                                                    side: BorderSide(
                                                        color: Colors.black,
                                                        width: 0.5))
                                                : RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0),
                                                    side: BorderSide(
                                                        color: Colors.white,
                                                        width: 0.5)),
                                          ),
                                        ),
                                        _getColoredChip(Colors.blueAccent),
                                        _getColoredChip(Colors.greenAccent),
                                        _getColoredChip(Colors.deepOrangeAccent),
                                        _getColoredChip(Colors.redAccent),

                                        /*
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: ChoiceChip(
                                              label: Text(""),
                                              //avatar: Icon(Icons.repeat),
                                              padding: EdgeInsets.all(5.0),
                                              selected: widget.color == Colors.red,
                                              onSelected: (var value) {
                                                setState(() {
                                                  widget.color = Colors.red;
                                                });
                                                print(value);
                                              },
                                              // selectedColor: Colors.greenAccent,
                                              backgroundColor: Colors.red,
                                              shape: widget.color == Colors.red
                                                  ? CircleBorder(
                                                  side: BorderSide(
                                                      color: Colors.black, width: 0.5))
                                                  : CircleBorder(
                                                  side: BorderSide(
                                                      color: Colors.white, width: 0.0)),
                                            ),
                                          ),
                                          */
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                            */
                        ],
                      ),
                    ),
                  ),

                  // per continuare la scheda bianca. hack.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      height: 10.0,

                      width: MediaQuery.of(context).size.width - 10.0,
                      //padding: EdgeInsets.symmetric(horizontal: 20.0),
                      color: Colors.amber[50],
                    ),
                  ),
                ],
              ),
            ),
          )),

      /*floatingActionButton: FloatingActionButton(
          tooltip: "Add task",
          child: Icon(Icons.check),
          onPressed: () {
            _addTask();

            widget.controller.animateToPage(0,
                duration: Duration(milliseconds: 500), curve: Curves.ease);

            print("Aggiungi!");
          },
        )*/
    );
  }

  void _addTask() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      _taskToAdd.creationDateSinceEpoch = DateTime.now();
      _taskToAdd.completed = 0;
      _taskToAdd.repetition = _taskFrequency; //'once';
      _taskToAdd.classification = _taskType;
      _taskToAdd.objectiveId = (await _taskBloc.getCurrentObjective()).id;
      _taskBloc.inAddTask.add(_taskToAdd);
    }
  }

  Widget _getColoredChip(Color c2) {
    return new Padding(
      padding: const EdgeInsets.all(9.0),
      child: ChoiceChip(
        label: color == c2
            ? Text(
                "  ",
                style: TextStyle(fontSize: 32.0),
              )
            : Text(""),
        //avatar: Icon(Icons.repeat),
        padding: EdgeInsets.all(5.0),
        selected: color == c2,
        onSelected: (var value) {
          setState(() {
            color = c2;
            _taskToAdd.color = c2;
          });
          print(value);
        },
        selectedColor: c2,

        backgroundColor: c2,
        shape: color == c2
            ? CircleBorder(side: BorderSide(color: Colors.black, width: 0.5))
            : CircleBorder(side: BorderSide(color: Colors.white, width: 0.0)),
      ),
    );
  }

  List<Widget> _generateSuggestions() {
    //  var data =

    List<Suggestion> visibleSuggestions = [];

    for (Suggestion root in tree.roots) {
      if (!suggestionsSelected.map((el) => el.root).toList().contains(root) &&
          suggestionsSelected.length == 0) visibleSuggestions.add(root);

      for (Suggestion suggestion in suggestionsSelected) {
        if (suggestion.root != root) continue;
        // aggiungo tutti i parent
        Suggestion parent = suggestion.parent;

        var index = visibleSuggestions.length;
        while (parent != null && parent.parent != null) {
          visibleSuggestions.insert(index, parent);
          //parents.add(parent);
          parent = parent.parent;
        }
        visibleSuggestions.insert(index, suggestion.root);

        //visibleSuggestions.addAll(parents.reversed.toList());

//      // aggiungo se stesso (se non è una root)
//        if (suggestion.parent != null)
//          visibleSuggestions.add(suggestion);

        // devo mettere prima i figli, no?

        // aggiungo i fratelli
        if (suggestion.parent != null) {
          var brothers = suggestion.parent.children.toList();
          // brothers.remove(suggestion);

          for (var b in brothers) {
            visibleSuggestions.add(b);
            if (b == suggestion) {
              // aggiungo i figli
              if (suggestion.children != null)
                visibleSuggestions.addAll(suggestion.children);
            }
          }
        } else {
          visibleSuggestions.addAll(suggestion.children);
        }
      }

//      if (tasksSelected.contains(root.text)) {
//        visibleSuggestions.addAll(recursive(root));
//      }
    }

    List<Widget> result = [];
    for (Suggestion s in visibleSuggestions) {
      var key = GlobalKey();
      s.key = key;
      result.add(
        Padding(
          padding: const EdgeInsets.only(
              left: 4.0, right: 4.0, top: 0.0, bottom: 0.0),
          child: ChoiceChip(
            key: key,
            label: Text(
              s.text,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
            ),
            selected: suggestionsSelected.contains(s),
            selectedColor: color,

            /*s.type == 'remind'
                ? TinyColor(Colors.blue).lighten(30).color
                : s.type == 'learn'
                    ? TinyColor(Colors.deepPurple).lighten(30).color
                    : s.type == 'stop' ? TinyColor(Colors.red).lighten(30).color : color,*/
            onSelected: (bool selected) {
              setState(() {
                // TODO prestazioni
                suggestionsSelected = [];
                if (selected && !suggestionsSelected.contains(s)) {
                  //Scrollable.of(context). = r.localToGlobal(Offset.zero).dy;

                  // provo
                  FocusScope.of(context).requestFocus(new FocusNode());

                  suggestionsSelected.add(s);
                  textController.text = s.text;
                  suggestFrequency(s);
                  changedKey = key;

                  // scrollo fino al genitore.
                  if (changedKey != null) {
//                    Scrollable.ensureVisible(changedKey.currentContext,
//                        curve: Curves.easeOut,
//                        duration: Duration(milliseconds: 200),
//                        alignment: 0.0,
//                        howManyScrollers: 1);
                    // }
                  }
                } else {
                  suggestionsSelected.remove(s);

                  if (s.parent != null) {
//                  Scrollable.ensureVisible(key.currentContext,curve: Curves.easeOut);

                    textController.text = s.parent.text;
                    suggestionsSelected.add(s.parent);
                    suggestFrequency(s.parent);
                    changedSuggestion = s;

//                    RenderBox r = changedSuggestion.parent.key.currentContext
//                        .findRenderObject();
//                    scrollController.animateTo(
//                        r
//                                .localToGlobal(
//                                    Offset(scrollController.position.pixels, 0))
//                                .dx -
//                            25,
//                        duration: Duration(milliseconds: 300),
//                        curve: Curves.easeOut);
                  } else
                    textController.text = "";
                }
              });

//
//              RenderBox r = key.currentContext.findRenderObject();
//              print(r
//                  .localToGlobal(Offset(scrollController.position.pixels, 0))
//                  .dx);
//
//
//              scrollController.animateTo(
//                  r
//                      .localToGlobal(
//                      Offset(scrollController.position.pixels, 0))
//                      .dx -
//                      25,
//                  duration: Duration(milliseconds: 300),
//                  curve: Curves.easeOut);
            },
          ),
        ),
      );
    }

    return result;
  }

  void suggestFrequency(Suggestion s) {
    if (s.type == 'remind') {
      _taskType = 'remind';
      color = TinyColor(Colors.blue).lighten(30).color;
      _taskToAdd.color = Colors.blue;
    } else if (s.type == 'learn') {
      _taskType = 'learn';
      color = TinyColor(Colors.deepPurple).lighten(30).color;
      _taskToAdd.color = Colors.deepPurple;
    } else if (s.type == 'stop') {
      _taskType = 'stop';
      color = TinyColor(Colors.red).lighten(30).color;
      _taskToAdd.color = Colors.red;
    }

    if (s.repetition == 'once') {
      _taskToAdd.repetition = 'once';
      _taskFrequency = 'once';
    } else if (s.repetition == 'daily') {
      _taskToAdd.repetition = 'daily';
      _taskFrequency = 'daily';
    } else if (s.repetition == 'weekly') {
      _taskToAdd.repetition = 'weekly';
      _taskFrequency = 'weekly';
    }
  }

  List<Suggestion> recursive(Suggestion s, {depth: 0}) {
    if (s == null) return [];

    if (s.children == null && depth == 0) return [];
    if (s.children == null) return [s];

    List<Suggestion> result = [];
    // esco direttamente se sono andato oltre
    // if (!tasksSelected.contains(s.text)) return [s];
//
//    else if(tasksSelected.contains(s.text) && depth > 0)
//      result.add(s);
//

    for (Suggestion el in s.children) {
      result.addAll(recursive(el, depth: depth + 1));
    }

    return result;
  }
}

Color _getLighterColor(Color color) {
  return TinyColor(color).lighten(30).color;
}

Color _getDarkerColor(Color color) {
  return TinyColor(color).darken(35).color;
}
