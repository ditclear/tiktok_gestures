import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiktok_gestures/page/detail_page.dart';
import 'package:tiktok_gestures/helper/transparent_page.dart';
import 'package:tiktok_gestures/page/left_page.dart';
import 'package:tiktok_gestures/page/middle_page.dart';
import 'package:tiktok_gestures/page/right_page.dart';
import 'package:vibrate/vibrate.dart';

/// 首页
///
/// 展示类似TikTok的手势交互效果
/// 包含 拍摄页[LeftPage]、主页[MiddlePage]、用户页[RightPage]
class TikTokPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TikTokState();
  }
}

class _TikTokState extends State<TikTokPage> with TickerProviderStateMixin {
  AnimationController animationControllerX;
  AnimationController animationControllerY;
  Animation<double> animationX;
  Animation<double> animationY;
  double offsetX = 0.0;
  double offsetY = 0.0;
  int currentIndex = 0;
  bool inMiddle = true;



  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      child: Scaffold(
        body: GestureDetector(
          // 垂直方向滑动中
          onVerticalDragUpdate: inMiddle
              ? (details) {
                  final tempY = offsetY + details.delta.dy / 2;
                  if (currentIndex == 0) {
                    if (tempY > 0) {
                      if (tempY < 40) {
                        setState(() {
                          offsetY = tempY;
                        });
                      } else if (offsetY != 40) {
                        setState(() {
                          setState(() {
                            offsetY = 40;
                          });
                        });
                        vibrate();
                      }
                    }
                  } else {
                    offsetY = 0;
                  }
                }
              : null,
          // 垂直方向滑动结束
          onVerticalDragEnd: (_) {
            if (offsetY != 0) {
              animateToTop();
            }
          },
          // 水平方向滑动结束
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
          // 水平方向滑动开始
          onHorizontalDragStart: (_) {
            animationControllerX?.stop();
          },
          // 水平方向滑动中
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
          child: Stack(
            children: <Widget>[
              buildLeftPage(),
              buildMiddlePage(),
              buildRightPage(),
            ],
          ),
        ),
      ),
    );
  }

  /// 左侧Widget
  ///
  /// 通过 [Transform.scale] 进行根据 [offsetX] 缩放
  /// 最小 0.88 最大为 1
  Widget buildLeftPage() =>LeftPage(offsetX: offsetX,);

  /// 中间 Widget
  ///
  /// 通过 [Transform.translate] 根据 [offsetX] 进行偏移
  /// 水平偏移量为 [ offsetX] /5 产生视差效果
  Widget buildMiddlePage()=>MiddlePage(offsetX: offsetX,offsetY: offsetY);

  /// 右侧Widget
  ///
  /// 通过 [Transform.translate] 根据 [offsetX] 进行偏移
  buildRightPage()=>RightPage(offsetX: offsetX,offsetY: offsetY);



  /// 滑动到中间
  ///
  /// [offsetX] to 0.0
  void animateToMiddle() {
    animationControllerX =
        AnimationController(duration: Duration(milliseconds: offsetX.abs() * 1000 ~/ 500), vsync: this);
    final curve = CurvedAnimation(parent: animationControllerX, curve: Curves.easeOutCubic);
    animationX = Tween(begin: offsetX, end: 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          offsetX = animationX.value;
        });
      });
    inMiddle = true;
    animationControllerX.forward();
  }

  /// 滑动到左边
  ///
  /// [offsetX] to [screenWidth]
  void animateToLeft(double screenWidth) {
    animationControllerX =
        AnimationController(duration: Duration(milliseconds: offsetX.abs() * 1000 ~/ 500), vsync: this);
    final curve = CurvedAnimation(parent: animationControllerX, curve: Curves.easeOutCubic);
    animationX = Tween(begin: offsetX, end: screenWidth).animate(curve)
      ..addListener(() {
        setState(() {
          offsetX = animationX.value;
        });
      });
    inMiddle = false;
    animationControllerX.forward();
  }

  /// 滑动到右边
  ///
  /// [offsetX] to -[screenWidth]
  void animateToRight(double screenWidth) {
    animationControllerX =
        AnimationController(duration: Duration(milliseconds: offsetX.abs() * 1000 ~/ 500), vsync: this);
    final curve = CurvedAnimation(parent: animationControllerX, curve: Curves.easeOutCubic);
    animationX = Tween(begin: offsetX, end: -screenWidth).animate(curve)
      ..addListener(() {
        setState(() {
          offsetX = animationX.value;
        });
      });
    inMiddle = false;
    animationControllerX.forward();
  }

  /// 滑动到顶部
  ///
  /// [offsetY] to 0.0
  void animateToTop() {
    animationControllerY =
        AnimationController(duration: Duration(milliseconds: offsetY.abs() * 1000 ~/ 40), vsync: this);
    final curve = CurvedAnimation(parent: animationControllerY, curve: Curves.easeOutCubic);
    animationY = Tween(begin: offsetY, end: 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          offsetY = animationY.value;
        });
      });
    animationControllerY.forward();
  }

  /// 震动效果
  vibrate() {
    // Not check if the device can vibrate
    Vibrate.feedback(FeedbackType.impact);
  }

  @override
  void dispose() {
    animationControllerX.dispose();
    animationControllerY.dispose();
    super.dispose();
  }



}