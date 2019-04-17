import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DetailState();
  }
}

class _DetailState extends State<DetailPage> {
  double dx = 0.0;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Hero(
      tag: "detail",
      child: Transform.scale(
        scale: 1-dx.abs()/screenWidth,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onPanUpdate: (details){
//              setState(() {
//                dx+=details.delta.dx;
//              });
            },
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Stack(
              children: <Widget>[
                Image.asset(
                  "assets/detail.png",
                  fit: BoxFit.contain,
                ),
                Positioned(
                    right: 10,
                    bottom: 230,
                    child: FlatButton(
                      color: Colors.red.withAlpha(100),
                      onPressed: () {
                        buildShowModalBottomSheet(context, screenHeight);
                      },
                      child: const Text(
                        'click me',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }


  /// 显示评论框
  Future<void> buildShowModalBottomSheet(BuildContext context, double screenHeight) {
    return showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: screenHeight * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.transparent,
              ),
              child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('This is the modal bottom sheet. Tap anywhere to dismiss.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).accentColor, fontSize: 24.0))));
        });
  }

}
