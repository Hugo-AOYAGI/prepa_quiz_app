import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fontStyles.dart';
import 'components.dart';
import 'sizeControllers.dart';
import 'main.dart';


class FinishedQuizMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[900].withOpacity(0.2),
        body: Center(
          child: Container(
              height: windowRelHeight(0.4),
              width: windowRelWidth(0.92),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20*(sizeCoeff + 0.1)),
                border: Border.all(width: 1, color: Colors.grey[300])
              ),
              child:  Column(
                children: <Widget>[
                  SizedBox(height: windowRelHeight(0.05)),
                  Icon(Icons.info_outline, size: 40, color: Colors.lightBlue,),
                  SizedBox(height: windowRelHeight(0.025)),
                  Center(
                    child: Text("Toutes les questions\nont été apprises ! ", style: mediumTitleFont2, textAlign: TextAlign.center,),
                  ),
                  SizedBox(height: windowRelHeight(0.025)),
                  Text("OU", style: mediumTitleFont3Grey,),
                  SizedBox(height: windowRelHeight(0.015)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setStringList("learnedPaths", <String>[]);
                          Navigator.push(context, slideTransitionBuilder(
                              menu: MainMenu(),
                              begin: Offset(0, -1),
                              end: Offset(0, 0),
                              duration: 300)
                          );
                        },
                        child: Container(
                          width: windowRelWidth(0.375),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.lightBlue, width: 3),
                              borderRadius: BorderRadius.circular(10*(sizeCoeff + 0.1))
                          ),
                          child: Center(child: Text("Oublier tout", style: mediumTextFont2,)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          Navigator.push(context, slideTransitionBuilder(
                              menu: MainMenu(),
                              begin: Offset(0, -1),
                              end: Offset(0, 0),
                              duration: 300)
                          );
                        },
                        child:Container(
                          width: windowRelWidth(0.375),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.lightBlue, width: 3),
                              borderRadius: BorderRadius.circular(10*(sizeCoeff + 0.1))
                          ),
                          child: Center(child: Text("Créer un quiz", style: mediumTextFont2,)),
                        ),
                      )
                    ],
                  )
                ],
              )
          )
        )
    );
  }
}