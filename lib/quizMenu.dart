
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:q_swipe/finishedQuizMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'fontStyles.dart';
import 'components.dart';
import 'sizeControllers.dart';
import 'package:flutter/cupertino.dart';
import 'main.dart';

import 'questionPage.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

ValueNotifier<int> questionIndex = ValueNotifier(0);

Question currentQuestion;
Question nextQuestion;

ValueNotifier<String> currPath = ValueNotifier("None");

ValueNotifier<QuestionPage> currPage;

ValueNotifier<List<Widget>> pages = ValueNotifier([]);
PageController pagesController;

final reportController = TextEditingController();


class QuizMenu extends StatelessWidget {

  final initialQuestion;

  QuizMenu(this.initialQuestion);

  @override
  Widget build(BuildContext context) {

    loadData();
    currentQuestion = initialQuestion;
    currPath.value = currentQuestion.questionPath;
    currPage = ValueNotifier(currentQuestion.getCard());
    getNewQuestionPage();


    return WillPopScope(
      onWillPop: getLearntPercentage,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
          body: MainFrame(),
      ),
    );
  }

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    questionIndex.value = prefs.getInt("questionIndex");
  }
}

class QuestionIndexBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: currPath,
      builder: (context, value, _) {
        return SizedBox(
          width: windowRelWidth(0.2),
          child: Tooltip(
              message: value,
              child: ValueListenableBuilder<int>(
                  valueListenable: questionIndex,
                  builder: (context, value, _) {
                    return Text("#" + value.toString(), style: mediumTitleFont4);
                  }
              )
          ),
        );
      }
    );
  }
}

class ReportQuestionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
        child: Icon(Icons.flag, color: Colors.black26, size: 35*(sizeCoeff + 0.1)),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.all(
                        Radius.circular(10.0)
                    )
                ),
                content: Builder(
                  builder: (context) {
                    return TextField(
                      maxLines: 3,
                      minLines: 1,
                      maxLength: 256,
                      controller: reportController,
                    );
                  }
                ),
                title: Text("Signaler un problème", style: mediumTitleFont2),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  FlatButton(
                    child: Text("Annuler", style: mediumTitleFont),
                    onPressed: () {
                      reportController.text = "";
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text("Confirmer", style: mediumTitleFont,),
                    onPressed: () async {

                      Navigator.of(context).pop();

                      final smtpServer = gmail("taupins.questions@gmail.com", "{_-e{f5DczQcjyd%");

                      final message = Message()
                        ..from = Address("taupins.questions@gmail.com", 'App Report')
                        ..recipients.add("taupins.questions@gmail.com")
                        ..subject = 'Problem Report : ${DateTime.now()}'
                        ..text = currPath.value + ": \n" + reportController.text;

                      try {
                        final sendReport = await send(message, smtpServer);
                        print('Message sent: ' + sendReport.toString());
                      } on MailerException catch (e) {
                        print('Message not sent.');
                        for (var p in e.problems) {
                          print('Problem: ${p.code}: ${p.msg}');
                        }
                      }

                      reportController.text = "";

                    },
                  ),
                ],
              );
            },
          );
        },
        color: Color(0x00000000),
    );
  }
}

class LeaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
        child: Icon(Icons.close, color: Colors.red[200], size: 35*(sizeCoeff + 0.1)),
        onPressed: () {
          Navigator.pop(context);
        },
        color: Color(0x00000000),
    );
  }
}


class MainFrame extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    pagesController = PageController(
        initialPage: 0
    );
    return Container(
      height: windowRelHeight(1),
      width: windowRelWidth(1),
      decoration: BoxDecoration(
          gradient: isHighContrast.value == true ? highContrastGradient : lowContrastGradient,
      ),
      child: Column(
        children: [
          SizedBox(height: windowRelHeight(0.035)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              LeaveButton(),
              ReportQuestionButton(),
              SizedBox(width: windowRelWidth(0.20)),
              QuestionIndexBox()
            ],
          ),
          ValueListenableBuilder<Widget>(
              valueListenable: currPage,
              builder: (context, value, _) {
                return AnimatedSwitcher(
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(child: child, position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0)).animate(animation),);
                  },
                  child: value,
                  duration: Duration(milliseconds: 300),
                );
              }
          ),
        ]
      )
    );
  }
}

class ConfirmQuestionButton extends StatelessWidget {

  final command;
  final icon;
  final tag;

  ConfirmQuestionButton({@required this.command, this.icon, this.tag});


  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: tag == null ? "0": tag,
      child: Icon(icon == null ? Icons.check : icon, color: Colors.white, size: 40*(sizeCoeff+0.1)),
      backgroundColor: Colors.blue[700],
      onPressed: command,
    );
  }
}

class Question {
  final questionPath;
  var type;
  Question(this.questionPath);

  String getType () {
    if (questionPath.contains("QCM")) {
      type = "QCM";
    } else if (questionPath.contains("TOF")) {
      type = "TOF";
    } else {
      type = "CRD";
    }
    return type;
  }

  String getAnsPath() {
    return "https://quiz-app-express-db.azurewebsites.net/" + questionPath.split("-QST")[0] + "-ANS.png";
  }

  bool compareResults(List<int> results) {
    return (results.join("_") == (questionPath.split("QST-")[1]).replaceAll(".png", ""));
  }

  String getSubjectCode() {
    return questionPath.substring(0, 3);
  }

  getQuestionPath() {
    return "https://quiz-app-express-db.azurewebsites.net/" + questionPath;
  }

  getCategory() {
    String subjCode = getSubjectCode();
    String catCode = questionPath.split("-" + getType())[0].replaceAll(subjCode + "-", "");
    for (var i = 0; i < categories[subjCode].length; i++) {
      var cat = categories[subjCode][i];
      if (cat[1] == catCode) {
        return cat;
      }
    }
  }

  getLenAnswers() {
    return (questionPath.split("QST-")[1]).replaceAll(".png", "").split("_").length;
  }

  Widget getCard({won}) {
    return QuestionPage(question: this, won: won);
  }

  String getAnswersMessage() {
    var solutions = (questionPath.split("QST-")[1]).replaceAll(".png", "").split("_");
    String res = "";
    if (type == "QCM") {
      List<int> ans = [];
      int count = 0;
      for (var i=0; i< solutions.length; i++) {
        if (solutions[i] == "1") {
          ans.add(i + 1);
        }
      }
      if(ans.length == 1) {
        res = "La solution était " + ans[0].toString() + ".";
      } else {
        res = "Les solutions étaient " + ans.join(", ") + ".";
      }
    } else if (type == "TOF") {
      res = "La proposition était " + (solutions[0] == "1" ? "vraie." : "fausse.");
    }
    return res;

  }


}

void getNewQuestionPage() async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var learnedPaths = prefs.getStringList("learnedPaths") == null ? [] : prefs.getStringList("learnedPaths");
  var selected = prefs.getString("selectedCategories") == null ? '["ALL"]' : prefs.getString("selectedCategories");
  var response = await http.post("https://quiz-app-express-db.azurewebsites.net/random_path", body: {'learned_paths': json.encode(learnedPaths), "selected": selected});
  if (response.body == "ALL LEARNED") {
    Navigator.push(mainContext, scaleTransitionBuilder(
        menu: FinishedQuizMenu(),
        duration: 300)
    );
  } else {
    nextQuestion = Question(response.body);
  }

}


void incrementQuestionIndex() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  questionIndex.value++;
  prefs.setInt("questionIndex", questionIndex.value);


}