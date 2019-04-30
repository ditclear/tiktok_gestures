import 'dart:math';

import 'package:flutter/material.dart';

/// 主页面
///
/// 手势交互包括：下拉刷新，和左右两侧的translate动画
class MiddlePage extends StatelessWidget {
  final double offsetX;
  final double offsetY;
  final Function onPageChanged;
  const MiddlePage({Key key, this.offsetX, this.offsetY,this.onPageChanged }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildMiddlePage();
  }

  /// 中间 Widget
  ///
  /// 通过 [Transform.translate] 根据 [offsetX] 进行偏移
  /// 水平偏移量为 [ offsetX] /5 产生视差效果
  Transform buildMiddlePage() {
    return Transform.translate(
      offset: Offset(offsetX > 0 ? offsetX : offsetX / 5, 0),
      child: Stack(
        children: <Widget>[
          Container(
            child: Column(
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Expanded(
                  child: PageView(
                    onPageChanged: onPageChanged,
                    pageSnapping: true,
                    physics: ClampingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                      children: List.generate(
                    10,
                    (_) => Image.asset(
                          "assets/middle.png",
                          fit: BoxFit.fill,
                        ),
                  )),
                ),
                Image.asset(
                  "assets/bottom.png",
                  fit: BoxFit.fill,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: buildHeader(),
          )
        ],
      ),
    );
  }

  /// 顶部header
  Widget buildHeader() {
    if (offsetY >= 20) {
      return Opacity(
        opacity: (offsetY - 20) / 20,
        child: Transform.translate(
          offset: Offset(0, offsetY),
          child: Container(
            height: 44,
            child: Center(
              child: const Text(
                "下拉刷新内容",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      );
    } else {
      return Opacity(
        opacity: max(0, 1 - offsetY / 20),
        child: Transform.translate(
          offset: Offset(0, offsetY),
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 18, color: Colors.grey),
            child: Container(
              height: 44,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 5, 0),
                    child: Icon(
                      Icons.camera_alt,
                      size: 24,
                    ),
                  ),
                  const Text('随拍'),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "推荐",
                          style: TextStyle(color: Colors.white),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 1,
                          height: 12,
                          color: Colors.white24,
                        ),
                        Text("上海"),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.live_tv,
                    size: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 24, 0),
                    child: Icon(
                      Icons.search,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
