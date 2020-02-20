import 'package:fluffy_bunny/Stars.dart';
import 'package:fluffy_bunny/db/bloc/AppBloc.dart';
import 'package:fluffy_bunny/db/bloc/BlocProvider.dart';
import 'package:fluffy_bunny/db/model/Star.dart';
import 'package:fluffy_bunny/db/model/Stat.dart';
import 'package:flutter/material.dart';

class LevelUpScreen {
  Stat stat;
  Star star;

  LevelUpScreen({this.stat, this.star});

  showDialog(BuildContext context, TickerProvider tp) async {

    BlocProvider.of<AppBloc>(context).taskBloc.getTotalStars();

    var controller = AnimationController(
        vsync: tp,
        duration: Duration(milliseconds: 1200),
        reverseDuration: Duration(milliseconds: 500));

    await Navigator.of(context).push(build(context, tp, controller));

    var controller2 =
        AnimationController(vsync: tp, duration: Duration(milliseconds: 700));
    await controller2.forward().then((_) => controller2.dispose());

    controller.dispose();
  }

  myLoop(AnimationController controller) {
    controller
        .forward()
        .then((_) => controller.reverse().then((_) => myLoop(controller)));
  }

  build(
      BuildContext context, TickerProvider tp, AnimationController controller) {
    var animation = CurvedAnimation(
        parent: controller,
        curve: Curves.elasticIn,
        reverseCurve: Curves.bounceOut);

    // myLoop(controller);
    controller.forward().then((_) {
      if(!controller.isDismissed && controller.status == AnimationStatus.completed)
      controller.reverse();
    });
    //Tween(begin: 5.0, end: 0.0,controller ).animate(controller);
    // var animation2 = Tween(begin: 0.0, end: 2 * 3.1415926).animate(controller);

    return PageRouteBuilder(
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return new SlideTransition(
            position: new Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        opaque: false,
        barrierColor: Colors.black12,
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Card(
                    elevation: 10,
                    child: createAchievement(
                        stat,
                        star,
                        star.currentLevel + 1,
                        // it hasnt still updated (shouldve waited for db)
                        star.maxStars,
                        star.emoji,
                        star.title,
                        star.subtitle,
                        star.description,
                        animation,
                        controller,
                        tp)),
              ),
            ),
          );
        });
  }
}

Widget createAchievement(
    Stat stat,
    Star star,
    int starLevel,
    int maxStars,
    String emoji,
    String title,
    String description,
    String longDescription,
    var animation,
    AnimationController controller,
    TickerProvider tp,
    {int progress = 0,
    int maxProgress = 0}) {
  return Padding(
    padding: const EdgeInsets.all(24.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      // si ringraziano i commenti al source code di flutter
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
              child: Container(
            // hehe le shader crashano con transparent.
            /*foregroundDecoration: BoxDecoration(
                color: starLevel > 0 ? Colors.transparent : Colors.grey,
                backgroundBlendMode: BlendMode.saturation,
              ),*/
            child: Text(emoji, style: TextStyle(fontSize: 48.0)),
          )

              //child: Text(emoji, style: TextStyle(fontSize: 48.0)),
              ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("⭐" * (starLevel - 1)),
//                  AnimatedSize(
//                    vsync: tp,
//                    child: Text("⭐" * 1),
//                    curve: Curves.decelerate,
//                    duration: Duration(milliseconds: 500),
//                  ),
                AnimatedBuilder(
                  animation: animation,
                  child: Text("⭐" * 1),
                  builder: (context, child) {
                    double d = animation.value * 2;
                    return Transform.scale(
                      scale: d + 1,
                      child: child, //Text("⭐" * 1),
                    );
                  },
                ),
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
          star.currentLimit == null
              ? '$description (${stat.count})'
              : '$description (${stat.count}/${star.currentLimit})',
          style: TextStyle(color: Colors.black54, fontSize: 10.0),
        ),
        SizedBox(
          height: 16.0,
        ),
        Text(
          longDescription,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontSize: 12.0),
        )
      ],
    ),
  );
}
