import 'dart:math';

import 'package:flutter/material.dart';
import 'right_page.dart';
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
  /// 暂时没用到offsetX
  double offsetX = 0.0;
  AnimationController animationController;
  Animation<double> animation;
  bool isCommentShow = false;
  int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Transform.translate(
      offset: Offset(0, max(0, offsetY)),
      child: Hero(
        tag: "detail_$currentIndex",
        child: GestureDetector(
          onTap: () {
            // 如果 isCommentShow 为true ,代表 评论布局已经展开，点击的时候先关闭 评论布局
            // 否则返回到上个页面
            if (isCommentShow) {
              animateToBottom(screenHeight);
            }
          },
          // 滑动开始时
          onPanStart: (_) {
            animationController?.stop();
          },
          // 滑动截止时
          onPanEnd: (_) {

            if (offsetY > 100) {
              // 下拉距离超过100，即退出页面
              Navigator.pop(context);
            } else if (offsetY > 0) {
              // 下拉距离小于100，恢复原样
              animateToBottom(screenHeight);
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
          },
          // 滑动中
          onPanUpdate: (details) {
            // dy 不超过 -screenHeight * 0.6
            offsetY += details.delta.dy;
            offsetX += details.delta.dx;

            if (offsetY < 0 && offsetY.abs() > screenHeight * 0.6) {
              offsetY = -screenHeight * 0.6;
              offsetX = 0;
            } else {}
            setState(() {});
          },
          child: Stack(
            children: <Widget>[
              PageView(
                onPageChanged: (index){
                  setState(() {
                    currentIndex = (widget.index+index)%2;
                  });
                },
                children: [0,1,2,3,4,5,6,7,8,9]
                    .map((index) => Image.asset(
                          (index+widget.index)%2==0?"assets/detail.png":"assets/detail2.png",
                          fit: BoxFit.fitWidth,
                          width: screenWidth,
                          height: screenHeight,
                        ))
                    .toList(),
              ),
              offsetY != 0
                  ? Transform.translate(
                      offset: Offset(0, offsetY > 0 ? screenHeight : offsetY + screenHeight),
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
    animationController =
        AnimationController(duration: Duration(milliseconds: offsetY.abs().floor()), vsync: this);
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
    animationController.forward(from: offsetY);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }
}
