import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GesturePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GestureState();
  }
}

class _GestureState extends State<GesturePage> with SingleTickerProviderStateMixin {
  TabController tabController;

  var dx = 0.0;
  var dy = 0.0;
  var scale = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Material(
      child: Scaffold(
        body: GestureDetector(
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
                    scale: 0.88 + 0.12 * dx / screenWidth < 0.88? 0.88: 0.88 + 0.12 * dx / screenWidth,
                    child: Container(
                      child: Image.asset("assets/left.png",fit: BoxFit.fill,),
                      foregroundDecoration: BoxDecoration(
                          color: Color.fromRGBO(
                              0, 0, 0,1-(dx/screenWidth)),
                          borderRadius: BorderRadius.circular(20.0), //3像素圆角
                          boxShadow: [
                            //阴影
                            BoxShadow(color: Colors.black54, offset: Offset(2.0, 2.0), blurRadius: 4.0)
                          ]),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(dx>0?dx:dx/5, 0),
                  child: Container(
                    height: screenHeight,
                    color: Colors.transparent,
                    child: Image.asset("assets/middle.png",fit: BoxFit.fitHeight,),
                  ),
                ),
                Transform.translate(
                    offset: Offset(max(0, dx + screenWidth), 0),
                    child: Container(
                      height: screenHeight,
                      color: Colors.transparent,
                      child: Image.asset("assets/right.png",fit: BoxFit.fitHeight,),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}