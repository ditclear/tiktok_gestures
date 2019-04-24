import 'dart:math';

import 'package:flutter/material.dart';

/// 详情页面
class DetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DetailState();
  }
}

class _DetailState extends State<DetailPage> with TickerProviderStateMixin {
  double dy = 0.0;
  double dx = 0.0;
  AnimationController animationController;
  Animation<double> animation;
  bool isCommentShow = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Transform.translate(
      offset: Offset(0, max(0, dy)),
      child: Hero(
        tag: "detail",
        child: GestureDetector(
          onTap: () {
            // 如果 isCommentShow 为true ,代表 评论布局已经展开，点击的时候先关闭 评论布局
            // 否则返回到上个页面
            if (isCommentShow) {
              animateToBottom(screenHeight);
            }
          },
          onPanStart: (_) {
            animationController?.stop();
          },
          onPanEnd: (_) {
            // 滑动截止时，根据 dy 判断是展开还是回缩
//            if(dx!=0){
//              Navigator.pop(context);
//            }else
            if(dy>100){
              Navigator.pop(context);
            }else if(dy>0){
              animateToBottom(screenHeight);
            }else if (dy < 0) {
              if (!isCommentShow && dy.abs() > screenHeight * 0.2) {
                if (dy.abs() > screenHeight * 0.2) {
                  animateToTop(screenHeight);
                } else {
                  animateToBottom(screenHeight);
                }
              } else {
                if (dy.abs() > screenHeight * 0.4) {
                  animateToTop(screenHeight);
                } else {
                  animateToBottom(screenHeight);
                }
              }
            }
          },
          onPanUpdate: (details) {
            // dy 不超过 -screenHeight * 0.6
            dy += details.delta.dy;
            dx += details.delta.dx;

            if (dy < 0 && dy.abs() > screenHeight * 0.6) {
              dy = -screenHeight * 0.6;
              dx = 0;
            } else {
            }
            setState(() {});
          },
          child: Stack(
            children: <Widget>[
              PageView(
                children:List(10).map((_)=>Image.asset(
                  "assets/detail.png",
                  fit: BoxFit.fitWidth,
                  width: screenWidth,
                  height: screenHeight,
                )).toList(),
              ),
              dy != 0
                  ? Transform.translate(
                      offset: Offset(0, dy > 0 ? screenHeight : dy + screenHeight),
                      child: Container(
                          height: screenHeight * 0.6,
                          child: GestureDetector(
                            onTap: () {},
                            child: Image.asset(
                              "assets/comment.png",
                              fit: BoxFit.fitHeight,
                            ),
                          )),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  /// 将comment布局滑动到顶部
  ///
  /// 动画结束后 [isCommentShow] 为 true
  void animateToTop(double screenHeight) {
    animationController = AnimationController(duration: Duration(milliseconds: dy.abs() * 1000 ~/ 800), vsync: this);
    final curve = CurvedAnimation(parent: animationController, curve: Curves.decelerate);
    animation = Tween(begin: dy, end: -screenHeight * 0.6).animate(curve)
      ..addListener(() {
        setState(() {
          dy = animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          isCommentShow = true;
        }
      });
    animationController.forward(from: dy);
  }

  /// 将comment布局滑动到底部
  ///
  /// 动画结束后 [isCommentShow] 为 false
  void animateToBottom(double screenHeight) {
    animationController = AnimationController(duration: Duration(milliseconds: dy.abs().floor()), vsync: this);
    final curve = CurvedAnimation(parent: animationController, curve: Curves.decelerate);
    animation = Tween(begin: dy, end: 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          dy = animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          isCommentShow = false;
        }
      });
    animationController.forward(from: dy);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }
}
