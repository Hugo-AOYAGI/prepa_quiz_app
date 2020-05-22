import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

import 'sizeControllers.dart';
import 'fontStyles.dart';


class PageTemplate extends StatelessWidget {

  final child;


  PageTemplate({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: windowHeight,
      width: windowWidth,
      child: child
    );
  }
}

class PaddedAlignBox extends StatelessWidget {

  final Widget child;
  final List<double> padding;
  final Alignment align;

  PaddedAlignBox({@required this.child, @required this.padding, @required this.align});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align,
      child: Padding(
        padding: EdgeInsets.only(left: padding[0], right: padding[1], top: padding[2], bottom: padding[3]),
        child: child
      )
    );
  }
}

class TitleAndSubtitle extends StatelessWidget {

  final String title;
  final String subtitle;
  final Alignment titleAlignment;
  final Alignment subtitleAlignment;
  final List<double> padding;

  TitleAndSubtitle({
    @required this.title,
    @required this.subtitle,
    @required this.titleAlignment,
    @required this.subtitleAlignment,
    @required this.padding
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 30*sizeCoeff),
        PaddedAlignBox(
          align: titleAlignment,
          padding: padding,
          child: Text(title, style: mainTitleFont,)
        ),
        PaddedAlignBox(
          align: subtitleAlignment,
          padding: [padding[0], 0, 0, 0],
          child: Text(subtitle, style: subtitleMain,)
        ),
      ],
    );
  }
}

class RoundedMenuBox extends StatelessWidget {

  final Widget child;
  final double width;
  final double height;
  final bool square;

  RoundedMenuBox({
    @required this.child,
    @required this.width,
    @required this.height,
    this.square: false
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
          width: widgetRelWidth(context, width),
          height: square ? widgetRelWidth(context, width) : widgetRelHeight(context, height),
          child: Card(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30*sizeCoeff)),
            ),
            child:  Padding(
              child: child,
              padding: EdgeInsets.all(20*sizeCoeff),
            ),
          )
        )

        //Container(
          //width: widgetRelWidth(context, width),
          //height: square ? widgetRelWidth(context, width) : widgetRelHeight(context, height),
          //decoration: BoxDecoration(
            //borderRadius: BorderRadius.all(Radius.circular(30)),
            //color: Colors.white
          //),
          //child: Padding(
            //child: child,
            //padding: EdgeInsets.all(20),
          //)
        //)
    );
  }
}


class SeparatorMenuBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0,
    );
  }
}

class RoundedMenuButton extends StatelessWidget {

  final Color color;
  final String text;
  final Function onPressed;

  RoundedMenuButton({@required this.color, @required this.text, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30*sizeCoeff,
      child: OutlineButton(
        child: Text(text),
        borderSide: BorderSide(color: color, width: 2),
        textColor: color,
        onPressed: onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      )
    );
  }
}

class ConfirmButton extends StatefulWidget {

  final String text;
  final Function command;

  ConfirmButton({@required this.text, @required this.command});

  @override
  State<ConfirmButton> createState() {
    return ConfirmButtonState();
  }
}

class ConfirmButtonState extends State<ConfirmButton> {

  final border = BorderSide(color:Colors.green, width: 2);

  Radius _borderRadius = Radius.circular(10);

  Color _backgroundColor = Colors.white;
  Color _fontColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {downAnimation(); widget.command();},
      onTapDown: (TapDownDetails details) {downAnimation();},
      onLongPressEnd: upAnimation,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        height: 30*sizeCoeff,
        width: 120*sizeCoeff,
        decoration: BoxDecoration(
          color: _backgroundColor,
          border: Border.fromBorderSide(border),
        ),
        child: Center(child: Text(widget.text, style: TextStyle(color: _fontColor, fontWeight: FontWeight.w700),))
      )
    );
  }

  void downAnimation () {
    setState(() {
      _borderRadius = Radius.circular(0);
      _backgroundColor = Colors.blueGrey;
      _fontColor = Colors.white;
    });
  }

  void upAnimation (LongPressEndDetails details) {
    setState(() {
      _borderRadius = Radius.circular(10);
      _backgroundColor = Colors.white;
      _fontColor = Colors.green;
    });
  }

}

