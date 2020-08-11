
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'components.dart';
import 'sizeControllers.dart';

import 'main.dart';

GlobalKey<_SplashScreenState> splashScreenKey = GlobalKey<_SplashScreenState>();

class SplashScreen extends StatefulWidget {

  SplashScreen() : super(key: splashScreenKey);

  @override
  State<StatefulWidget> createState() {

    return _SplashScreenState();
  }

}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // WidgetsBinding.instance
       // .addPostFrameCallback((_) => loadMenu());
    super.initState();
  }

  void loadMenu() async {
    Navigator.of(context).push(slideTransitionBuilder(menu: MainMenu(), begin: Offset(0, -1), end: Offset.zero));
  }

  @override
  Widget build(BuildContext context) {

    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.cyan[500],
      body: Column(
        children: <Widget>[
          SizedBox(height: windowRelHeight(0.7),),
          Center(
            child: SizedBox(
                height: windowRelHeight(0.1),
                width: windowRelHeight(0.1),
                child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlue[200],
                )
            ),
          )
        ],
      ),
    );
  }

}