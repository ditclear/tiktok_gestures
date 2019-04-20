import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiktok_gestures/detail_page.dart';
import 'package:flutter/cupertino.dart';

/// 首页
///
/// 展示类似TikTok的手势交互效果
class TikTokPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TikTokState();
  }
}

class _TikTokState extends State<TikTokPage> with TickerProviderStateMixin {

  AnimationController animationController;
  Animation<double> animation;
  double offsetX = 0.0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      child: Scaffold(
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            // 当滑动停止的时候 根据 offsetX 的偏移量进行动画
            // 为了方便这里取 screenWidth / 2为临界条件
            if (offsetX.abs() < screenWidth / 2) {
              animateToMiddle();
            } else if (offsetX > 0) {
              animateToLeft(screenWidth);
            } else {
              animateToRight(screenWidth);
            }
          },
          onHorizontalDragStart: (_) {
            animationController?.stop();
          },
          onHorizontalDragUpdate: (details) {
            // 控制 offsetX 的值在 -screenWidth 到 screenWidth 之间
            if (offsetX + details.delta.dx >= screenWidth) {
              setState(() {
                offsetX = screenWidth;
              });
            } else if (offsetX + details.delta.dx <= -screenWidth) {
              setState(() {
                offsetX = -screenWidth;
              });
            } else {
              setState(() {
                offsetX += details.delta.dx;
              });
            }
          },
          child: Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                buildLeftPage(screenWidth),
                buildMiddlePage(),
                buildRightPage(screenWidth, screenHeight, context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 左侧Widget
  ///
  /// 通过 [Transform.scale] 进行根据 [offsetX] 缩放
  /// 最小 0.88 最大为 1
  Transform buildLeftPage(double screenWidth) {
    return Transform.scale(
      scale: 0.88 + 0.12 * offsetX / screenWidth < 0.88 ? 0.88 : 0.88 + 0.12 * offsetX / screenWidth,
      child: Container(
        child: Image.asset(
          "assets/left.png",
          fit: BoxFit.fill,
        ),
        foregroundDecoration: BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 1 - (offsetX / screenWidth)),
           ),
      ),
    );
  }

  /// 中间 Widget
  ///
  /// 通过 [Transform.translate] 根据 [offsetX] 进行偏移
  /// 水平偏移量为 [ offsetX] /5 产生视差效果
  Transform buildMiddlePage() {
    return Transform.translate(
                offset: Offset(offsetX > 0 ? offsetX : offsetX / 5, 0),
                child: PageView(
                  children: List(10)
                      .map((_) => Container(
                            child: Image.asset(
                              "assets/middle.png",
                              fit: BoxFit.fill,
                            ),
                          ))
                      .toList(),
                  scrollDirection: Axis.vertical,
                ),
              );
  }

  /// 右侧Widget
  ///
  /// 通过 [Transform.translate] 根据 [offsetX] 进行偏移
  Transform buildRightPage(double screenWidth, double screenHeight, BuildContext context) {
    return Transform.translate(
                  offset: Offset(max(0, offsetX + screenWidth), 0),
                  child: Container(
                    width: screenWidth,
                    height: screenHeight,
                    color: Colors.transparent,
                    child: Stack(
                      children: <Widget>[
                        Image.asset(
                          "assets/right.png",
                          fit: BoxFit.fill,
                          width: screenWidth,
                        ),
                        Positioned(
                            bottom: 190,
                            child: FlatButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return DetailPage();
                                    })
                                );
                              },
                              child: SizedBox(
                                width: 130,
                                height: 175,
                                child: Hero(
                                  tag: "detail",
                                  child: Image.asset(
                                    "assets/detail.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ))
                      ],
                    ),
                  ));
  }

  /// 滑动到中间
  void animateToMiddle() {
    animationController = AnimationController(duration: Duration(milliseconds: offsetX.abs() * 1000 ~/ 500), vsync: this);
    final curve = CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic);
    animation = Tween(begin: offsetX, end: 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          offsetX = animation.value;
        });
      });
    animationController.forward();
  }

  /// 滑动到左边
  void animateToLeft(double screenWidth) {
    animationController = AnimationController(duration: Duration(milliseconds: offsetX.abs() * 1000 ~/ 500), vsync: this);
    final curve = CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic);
    animation = Tween(begin: offsetX, end: screenWidth).animate(curve)
      ..addListener(() {
        setState(() {
          offsetX = animation.value;
        });
      });
    animationController.forward();
  }

  /// 滑动到右边
  void animateToRight(double screenWidth) {
    animationController = AnimationController(duration: Duration(milliseconds: offsetX.abs() * 1000 ~/ 500), vsync: this);
    final curve = CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic);
    animation = Tween(begin: offsetX, end: -screenWidth).animate(curve)
      ..addListener(() {
        setState(() {
          offsetX = animation.value;
        });
      });
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

}
