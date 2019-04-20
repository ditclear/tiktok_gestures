### 写在前面

Flutter 是 Google推出并开源的移动应用开发框架，主打跨平台、高保真、高性能。开发者可以通过 Dart语言开发 App，一套代码同时运行在 iOS 和 Android平台。

> Flutter官网：https://flutter-io.cn

抖音，英文名TikTok，一款火遍全球的短视频App。在玩抖音的日子里，最令我感到舒服的就是抖音的手势交互，加上近期都在进行Flutter方面的学习，因此就产生了使用Flutter来仿写TikTok手势交互的想法。

来看看实现的效果：

![](https://media.giphy.com/media/Y0nMQwaOg14vWmwQDz/giphy.gif)



> Gif：<https://giphy.com/gifs/Y0nMQwaOg14vWmwQDz>
>
> Github地址：<https://github.com/ditclear/tiktok_gestures>

### GestureDetector以及Transform

既然是手势交互，那么就必然要检测手势，在Flutter中提供了`GestureDetector`来帮助开发者，并提供了多个回

调来处理手势。

| Property/Callback      | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| onTapDown              | 用户每次和屏幕交互时都会被调用                               |
| onTapUp                | 用户停止触摸屏幕时触发                                       |
| onTap                  | 短暂触摸屏幕时触发                                           |
| onTapCancel            | 用户触摸了屏幕，但是没有完成Tap的动作时触发                  |
| onDoubleTap            | 用户在短时间内触摸了屏幕两次                                 |
| onLongPress            | 用户触摸屏幕时间超过500ms时触发                              |
| onVerticalDragDown     | 当一个触摸点开始跟屏幕交互，同时在垂直方向上移动时触发       |
| onVerticalDragStart    | 当触摸点开始在垂直方向上移动时触发                           |
| onVerticalDragUpdate   | 屏幕上的触摸点位置每次改变时，都会触发这个回调               |
| onVerticalDragEnd      | 当用户停止移动，这个拖拽操作就被认为是完成了，就会触发这个回调 |
| onVerticalDragCancel   | 用户突然停止拖拽时触发                                       |
| onHorizontalDragDown   | 当一个触摸点开始跟屏幕交互，同时在水平方向上移动时触发       |
| onHorizontalDragStart  | 当触摸点开始在水平方向上移动时触发                           |
| onHorizontalDragUpdate | 屏幕上的触摸点位置每次改变时，都会触发这个回调               |
| onHorizontalDragEnd    | 水平拖拽结束时触发                                           |
| onHorizontalDragCancel | onHorizontalDragDown没有成功完成时触发                       |
| onPanDown              | 当触摸点开始跟屏幕交互时触发                                 |
| onPanStart             | 当触摸点开始移动时触发                                       |
| onPanUpdate            | 屏幕上的触摸点位置每次改变时，都会触发这个回调               |
| onPanEnd               | pan操作完成时触发                                            |
| onScaleStart           | 触摸点开始跟屏幕交互时触发，同时会建立一个焦点为1.0          |
| onScaleUpdate          | 跟屏幕交互时触发，同时会标示一个新的焦点                     |
| onScaleEnd             | 触摸点不再跟屏幕有任何交互，同时也表示这个scale手势完成      |

`GestureDetector`并不会监听上面所有的手势，只有传入的callbacks非空时，才会监听。所以，如果你想要禁用某个手势时，可以给对应的callback传null。

本文主要关注的的是拖动相关的，比如`onPanXX`、`onHorizontalDragXX`、`onVerticalDragXX`等等回调事件。

**Transform**可以在其子Widget绘制时对其应用一个矩阵变换（transformation）,Matrix4是一个4D矩阵，通过它我们可以实现各种矩阵操作。

```dart
Container(
  color: Colors.black,
  child: new Transform(
    alignment: Alignment.topRight, //相对于坐标系原点的对齐方式
    transform: new Matrix4.skewY(0.3), //沿Y轴倾斜0.3弧度
    child: new Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.deepOrange,
      child: const Text('Apartment for rent!'),
    ),
  ),
);
```

效果如下：

![](https://cdn.jsdelivr.net/gh/flutterchina/flutter-in-action@1.0/docs/imgs/image-20180910160248494.png)



在Flutter中提供了一些封装好的transform效果供开发者选择，比如：平移(translate)、旋转(rotate)、缩放(scale)。

在了解了这两点之后，我们来逐步分解前文的效果。

### 交互分解

首先，需要明确的是这些交互效果其实都是通过检测手指的滑动，得到一个x坐标或者y坐标的偏移量，然后配合Transform进行各种不同的变换，明白了这一点，想做到这样的效果并不难。

- 首页的交互

![](https://media.giphy.com/media/iFgOIQ7abZx0i98MCA/giphy.gif)

> Gif :https://media.giphy.com/media/iFgOIQ7abZx0i98MCA/giphy.gif

这里的交互都是横向的滑动，因此这里主要处理`onHorizontalDragXX`相关的事件。

然后来看看首页的布局：



![](https://upload-images.jianshu.io/upload_images/3722695-4228fb154d98c073.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> Left:拍摄页  Middle:主页  Right：用户页

外层是一个`GestureDetector`用于处理整个页面的手势，里面用的是一个`Stack`，类似于Android中的`FrameLayout`，它包含3个`Transform`的子Widget。

![](https://upload-images.jianshu.io/upload_images/3722695-5fd29ca780f76d7e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/580)

这里选取拍摄页(left)来具体谈谈.

通过观察可以发现，**随着偏移量的改变，这里其实包含两个变化：1.缩放 2. 前景色透明度**。

缩放可以直接采用前文提到的`Transform.scale`，前景色可以用`foregroundDecoration`通过改变Color的透明度来达到效果，看看实现：

```dart
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
```

当我们的手指在横向移动的时候，记录下偏移总量`offsetX`，然后通过setState进行更新。

```dart
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
}
```

通过setState更新偏移量offsetX之后，Flutter便会重新渲染视图，从而达到上图的效果。

- Hero动画

![](https://media.giphy.com/media/Q7LdOFFBM4HB8xGSpg/giphy.gif)

> Gif：<https://media.giphy.com/media/Q7LdOFFBM4HB8xGSpg/giphy.gif>

Flutter提供了Hero动画来实现这样的过渡效果。Hero指的是可以在路由(页面)之间“飞行”的widget，简单来说Hero动画就是在路由切换时，有一个共享的Widget可以在新旧路由间切换，由于共享的Widget在新旧路由页面上的位置、外观可能有所差异，所以在路由切换时会逐渐过渡，这样就会产生一个Hero动画。

```dart
/// tiktok_page.dart
Widget build(BuildContext context) {
		return	Hero(
              tag: "detail",
              //child
            )
 )               
 
 /// detail_page.dart
 Widget build(BuildContext context) {
	return Hero(
      tag: "detail",
      // child
        )
  }
```

保证tag一致就可以了。

- 详情页的交互

![](https://media.giphy.com/media/h4HMGtcLLcQQmqTZTI/giphy.gif)

> Gif :https://media.giphy.com/media/h4HMGtcLLcQQmqTZTI/giphy.gif

跟首页一样的思路，只是这里的手势是垂直方向。

布局同样是`GestureDetector`加上`Stack`再配合`Transform.translate`。

```dart
Hero(
      tag: "detail",
      child: GestureDetector(
        onVerticalDragUpdate: (details){
          // dy 不超过 -screenHeight * 0.6
          dy += details.delta.dy;
          if ((dy < 0 && dy.abs() > screenHeight * 0.6)) {
            dy = -screenHeight * 0.6;
          } else {
            setState(() {});
          }
        },
        child: Stack(
          children: <Widget>[
            Image.asset(
              "assets/detail.png",
              fit: BoxFit.fitWidth,
              width: screenWidth,
              height: screenHeight,
            ),
            Transform.translate(
              offset: Offset(0, dy + screenHeight),
              child: Container(
                  height: screenHeight * 0.6,
                  child: GestureDetector(
                    onTap: () {},
                    child: Image.asset(
                        "assets/comment.png",),
                  )
              ),
            ),
          ],
        ),
      ),
    );
```

在手指离开屏幕时，根据偏移利用动画进行调整。

```dart
onVerticalDragEnd: (_){
          // 滑动截止时，根据 dy 判断是展开还是回缩
          if (dy < 0) {
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
```

### 写在最后

总的来说，这些交互都是依靠着对手势的检测做到的，相比于Android，Flutter有着一切都是Widget的概念，

`GestureDetector`以及`Hero`都是Widget而且提供了很多回调函数，再配合数据驱动UI和Flutter优秀的渲染机制，减轻了开发者进行手势交互的难度。

Github地址：<https://github.com/ditclear/tiktok_gestures>

如果本文对你有帮助，请点赞支持。

#### 参考资料：

- Flutter实战：<https://book.flutterchina.club/>
- 解析Flutter中的手势控制Gestures：<https://www.jianshu.com/p/228b2d043bca>

==================== 分割线 ======================

如果你想了解更多关于MVVM、Flutter、响应式编程方面的知识，欢迎关注我。

##### 你可以在以下地方找到我：

简书：https://www.jianshu.com/u/117f1cf0c556

掘金：https://juejin.im/user/582d601d2e958a0069bbe687

Github: https://github.com/ditclear

![](http://upload-images.jianshu.io/upload_images/3722695-812afe12bc7a15fb?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)























