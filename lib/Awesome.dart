import 'package:fluffy_bunny/NiceButton.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Awesome extends StatefulWidget {
  final PageController controller;

  const Awesome({Key key, this.controller}) : super(key: key);

  @override
  createState() => new AwesomeState();
}

class AwesomeState extends State<Awesome> {
  PageController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue[800],
        height: MediaQuery.of(context).size.height,
        child: Material(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height
            ),
            child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue[800],
                      Color(0xffa9d4f4),
                    ],
                    stops: [0.0, 1.2],
                  ),
                ),

              // height: MediaQuery.of(context).size.height,
                //color: Colors.blue[800],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 72.0, bottom: 24.0),
                      child: Text(
                        "Awesome!",
                        style: TextStyle(fontSize: 36.0, color: Colors.white, fontWeight: FontWeight.w200),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                          child: Text(
                        "That was amazing 😄\n",
                        style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w300),
                      )),
                    ),
                    Flexible(fit: FlexFit.loose, child: Container()),
                    InkWell(
                        splashColor:
                        Theme.of(context).primaryColor.withAlpha(30),
                        onTap: () {
                          setState(() {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        },

                        child: NiceButton(
                        text: "I'M READY FOR MY NEXT STORY",
                        textColor: Colors.blue,
                      ),
                    ),
                    SizedBox(
                      height: 32.0,
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
