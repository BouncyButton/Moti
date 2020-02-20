import 'dart:math';

import 'package:fluffy_bunny/TaskCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vector_math/vector_math_64.dart';

class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final SlidableController sc;
  final int index;
  final String repeat;

  ShakeAnimation({this.child, this.sc, this.index, this.repeat});

  @override
  _ShakeAnimationState createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with TickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;
  bool hasBeenShaken = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..addListener(() => setState(() {}));
    // non una best practice.

//    animation = Tween<double>(
//      begin: 50.0,
//      end: 120.0,
//    ).animate(animationController);
  }

  loop() {
    if (mounted && widget.repeat == 'once'
        /*&& widget.sc.isSlideOpen == null
        ? true
        : !widget.sc.isSlideOpen*/
        ) {
      animationController.forward().whenCompleteOrCancel(() {
        if (mounted && widget.repeat == 'once'
/*&& widget.sc.isSlideOpen == null
            ? true
            : !widget.sc.isSlideOpen*/
            ) {
          Future.delayed(
              Duration(
                milliseconds: 1500,
              ), () {
            if (widget.repeat == 'once') {
              if (mounted) {
                animationController.reset();
                loop();
              }
            }
          });
        } else {
        }
      });
    } else {
    }
  }

  Vector3 _shake() {
    double progress = animationController.value;
    double offset = sin(progress * pi * 3.0);
    return Vector3(offset * 8, 0.0, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index == 0 && !hasBeenShaken && widget.repeat == 'once') {
      hasBeenShaken = true;
      loop();
    }

    return Transform(
        transform: Matrix4.translation(_shake()), child: widget.child);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class ShakerController {
  List<ShakeAnimation> list = [];

  firstIndex() {
    return list.map((w) => w.index).reduce(min);
  }
}
