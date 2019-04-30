import 'package:flutter/material.dart';
import 'package:tiktok_gestures/page/detail_page.dart';
import 'dart:math';
import 'middle_page.dart';
import 'package:tiktok_gestures/helper/transparent_page.dart';

/// 用户页
///
/// 包含的交互包括：
/// - 和主页面[MiddlePage]的视差效果
/// - 和详情页[DetailPage]的[Hero]过渡
class RightPage extends StatelessWidget{

  final double offsetX;
  final double offsetY;

  const RightPage({Key key, this.offsetX, this.offsetY}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return buildRightPage(screenWidth,screenHeight,context);
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
              // 以下是用来进行Hero交互用的
              Positioned(
                  bottom: 190,
                  child: FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      // 由于[MaterialPageRoute]等等的背景都是不透明的,所以这里修改了一下
                      Navigator.push(context, TransparentPage(builder:(BuildContext context) {
                        return DetailPage(index: 0,);
                      },fullscreenDialog: true));
                    },
                    child: SizedBox(
                      width: 130,
                      height: 175,
                      child: Hero(
                        tag: "detail_0",
                        child: Image.asset(
                          "assets/detail.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )),
              Positioned(
                  bottom: 190,
                  left: 130,
                  child: FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      Navigator.push(context, TransparentPage(builder:(BuildContext context) {
                        return DetailPage(index: 1,);
                      },fullscreenDialog: true));
                    },
                    child: SizedBox(
                      width: 130,
                      height: 175,
                      child: Hero(
                        tag: "detail_1",
                        child: Image.asset(
                          "assets/detail2.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }

}