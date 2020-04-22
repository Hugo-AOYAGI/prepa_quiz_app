
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/rendering.dart';

import 'fontStyles.dart';
import 'sizeControllers.dart';
import 'quizMenu.dart';


import 'package:shared_preferences/shared_preferences.dart';


List<IconData> subjectIcons = [];

ValueNotifier<bool> learntQuestion = ValueNotifier(false);

class QuestionPage extends StatefulWidget {

  final Question question;
  final won;

  QuestionPage({@required this.question, this.won})  : super(key: UniqueKey());

  @override
  State<StatefulWidget> createState() {
    return _QuestionPageState();
  }
}

class _QuestionPageState extends State<QuestionPage> {

  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  ValueNotifier<List<int>> answers;

  @override
  Widget build(BuildContext context) {
    answers = ValueNotifier(List<int>.generate(widget.question.getLenAnswers(), (index) => 0));

    return Padding(
      padding: EdgeInsets.all(10),
      child: FlipCard(
        key: cardKey,
        flipOnTouch: false,
        direction: FlipDirection.HORIZONTAL, // default
        front: getFront(),
        back: getBack(),
      )
    );
  }

  Widget getFront() {
    return ClipPath(
      clipper: CornerClipper(),
      child: Container(
          width: windowRelWidth(0.95),
          height: windowRelHeight(0.85),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200], width: 1),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(windowRelWidth(0.075))),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: windowRelHeight(0.015),),
              UpperQuestionInfoBar(
                category: widget.question.getCategory(),
                subjCode: widget.question.getSubjectCode(),
              ),
              SizedBox(height: windowRelHeight(0.025),),
              Text("Question", style: mediumTitleFont2),
              SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: windowRelHeight(0.4),
                  ),
                  child: Image.network(widget.question.getQuestionPath()),
                  padding: EdgeInsets.all(26),
                ),
              ),

              SizedBox(height: windowRelHeight(0.025),),
              widget.question.type != "CRD"? Text("Réponses", style: mediumTitleFont2) :
              Text("Tournez la carte pour la réponse", style: lightTextFontGrey),
              SizedBox(height: windowRelHeight(0.045),),
              getAnswersContainer(context),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Container(
                      child: Align(
                        alignment: Alignment(-1, 1),
                        child: Container(
                          width: windowRelWidth(0.125),
                          height: windowRelWidth(0.125),
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.only(topRight: Radius.circular(windowRelWidth(0.125)))
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: windowRelWidth(0.245),),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: ConfirmQuestionButton(command: () {
                          cardKey.currentState.toggleCard();
                        })
                      )
                    )
                  ],
                )
              ),
            ],
          )
      ),
    );
  }

  Widget getBack() {
    return ClipPath(
      clipper: CornerClipperReverse(),
      child: Container(
          width: windowRelWidth(0.95),
          height: windowRelHeight(0.85),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200], width: 1),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(windowRelWidth(0.075))),
          ),
          child: Column(
            children: <Widget>[
              UpperQuestionInfoBar(
                category: widget.question.getCategory(),
                subjCode: widget.question.getSubjectCode(),
              ),
              SizedBox(height: windowRelHeight(0.025),),
              widget.question.getType() != "CRD" ?
              ValueListenableBuilder<List<int>>(
                valueListenable: answers,
                builder: (context, value, _) {
                  return widget.question.compareResults(value) || widget.won == true ?
                    Column(
                      children: [
                        Text("Bonne Réponse", style: resultsFontGreen),
                        Text(widget.question.getAnswersMessage(), style: mediumTextFont2,)
                      ]
                    )
                  : Column(
                    children: [
                      Text("Mauvaise Réponse", style: resultsFontRed),
                      Text(widget.question.getAnswersMessage(), style: mediumTextFont2,)
                    ],
                  );
                }
              ) : SizedBox(height: 10),
              SizedBox(height: windowRelHeight(0.025),),
              Text("Solution & Explications", style: mediumTitleFont2),
              Container(
                child: Image.network(widget.question.getAnsPath()),
                padding: EdgeInsets.all(26),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: learntQuestion,
                          builder: (context, value, _) {
                            return Tooltip(
                              message: value ? "Oublier la question" : "Apprendre la question",
                              child: InkWell(
                                  onTap: () async {
                                    learntQuestion.value = !value;

                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    List<String> learnedPaths = prefs.getStringList("learnedPaths") == null ? [] : prefs.getStringList("learnedPaths");

                                    if (learntQuestion.value == true) {
                                      learnedPaths.add(widget.question.questionPath);
                                    } else {
                                      learnedPaths.remove(widget.question.questionPath);
                                    }

                                    print(learnedPaths);

                                    prefs.setStringList("learnedPaths", learnedPaths);

                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(!value ? 'Question apprise..' : 'Question oubliée..', style: mediumTextFont),
                                      duration: Duration(milliseconds: 500),
                                      backgroundColor: Colors.black.withOpacity(0.6),
                                    ));
                                  },
                                  child:Container(
                                    width: windowRelWidth(0.12),
                                    height: windowRelWidth(0.12),
                                    child: Icon(Icons.collections_bookmark, size: 25, color: Colors.lightBlue,),
                                    decoration: BoxDecoration(
                                      color: !value ? Colors.transparent : Colors.blue[100],
                                      border: Border.all(color: Colors.lightBlue, width: 3),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  )
                              ),
                            );
                          },
                        )
                      )
                    ),
                    SizedBox(width: windowRelWidth(0.15),),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            padding: EdgeInsets.all(10),
                            child: ConfirmQuestionButton(command: () {
                              learntQuestion.value = false;
                              currPage.value = nextQuestion.getCard();
                              getNewQuestionPage();
                              incrementQuestionIndex();
                            }, icon: Icons.arrow_forward, tag: "1")
                        )
                    )
                  ],
                )
              )
            ],
          )
      ),
    );
  }

  Widget getAnswersContainer(BuildContext context) {
    if (widget.question.getType() == "QCM") {
      return qcmAnswers();
    } else if (widget.question.getType() == "TOF") {
      return tofAnswers(context);
    } else {
      return SizedBox(height: 10);
    }
  }

  Widget qcmAnswers() {
      return ValueListenableBuilder(
        valueListenable: answers,
        builder: (context, value, _) {
          return Wrap(
            spacing: 40,
            runSpacing: 30,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            alignment: WrapAlignment.center,
            children: List<int>.generate(widget.question.getLenAnswers(), (int i) => i+1).map( (int i) {
              return GestureDetector(
                onTap: () {
                  answers.value[i-1] = answers.value[i-1] == 1 ? 0 : 1;
                  answers.value = List.from(answers.value);
                },
                child: Container(
                  width: windowRelHeight(0.065),
                  height: windowRelHeight(0.065),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: value[i - 1] == 1 ? Colors.grey[100] : Colors.white
                  ),
                  child: Center(
                    child: Text(i.toString(), style: value[i - 1] == 1 ? mediumTitleFont3Green : mediumTitleFont3Grey )
                  )
                )
              );
            }).toList()
          );
        }
      );
  }

  Widget tofAnswers(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("VRAI", style: mediumTitleFont3Grey),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            answers.value[0] = answers.value[0] == 1 ? 0 : 1;
            answers.value = List.from(answers.value);
          },
          child:ValueListenableBuilder<List<int>>(
            valueListenable: answers,
            builder: (context, value, _) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 100),
                width: windowRelWidth(0.2),
                height: windowRelHeight(0.05),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  border: Border.all(color: value[0] == 1 ? Colors.green[400] : Colors.red[400], width: 2)
                ),
                child: AnimatedAlign(
                  duration: Duration(milliseconds: 100),
                  alignment: value[0] == 0 ? Alignment.centerRight : Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: windowRelHeight(0.04),
                    height: windowRelHeight(0.04),
                    decoration: BoxDecoration(
                      color: value[0] == 1 ? Colors.greenAccent[100].withOpacity(0.3) : Colors.redAccent[100].withOpacity(0.3),
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      border: Border.all(color: value[0] == 1 ? Colors.green[300] : Colors.red[300], width: 3)
                    ),
                  )
                )
              );
            }
          ),
        ),
        SizedBox(width: 20),
        Text("FAUX", style: mediumTitleFont3Grey),
      ],
    );
  }

}


class CornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    
    path.lineTo(0, size.height - windowRelWidth(0.125));
    path.lineTo(windowRelWidth(0.125), size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class CornerClipperReverse extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height);
    path.lineTo(size.width - windowRelWidth(0.125), size.height);
    path.lineTo(size.width, size.height - windowRelWidth(0.125));
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}


class UpperQuestionInfoBar extends StatelessWidget {

  final category;
  final subjCode;

  UpperQuestionInfoBar({@required this.category, @required this.subjCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: windowRelHeight(0.06),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]))
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 10,),
          Image(image: AssetImage("assets/subjects/" + subjCode + ".png"), width: 30, height: 30),
          SizedBox(width: 10,),
          Container(
            width: windowRelWidth(0.73),
            child: Text(subjCode + " : " + category[0], style: mediumTitleFont, overflow: TextOverflow.fade, maxLines: 1, softWrap: false,)
          )

        ],
      )
    );
  }
}

