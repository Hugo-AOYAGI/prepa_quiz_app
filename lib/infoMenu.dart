import 'package:flutter/material.dart';

import 'fontStyles.dart';
import 'sizeControllers.dart';
import 'main.dart';
import 'package:url_launcher/url_launcher.dart';



class InfoMenu extends StatelessWidget {

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
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 1, color: Colors.grey[300])
                ),
                child:  Container(
                  width: windowRelWidth(0.95),
                  padding: EdgeInsets.all(45),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: windowRelHeight(0)),
                      Icon(Icons.info_outline, size: 40, color: Colors.lightBlue,),
                      SizedBox(height: windowRelHeight(0.025)),
                      Center(
                        child: RichText(
                          text: TextSpan(
                              text: "Ce quiz contient actuellement ",
                              children: [
                                TextSpan(
                                  text: totalNumberQuestions,
                                  style: mediumTextFont2,
                                ),
                                TextSpan(
                                    text: " questions. ",
                                    style: mediumTitleFont2
                                )
                              ],
                              style: mediumTitleFont2
                          ),
                        ),
                      ),
                      SizedBox(height: windowRelHeight(0.025)),
                      InkWell(
                          child: new Text('Voir le nombre de questions par chapitre', style: mediumTitleFont),
                          onTap: () => launch('https://quiz-app-db.glitch.me/')
                      ),
                    ],
                  )
                )
            )
        )
    );
  }
}