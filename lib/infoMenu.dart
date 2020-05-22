import 'package:flutter/material.dart';

import 'fontStyles.dart';
import 'sizeControllers.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';



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
        height: windowRelHeight(0.95),
        width: windowRelWidth(0.92),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 1, color: Colors.grey[300])
        ),
        child:  Container(
            width: windowRelWidth(0.95),
            padding: EdgeInsets.all(35),
            child: Column(
              children: <Widget>[
                SizedBox(height: windowRelHeight(0)),
                Icon(Icons.info_outline, size: 40, color: Colors.lightBlue,),
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
                    onTap: () => launch('https://quiz-app-db.glitch.me/')
                ),
                SizedBox(height: windowRelHeight(0.055)),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Si vous trouvez une erreur dans l'une des questions, n'hésitez pas à me contacter par email : ",
                      style: mediumTitleFont2,
                    ),
                  ),
                ),
                SizedBox(height: windowRelHeight(0.015)),
                InkWell(
                    child: new Text('aoyagihugo@gmail.com', style: mediumTitleFontGrey),
                    onTap: () => launch("mailto:aoyagihugo@gmail.com?")
                ),
                SizedBox(height: windowRelHeight(0.05)),
                Icon(Icons.settings_applications, size: 40, color: Colors.lightBlue,),
                SizedBox(height: windowRelHeight(0.025)),
                GestureDetector(
                  onTap: () async {
                    isHighContrast.value = !isHighContrast.value;
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool("isHighContrast", isHighContrast.value);
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Redemmarez l'application..", style: mediumTextFont),
                      duration: Duration(milliseconds: 800),
                      backgroundColor: Colors.black.withOpacity(0.6),
                    ));
                  },
                  child:Container(
                    width: windowRelWidth(0.505),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.lightBlue, width: 3),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(child: ValueListenableBuilder<bool> (
                        valueListenable: isHighContrast,
                        builder: (context, value, _) {
                          return Text(value == true ? "Faible Contraste" : "Contraste élevé", style: mediumTitleFont,);
                        }
                    )
                    ),
                  ),
                ),
                SizedBox(height: windowRelHeight(0.045)),
                Text("Taille de Police", style: mediumTitleFont2),
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: SpinBox(
                    min: 0.5,
                    max: 1.5,
                    value: sizeCoeff,
                    decimals: 3,
                    step: 0.025,
                    onChanged: (value) async {
                      sizeCoeff = value;
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setDouble("sizeCoeff", value);
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Redemmarez l'application..", style: mediumTextFont),
                        duration: Duration(milliseconds: 800),
                        backgroundColor: Colors.black.withOpacity(0.6),
                      ));
                    },
                  ),
                ),
                SizedBox(
                  height: windowRelHeight(0.045),
                ),
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