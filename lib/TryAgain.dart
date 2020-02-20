import 'package:fluffy_bunny/NiceButton.dart';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/bloc/MotivationBloc.dart';
import 'package:fluffy_bunny/db/bloc/TaskBloc.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class TryAgain extends StatefulWidget {
  final PageController controller;
  final AppBloc bloc;
  final String text;
  final List<String> textList;

  const TryAgain(
      {Key key, this.text, this.controller, this.bloc, this.textList})
      : super(key: key);

  @override
  createState() => new TryAgainState();
}

class TryAgainState extends State<TryAgain> {
  TaskBloc _taskBloc;

  @override
  void initState() {
    super.initState(); // sempre per primo?
    _taskBloc = widget.bloc.taskBloc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue[800],
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Material(
            child: Container(

                // height: MediaQuery.of(context).size.height,
                // color: Colors.blue[800],
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Colors.blue[800],
                      Colors.deepPurple[800],
                    ],
                        stops: [
                      0,
                      1
                    ])),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 72.0, bottom: 4.0),
                      child: Text(
                        "It's okay!",
                        style: TextStyle(
                            fontSize: 32.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
//                      Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: Center(
//                            child: Card(
//                          color: Colors.blueGrey,
//                          shape: RoundedRectangleBorder(
//                              borderRadius: BorderRadius.circular(20.0)),
//                          child: Container(
//                            // TODO: if missing photo, let user take photo.
//                            height: 200,
//                            width: 200,
//                          ),
//                        )),
//                      ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 48.0),
                        child: Center(
                            child: Text(
                          widget.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w300),
                          softWrap: true,
                        )),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 32.0, top: 0.0),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon(Icons.arrow_forward_ios, color: Colors.white70,),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.68,

                                    child: Text(
                                      widget.textList[0],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w300),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),

                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon(Icons.arrow_forward_ios, color: Colors.white70,),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.68,
                                    child: Text(
                                      widget.textList[1],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w300),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),


                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon(Icons.arrow_forward_ios, color: Colors.white70,),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width* 0.68,
                                    child: Text(
                                      widget.textList[2],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w300),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon(Icons.arrow_forward_ios, color: Colors.white70,),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.68,
                                    child: Text(
                                      widget.textList[3],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w300),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),


                        ],
                      ),
                    ),
//
//                      Flexible(
//                        child: Container(),
//                        fit: FlexFit.loose,
//                      ),
                    InkWell(
                      splashColor: Theme.of(context).primaryColor.withAlpha(30),
                      onTap: () {
                        setState(() {
                          _taskBloc.refreshUI();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      },
                      child: NiceButton(
                        text: "I WON'T GIVE UP. LET ME GO BACK!",
                        textColor: Colors.blue,
                      ),
                    ),
                    InkWell(
                      splashColor: Theme.of(context).primaryColor.withAlpha(30),
                      onTap: () async {
                        //setState(() {
                          await _taskBloc.restartCurrentObjective();
//                          await _taskBloc.refreshUI();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        //});
                      },
                      child: NiceButton(
                        fillColor: Colors.red,
                        text: "I'M SURE. LET ME START OVER",
                        textColor: Colors.white,
                      ),
                    ),

                    SizedBox(
                      height: 24.0,
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
