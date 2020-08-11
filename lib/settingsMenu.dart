import 'package:flutter/material.dart';

import 'fontStyles.dart';
import 'sizeControllers.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';



class SettingsMenu extends StatelessWidget {

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
        height: windowRelHeight(0.5),
        width: windowRelWidth(0.92),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20*(sizeCoeff + 0.1)),
            border: Border.all(width: 1, color: Colors.grey[300])
        ),
        child:  Container(
            width: windowRelWidth(0.95),
            padding: EdgeInsets.only(left: 35*(sizeCoeff + 0.1), right: 35*(sizeCoeff + 0.1)),
            child: ListView(
              children: <Widget>[
                Icon(Icons.settings_applications, size: 40*(sizeCoeff + 0.1), color: Colors.lightBlue,),
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
                        borderRadius: BorderRadius.circular(10*(sizeCoeff + 0.1))
                    ),
                    child: Center(child: ValueListenableBuilder<bool> (
                        valueListenable: isHighContrast,
                        builder: (context, value, _) {
                          return Text(value == false ? "Faible Contraste" : "Contraste élevé", style: mediumTitleFont,);
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
                        content: Text("Rédemarrez l'application..", style: mediumTextFont),
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