class BoxCategory extends StatelessWidget {

  final Function onPressed;

  final String title;
  final String subtitle;

  final String buttonText;
  final Color buttonColor;

  final IconData icon;
  final Color iconColor;

  BoxCategory({
    @required this.onPressed,
    @required this.title,
    this.subtitle,
    this.buttonText,
    this.buttonColor,
    this.icon,
    this.iconColor
  });




  @override
  Widget build(BuildContext context) {

    bool noLower = this.buttonText == null && this.subtitle == null;

    return GestureDetector(
        onTap: onPressed,
        child: Container(
            height: widgetRelHeight(context, noLower ? 0.05 : 0.1 ),
            child: Column(
              children: <Widget>[
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        icon == null ? SizedBox(height:0) : Icon(icon, size: 20*(sizeCoeff + 0.1), color: iconColor,),
                        Text(title, style: mediumTitleFont)
                      ],
                    )
                ),
                SizedBox(height: 15*(sizeCoeff + 0.1)),
                noLower ? SizedBox() :
                Row(
                  children: <Widget>[
                    subtitle == null ? SizedBox() : Text(subtitle, style: mediumTextFont2,),
                    SizedBox(width: widgetRelWidth(context, buttonText == null ? 0 : 0.3 )),
                    buttonText == null ? SizedBox(width: 0) : RoundedMenuButton(
                      color: buttonColor == null ? Colors.black : buttonColor,
                      text: buttonText,
                      onPressed: onPressed,
                    )
                  ],
                )
              ],
            )
        )
    );
  }
}

class EmptyMenuBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.2,
      child: Container(
          width: widgetRelWidth(context, 0.35),
          height: widgetRelWidth(context, 0.35),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            color: Colors.white
          ),
          child: SizedBox(width: 0,)
      )
    )
      ;
  }
}

class VerticalLine extends StatelessWidget {

  final double height;
  final double width;
  final List<Color> colors;

  VerticalLine({
    @required this.height,
    @required this.width,
    @required this.colors
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(360)),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors
          )
      ),
    );
  }


}

class HorizontalLine extends StatelessWidget {

  final double length;
  final double width;
  final List<Color> colors;

  HorizontalLine({
    @required this.length,
    @required this.width,
    @required this.colors
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: width,
      width: length,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(360)),
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors
          )
      ),
    );
  }
}

class AnimatedRotatingIcon extends StatefulWidget {

  final AnimationController controller;

  AnimatedRotatingIcon({@required this.controller});

  @override
  State<StatefulWidget> createState() {
    return _AnimatedRotatingIconState();
  }
}


class _AnimatedRotatingIconState extends State<AnimatedRotatingIcon> with SingleTickerProviderStateMixin {

  Animation animation;

  @override
  void initState() {
    super.initState();
    animation = Tween(begin: 0, end: pi / 2).animate(widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        child: Icon(Icons.chevron_right, color: Colors.blueAccent, size: 30),
        builder: (context, child) {
          return Transform.rotate(
            angle: animation.value.toDouble(),
            child: child,
          );
        }
    );
  }
}


PageRouteBuilder slideTransitionBuilder ({@required menu, @required Offset begin, @required Offset end, int duration: 600}) {
  return PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return menu;
      },
      transitionDuration: Duration(milliseconds: duration),
      transitionsBuilder: (___, Animation<double> animation, ____, Widget child) {
        return SlideTransition(
          position: animation.drive(Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOutQuad))),
          child: child
        );
      }
  );

}

PageRouteBuilder scaleTransitionBuilder ({@required menu, int duration: 600}) {
  return PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return menu;
      },
      transitionDuration: Duration(milliseconds: duration),
      transitionsBuilder: (___, Animation<double> animation, ____, Widget child) {
        return ScaleTransition(
            scale: animation.drive(Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOutQuad))),
            child: child
        );
      }
  );

}

