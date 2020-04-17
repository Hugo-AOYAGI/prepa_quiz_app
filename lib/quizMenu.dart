
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

ValueNotifier<int> questionIndex = ValueNotifier(0);

Question currentQuestion;
Question nextQuestion;

ValueNotifier<QuestionPage> currPage;

ValueNotifier<List<Widget>> pages = ValueNotifier([]);
PageController pagesController;


class QuizMenu extends StatelessWidget {

  final initialQuestion;

  QuizMenu(this.initialQuestion);

  @override
  Widget build(BuildContext context) {

    loadData();
    currentQuestion = initialQuestion;
    currPage = ValueNotifier(currentQuestion.getCard());
    getNewQuestionPage();


    return Scaffold(
      body: Column(
        children: <Widget>[
          UpperInfoBar(),
          MainFrame(),
        ],
      )
    );
  }

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    questionIndex.value = prefs.getInt("questionIndex");
  }
}

class UpperInfoBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: windowRelWidth(1),
      height: windowRelHeight(0.125),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[400], width: 2)),
        color: Colors.grey[100]
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: windowRelHeight(0.05),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              LeaveButton(),
              QuestionIndexBox(),
            ],
          ),
        ],
      )
    );
  }
}

class QuestionIndexBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Nombre de questions répondues",
      child: ValueListenableBuilder<int>(
        valueListenable: questionIndex,
        builder: (context, value, _) {
          return Text("#" + value.toString(), style: mediumTitleFont2);
        }
      )

    );
  }
}

class LeaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: windowRelWidth(0.15),
      child: FlatButton(
        child: Icon(Icons.keyboard_return, color: Colors.red[300], size: 30),
        onPressed: () {
          Navigator.pop(context);
        },
        color: Colors.grey[100],
      ),
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
      height: windowRelHeight(0.875),
      width: windowRelWidth(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:  [
            Colors.lightBlue[100],
            Colors.cyan[100],
          ]
        ),
      ),
      child: ValueListenableBuilder<Widget>(
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
      child: Icon(icon == null ? Icons.check : icon, color: Colors.white, size: 40),
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
    return "https://quiz-app-db.glitch.me/" + questionPath.split("-QST")[0] + "-ANS.png";
  }

  bool compareResults(List<int> results) {
    return (results.join("_") == (questionPath.split("QST-")[1]).replaceAll(".png", ""));
  }

  String getSubjectCode() {
    return questionPath.substring(0, 3);
  }

  getQuestionPath() {
    return "https://quiz-app-db.glitch.me/" + questionPath;
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
  var response = await http.post("https://quiz-app-db.glitch.me/random_path", body: {'learned_paths': json.encode(learnedPaths), "selected": selected});
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