import 'package:flutter/material.dart';

import 'fontStyles.dart';
import 'sizeControllers.dart';
import 'main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components.dart';




class InfoMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.grey[900].withOpacity(0.2),
        body: Center(
            child: MainFrame()
        )
    );
  }
}

class MainFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: windowRelHeight(0.8),
        width: windowRelWidth(0.92),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20*(sizeCoeff + 0.1)),
            border: Border.all(width: 1, color: Colors.grey[300])
        ),
        child:  Container(
            width: windowRelWidth(0.95),
            padding: EdgeInsets.only(left: 25*(sizeCoeff + 0.1), right: 25*(sizeCoeff + 0.1), bottom: 35*(sizeCoeff + 0.1)),
            child: ListView(
              children: <Widget>[
                Icon(Icons.info_outline, size: 40*(sizeCoeff + 0.1), color: Colors.lightBlue,),
                SizedBox(height: windowRelHeight(0.025)),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
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
                    child: new Text('Voir le nombre de questions par chapitre', style: mediumTitleFontGrey, textAlign: TextAlign.center,),
                    onTap: () => launch('https://quiz-app-express-db.azurewebsites.net/')
                ),
                SizedBox(height: windowRelHeight(0.055)),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Si vous trouvez une erreur dans l'une des questions ou si vous souhaitez en proposer vous même, n'hésitez pas à me contacter par email : ",
                      style: mediumTitleFont2,
                    ),
                  ),
                ),
                SizedBox(height: windowRelHeight(0.015)),
                InkWell(
                    child: new Text('taupins.questions@gmail.com', style: mediumTitleFontGrey, textAlign: TextAlign.center,),
                    onTap: () => launch("mailto:taupins.questions@gmail.com?")
                ),
                SizedBox(height: windowRelHeight(0.055)),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Soutenez moi sur Patreon si vous aimez cette application : ",
                      style: mediumTitleFont2,
                    ),
                  ),
                ),
                SizedBox(height: windowRelHeight(0.015)),
                InkWell(
                    child: new Text('patreon.com/hugoaoyagi', style: mediumTitleFontGrey, textAlign: TextAlign.center,),
                    onTap: () => launch("https://www.patreon.com/hugoaoyagi")
                ),
                SizedBox(height: windowRelHeight(0.055)),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Les fiches de cette application ne m'appartiennent pas, elles sont extraites des cours de mes professeurs ou de différentes sources sur internet.",
                      style: mediumTitleFont2,
                    ),
                  ),
                ),
                SizedBox(height: windowRelHeight(0.05)),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close, size: 35*sizeCoeff, color: Colors.red,),
                )
              ],
            )
        )
    );
  }
}

class PatreonMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.grey[900].withOpacity(0.2),
        body: Center(
            child: Container(
              padding: EdgeInsets.only(left: 35*(sizeCoeff + 0.1), right: 35*(sizeCoeff + 0.1)),
                height: windowRelHeight(0.5),
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
                      child: Text("Vous aimez l'application ? N'hésitez pas à me soutenir sur Patreon !", style: mediumTitleFont2, textAlign: TextAlign.center,),
                    ),
                    SizedBox(height: windowRelHeight(0.025)),
                    Text("OU", style: mediumTitleFont3Grey,),
                    SizedBox(height: windowRelHeight(0.015)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            launch("https://www.patreon.com/hugoaoyagi");
                            Navigator.push(context, slideTransitionBuilder(
                                menu: MainMenu(),
                                begin: Offset(0, -1),
                                end: Offset(0, 0),
                                duration: 300)
                            );
                          },
                          child: Container(
                            width: windowRelWidth(0.335),
                            height: windowRelHeight(0.1),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.lightBlue, width: 3),
                                borderRadius: BorderRadius.circular(10*(sizeCoeff + 0.1))
                            ),
                            child: Center(child: Text("Faire une donation", style: mediumTitleFont2,)),
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
                            width: windowRelWidth(0.335),
                            height: windowRelHeight(0.1),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.lightBlue, width: 3),
                                borderRadius: BorderRadius.circular(10*(sizeCoeff + 0.1))
                            ),
                            child: Center(child: Text("Non merci", style: mediumTitleFont2,)),
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