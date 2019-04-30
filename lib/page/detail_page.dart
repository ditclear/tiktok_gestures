import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'right_page.dart';

enum DragState {
  /// 拖动返回
  Back,

  /// 正常情况
  Normal,

  /// 上拉comment布局
  PullUp
}

/// 详情页面
///
/// 接收来自[RightPage]传递来的[index]参数，用于演示[Hero]效果
/// 本页的手势交互有：下拉返回、上拉显示评论
class DetailPage extends StatefulWidget {
  final int index;

  const DetailPage({Key key, this.index}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DetailState();
  }
}

class _DetailState extends State<DetailPage> with TickerProviderStateMixin {

  double offsetY = 0.0;
  double offsetX = 0.0;
  AnimationController animationController;
  Animation<double> animation;
  Animation<double> animationX;
  bool isCommentShow = false;
  /// 进行hero动画
  int currentIndex;

  var dragState = DragState.Normal;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Transform.scale(
      scale: dragState == DragState.Normal ? 1 : min(1, 1 - 0.5 * offsetY.abs() / screenHeight),
      child: Transform.translate(
        offset: dragState == DragState.Back ? Offset(offsetX, offsetY) : Offset(0, max(0, offsetY)),
        child: Hero(
          tag: "detail_$currentIndex",
          child: GestureDetector(
            onTap: () {
              // 如果 isCommentShow 为true ,代表 评论布局已经展开，点击的时候先关闭 评论布局
              if (isCommentShow) {
                animateToBottom(screenHeight);
              }
            },
            onPanDown: (_) {
              dragState = DragState.Normal;
            },
            // 滑动开始时
            onPanStart: (details) {
              animationController?.stop();
            },
            // 滑动截止时
            onPanEnd: (_) {
              dispatchPanEnd(context, screenHeight);
            },
            // 滑动中
            onPanUpdate: (details) {
              if (offsetY == 0.0 && details.delta.dy > 0 && dragState == DragState.Normal) {
                dragState = DragState.Back;
              }
              if (dragState == DragState.Back) {
                offsetX += details.delta.dx;
              }
              // dy 不超过 -screenHeight * 0.6
              offsetY += details.delta.dy;
              if (offsetY < 0 && offsetY.abs() > screenHeight * 0.6) {
                offsetY = -screenHeight * 0.6;
                offsetX = 0;
              } else {}

              setState(() {});
            },
            child: Stack(
              children: <Widget>[
                AbsorbPointer(
                  //  offsetY != 0 || offsetX != 0 ||isCommentShow 时，禁止PageView滑动
                  absorbing: offsetY != 0 || offsetX != 0 ||isCommentShow,
                  child: SizedBox(
                    width: screenWidth,
                    height: screenHeight,
                    child: PageView(
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = (widget.index + index) % 2;
                        });
                      },
                      children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((index) {
                        return Image.asset(
                          (index + widget.index) % 2 == 0 ? "assets/detail.png" : "assets/detail2.png",
                          fit: BoxFit.fitWidth,
                          width: screenWidth,
                          height: screenHeight,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                dragState != DragState.Back ? buildTransformComment(screenHeight, screenWidth) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 滑动截止时，根据[offsetY]进行处理
  void dispatchPanEnd(BuildContext context, double screenHeight) {
    if (offsetY > 100) {
      // 下拉距离超过100，即退出页面
      Navigator.pop(context);
    } else if (offsetY > 0) {
      // 下拉距离小于100，恢复原样
      animateToBottom(screenHeight);
    } else if (dragState == DragState.Back) {
      Navigator.pop(context);
    } else if (offsetY < 0) {
      // 上拉根据是否已经显示评论框 [isCommentShow]和offsetY来判断是展开还是收缩
      if (!isCommentShow && offsetY.abs() > screenHeight * 0.2) {
        if (offsetY.abs() > screenHeight * 0.2) {
          animateToTop(screenHeight);
        } else {
          animateToBottom(screenHeight);
        }
      } else {
        if (offsetY.abs() > screenHeight * 0.4) {
          animateToTop(screenHeight);
        } else {
          animateToBottom(screenHeight);
        }
      }
    }
  }

  /// comment 布局
  Transform buildTransformComment(double screenHeight, double screenWidth) {
    return Transform.translate(
      offset: Offset(0, offsetY > 0 ? screenHeight : offsetY + screenHeight),
      child: Container(
          height: screenHeight * 0.6,
          child: GestureDetector(
            onTap: () {},
            child: Image.asset(
              "assets/comment.png",
              fit: BoxFit.fitWidth,
              width: screenWidth,
            ),
          )),
    );
  }

  /// 将comment布局滑动到顶部
  ///
  /// 动画结束后 [isCommentShow] 为 true
  void animateToTop(double screenHeight) {
    animationController =
        AnimationController(duration: Duration(milliseconds: offsetY.abs() * 1000 ~/ 800), vsync: this);
    final curve = CurvedAnimation(parent: animationController, curve: Curves.decelerate);
    animation = Tween(begin: offsetY, end: -screenHeight * 0.6).animate(curve)
      ..addListener(() {
        setState(() {
          offsetY = animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          isCommentShow = true;
        }
      });
    animationController.forward(from: offsetY);
  }

  /// 将comment布局滑动到底部
  ///
  /// 动画结束后 [isCommentShow] 为 false
  void animateToBottom(double screenHeight) {
    animationController = AnimationController(duration: Duration(milliseconds: offsetY.abs().floor()), vsync: this);
    final curve = CurvedAnimation(parent: animationController, curve: Curves.decelerate);
    animation = Tween(begin: offsetY, end: 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          offsetY = animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          isCommentShow = false;
        }
      });
    animationX = Tween(begin: offsetX, end: 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          offsetX = animationX.value;
        });
      });
    animationController.forward(from: offsetY);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }
}
