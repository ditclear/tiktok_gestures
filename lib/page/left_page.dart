import 'dart:math';
import 'package:flutter/material.dart';

/// 拍摄页
///
/// 包含的交互包括：前景色,scale
class LeftPage extends StatelessWidget{
  final double offsetX;

  const LeftPage({Key key, this.offsetX}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return buildLeftPage(screenWidth);
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
          fit: BoxFit.fitWidth,
          width: screenWidth,
        ),
        foregroundDecoration: BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 1 - (offsetX / screenWidth)),
        ),
      ),
    );
  }
}