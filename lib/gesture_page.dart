import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiktok_gestures/detail_page.dart';
import 'package:flutter/cupertino.dart';

class GesturePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GestureState();
  }
}

class _GestureState extends State<GesturePage> with TickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var dx = 0.0;
  var dy = 0.0;
  var scale = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }

  /// 评论框是否显示
  bool isBottomSheetShowing = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      child: Scaffold(
        key: _scaffoldKey,
        body: GestureDetector(
          onPanEnd: (details) {
            if (dx.abs() < screenWidth / 2) {
              animateToMiddle();
            } else if (dx > 0) {
              animateToLeft(screenWidth);
            } else {
              animateToRight(screenWidth);
            }
          },
          onPanStart: (_) {
            animationController?.stop();
          },
          onPanUpdate: (details) {
            if (dx + details.delta.dx >= screenWidth) {
              setState(() {
                dx = screenWidth;
              });
            } else if (dx + details.delta.dx <= -screenWidth) {
              setState(() {
                dx = -screenWidth;
              });
            } else {
              setState(() {
                dx += details.delta.dx;
              });
            }
          },
          child: Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Transform.scale(
                    scale: 0.88 + 0.12 * dx / screenWidth < 0.88 ? 0.88 : 0.88 + 0.12 * dx / screenWidth,
                    child: Container(
                      child: Image.asset(
                        "assets/left.png",
                        fit: BoxFit.fill,
                      ),
                      foregroundDecoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 1 - (dx / screenWidth)),
                          borderRadius: BorderRadius.circular(20.0),
                          //3像素圆角
                          boxShadow: [
                            //阴影
                            BoxShadow(color: Colors.black54, offset: Offset(2.0, 2.0), blurRadius: 4.0)
                          ]),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(dx > 0 ? dx : dx / 5, 0),
                  child: PageView(
                    children: List(10)
                        .map((_) => Container(
                              color: Colors.yellow,
                              child: Image.asset(
                                "assets/middle.png",
                                fit: BoxFit.fitHeight,
                              ),
                            ))
                        .toList(),
                    scrollDirection: Axis.vertical,
                  ),
                ),
                Transform.translate(
                    offset: Offset(max(0, dx + screenWidth), 0),
                    child: Container(
                      height: screenHeight,
                      color: Colors.transparent,
                      child: Stack(
                        children: <Widget>[
                          Image.asset(
                            "assets/right.png",
                            fit: BoxFit.fitHeight,
                          ),
                          Positioned(
                              bottom: 190,
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  Navigator.push(context, PageRouteBuilder(
                                      pageBuilder: (BuildContext context, Animation animation,
                                          Animation secondaryAnimation) {
                                        return DetailPage();
                                      })
                                  );
                                },
                                child: SizedBox(
                                  width: 130,
                                  height: 170,
                                  child: Hero(
                                    tag: "detail",
                                    child: Image.asset(
                                      "assets/detail.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 滑动到中间
  void animateToMiddle() {
    animationController = AnimationController(duration: Duration(milliseconds: dx.abs() * 1000 ~/ 500), vsync: this);
    final curve = CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic);
    animation = Tween(begin: dx, end: 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          dx = animation.value;
        });
      });
    animationController.forward();
  }

  /// 滑动到左边
  void animateToLeft(double screenWidth) {
    animationController = AnimationController(duration: Duration(milliseconds: dx.abs() * 1000 ~/ 500), vsync: this);
    final curve = CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic);
    animation = Tween(begin: dx, end: screenWidth).animate(curve)
      ..addListener(() {
        setState(() {
          dx = animation.value;
        });
      });
    animationController.forward();
  }

  /// 滑动到右边
  void animateToRight(double screenWidth) {
    animationController = AnimationController(duration: Duration(milliseconds: dx.abs() * 1000 ~/ 500), vsync: this);
    final curve = CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic);
    animation = Tween(begin: dx, end: -screenWidth).animate(curve)
      ..addListener(() {
        setState(() {
          dx = animation.value;
        });
      });
    animationController.forward();
  }
}
