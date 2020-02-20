import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/model/Star.dart';
import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:fluffy_bunny/HeroDialogRoute.dart';

class Stars extends StatefulWidget {
  final PageController controller;
  final AppBloc bloc;

  const Stars({Key key, this.controller, this.bloc}) : super(key: key);

  @override
  createState() => new StarsState();
}

class StarsState extends State<Stars> {
  PageController controller;
  AppBloc appBloc;

  @override
  void initState() {
    super.initState();

    appBloc = widget.bloc;
    appBloc.motivationalBloc.getStars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("★ Achievements"),
            backgroundColor: Colors.yellow[800]),
        body: Container(
            color: Colors.yellow[800],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                  color: Colors.white,
                  elevation: 1.0,
                  child:

                  StreamBuilder(
                      stream: appBloc.motivationalBloc.stars,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<Widget> starsWidgets = [];
                          for (Star star in snapshot.data) {
                            starsWidgets.add(_createAchievement(
                                star.currentLevel, star.maxStars, star.emoji,
                                star.title, star.subtitle, star.description, progress: star.currentValue, maxProgress: star.currentLimit));
                          }

                          return GridView.count(
                              crossAxisCount: 2,
                              children: starsWidgets
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }),

                /*GridView.count(
                  crossAxisCount: 2,
                  children: <Widget>[
                    _createAchievement(
                        1,
                        3,
                        "🎉",
                        "Getting started!",
                        "Complete the tutorial.",
                        "Everyone needs to start somewhere!"),
                    _createAchievement(0, 3, "🤳", "Cheese!", "Take a picture.",
                        "Taking pictures is a strong motivator!")
                  ],
                ),*/

              ),
            )));
  }

  Widget _createAchievement(int starLevel, int maxStars, String emoji,
      String title, String description, String longDescription,
      {int progress = 0, int maxProgress = 0}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          setState(() {
            Navigator.push(
              context,
              new HeroDialogRoute(
                builder: (BuildContext context) {
                  return new Center(
                    child: new AlertDialog(
                      title: new Text(
                        title,
                        textAlign: TextAlign.center,
                      ),
                      content: new Container(
                        height: 200.0,
                        width: 200.0,
                        child: Column(
                          children: <Widget>[
                            new Hero(
                              tag: emoji,
                              child: Material(
                                type: MaterialType.transparency,
                                child: new Container(
                                  child: Text(emoji,
                                      style: TextStyle(fontSize: 56.0),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("⭐" * starLevel),
                                Text(
                                  "★" * (maxStars - starLevel),
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12.0)),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              longDescription,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('OK'),
                          onPressed: Navigator
                              .of(context)
                              .pop,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          });
        },
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Hero(
                tag: emoji,

                child: Material(
                  type: MaterialType.transparency,
                  child: Center(
//                      child: Container(
//                        foregroundDecoration: BoxDecoration(
//                          color: Colors.grey,
//                          backgroundBlendMode: BlendMode.saturation,
//                        ),
//                        child: Text(emoji, style: TextStyle(fontSize: 48.0)),
//                      )

                    child: Text(emoji, style: TextStyle(fontSize: 48.0)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("⭐" * starLevel),
                    Text(
                      "★" * (maxStars - starLevel),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Text(title),
            Text(
              "$description ($progress/$maxProgress)",
              style: TextStyle(color: Colors.black54, fontSize: 10.0),
            )
          ],
        ),
      ),
    );
  }

  void _popup(String emoji) {}
}
