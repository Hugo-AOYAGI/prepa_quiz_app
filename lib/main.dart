

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'fontStyles.dart';
import 'components.dart';
import 'sizeControllers.dart';

import 'categoryMenu.dart';
import 'quizMenu.dart';
import 'splashScreen.dart';
import 'finishedQuizMenu.dart';
import 'infoMenu.dart';
import 'settingsMenu.dart';
import 'sheetMenu.dart';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;


/// If the current platform is a desktop platform that isn't yet supported by
/// TargetPlatform, override the default platform to one that is.
/// Otherwise, do nothing.
void _setTargetPlatformForDesktop() {
  // No need to handle macOS, as it has now been added to TargetPlatform.
  if (Platform.isLinux || Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

BuildContext mainContext;

dynamic categories;
dynamic subjects;
dynamic selectedCategories;
dynamic sheets;

bool patreonMenuPopped = false;
int appCount;
String totalNumberQuestions;

ValueNotifier<bool> showTutorial = ValueNotifier(false);

ValueNotifier<List<int>> selectedLen = ValueNotifier([0, 0]);

ValueNotifier<bool> isHighContrast = ValueNotifier(false);

ValueNotifier<int> percentage = ValueNotifier(0);

PageController pageController = PageController(initialPage: 1);

LinearGradient highContrastGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0, 0.9],
  colors: <Color> [
    Colors.purple[900],
    Color(0xFF006cda),
  ]
);
LinearGradient lowContrastGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 0.25, 1],
    colors: <Color> [
      Color(0xFF8e75ff),
      Color(0xFF617fff),
      Color(0xFF7ac0ff),
    ]
);



void loadData() async {
  print("Loading Data...");
  final response = await http.get("https://quiz-app-express-db.azurewebsites.net/json");
  final jsonData = json.decode(response.body);

  categories = jsonData["categories"];
  subjects = jsonData["subjects"];
  selectedCategories = new Map.from(jsonData["categories"]);
  selectedLen.value[1] = 0;

  for (var i = 0; i < subjects.length; i++) {
    selectedCategories[subjects[i][1]] = {};
    for (var k = 0; k < categories[subjects[i][1]].length; k++) {
      selectedCategories[subjects[i][1]][categories[subjects[i][1]][k][1]] = false;
      selectedLen.value[1]++;
    }
  }
  print("Loading Sheets...");
  final sheetsResponse = await http.get("https://quiz-app-express-db.azurewebsites.net/sheets");
  sheets = json.decode(sheetsResponse.body);

  final lenResponse = await http.get("https://quiz-app-express-db.azurewebsites.net/questions_len");
  totalNumberQuestions = lenResponse.body;

  print(totalNumberQuestions);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  isHighContrast.value = prefs.getBool("isHighContrast") == null ? false : prefs.getBool("isHighContrast");
  sizeCoeff = prefs.getDouble("sizeCoeff") == null ? 0.9 : prefs.getDouble("sizeCoeff");

  appCount = prefs.getInt("appCounter") == null ? 0 : prefs.getInt("appCounter");
  appCount++;
  prefs.setInt("appCounter", appCount);

  print("Data loaded...");
  splashScreenKey.currentState.loadMenu();
}

void main() {
  runApp(MyApp());
  loadData();

}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: "QSwipe",
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    mainContext = context;
    if (appCount%20 == 5 && !patreonMenuPopped) {
      patreonMenuPopped = true;
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.push(context, scaleTransitionBuilder(
            menu: PatreonMenu(),
            duration: 300)
        );
      });
    }

    if (appCount == 1) {
      showTutorial.value = true;
      startTutorial();
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              decoration: BoxDecoration(
                  gradient: isHighContrast.value == true ? highContrastGradient : lowContrastGradient,
              ),
              child: MainListView()
          )
	),
    );
  }
}

class MainListView extends StatefulWidget {
  @override
  _MainListViewState createState() => _MainListViewState();
}

class _MainListViewState extends State<MainListView> {

  final _activeColor = Colors.white;
  final _unselectedColor = Colors.lightBlue[100];

  final _bottomIcons = [Icons.queue, Icons.home, Icons.view_column];

  int _pageIndex = 1;

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: <Widget>[

        PageView(
            controller: pageController,
            onPageChanged: _onPageViewChange,
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              QuizStartPage(),
              HomePage(),
              SheetsPage()
            ]
        ),
        Positioned(
          bottom: 10,
          left: 0,
          width: windowWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(width: 60),
              Row(
                children: _bottomIcons.map( (_icon) {
                  bool _isCurrent = _pageIndex == _bottomIcons.indexOf(_icon);
                  return IconButton(
                    icon: Icon(
                        _icon,
                        color: _isCurrent ? _activeColor : _unselectedColor
                    ),
                    iconSize: _isCurrent ? 30 : 25,
                    onPressed: () {
                      pageController.animateToPage(
                        _bottomIcons.indexOf(_icon),
                        duration: Duration(milliseconds: 500),
                        curve: Curves.linearToEaseOut
                      );
                    },
                  );
                }).toList()
              ),
              SizedBox(width: 60),
            ]
          )
        ),
        ValueListenableBuilder(
          valueListenable: showTutorial,
          builder: (context, value, _) {
            if (value) {
              return MainPageTutorial();
            } else {
              return SizedBox(width: 0,);
            }
          },
        )

      ],
    );
  }


  void _onPageViewChange(int page) {
    setState(() {
      _pageIndex = page;
    });
  }

}


class MainPageTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: ValueListenableBuilder(
        valueListenable: tutorialStep,
        builder: (context, value, _)  {

          List step = tutorialStepDetails[value];

          if (value != 0) {
            pageController.animateToPage(step[9], duration: Duration(milliseconds: 200), curve: Curves.easeOut);
          }

          double frameX = step[0]; double frameY = step[1]; double frameW = step[2]; double frameH = step[3];

          double textX = step[4];  double textY = step[5]; double textW = step[6]; double textH = step[7];


          return Container(
              width: windowRelWidth(1),
              height: windowRelHeight(1),
              color: Colors.transparent,
              child: Stack(
                children: [

                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: windowRelWidth(1),
                      height: frameY,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(120, 50, 50, 50),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    top: frameY,
                    child: Container(
                      width: frameX,
                      height: frameH,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(120, 50, 50, 50),
                      ),
                    ),
                  ),

                  Positioned(
                    left: frameX + frameW,
                    top: frameY,
                    child: Container(
                      width: windowWidth - (frameX + frameW),
                      height: frameH,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(120, 50, 50, 50),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    top: frameY + frameH,
                    child: Container(
                      width: windowRelWidth(1),
                      height: windowHeight - (frameY + frameH),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(120, 50, 50, 50),
                      ),
                    ),
                  ),


                  Positioned(
                    left: frameX,
                    top: frameY,
                    child: Container(
                      width: frameW,
                      height: frameH,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),


                  Positioned(
                    left: textX,
                    top: textY,
                    child: Container(
                      width: textW,
                      height: textH,
                      padding: EdgeInsets.all(windowRelWidth(0.045)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(windowRelHeight(0.015))),
                      ),
                      child: Center(
                          child: Text(
                            step[8],
                            style: mediumTitleFont,
                          )
                      ),
                    ),
                  ),


                  Positioned(
                    left: windowRelWidth(0.45),
                    top: windowRelHeight(0.8),
                    child: GestureDetector(
                      child: Icon(Icons.arrow_forward, size: windowRelWidth(0.125), color: Colors.white),
                      onTap: () {
                        if (tutorialStep.value == tutorialStepDetails.length - 1) {
                          showTutorial.value = false;
                        } else {
                          tutorialStep.value++;
                        }
                      },
                    )
                  )
                ],
              )
          );
        },
      )

    );
  }
}


class QuizStartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      child: Column(
        children: <Widget>[
          TitleAndSubtitle(
              title: "Créer un Quiz",
              subtitle: "",
              titleAlignment: Alignment.topCenter,
              subtitleAlignment: Alignment.topCenter,
              padding: [0, 0, 20, 0]
          ),
          SizedBox(height: windowRelHeight(0.05),),
          StartQuizBox(),
          SizedBox(height: 30),
          Text("OU", style: headerMedium,),
          SizedBox(height: 30),
          AllQuiz()
        ],
      )
    );
  }
}

class StartQuizBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoundedMenuBox(
      width: 0.8,
      height: 0.25,
      child: Column(
        children: <Widget>[
          SelectedCategories(),
          SizedBox(height: windowRelHeight(0.0275),),
          ConfirmButton(text: "CRÉER", command: () {
            if (selectedLen.value[0] == 0) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Choisissez une catégorie !", style: mediumTextFont),
                duration: Duration(milliseconds: 800),
                backgroundColor: Colors.black.withOpacity(0.6),
              ));
            } else {
              createQuiz("THEMED", context);
            }
          }),
        ],
      )
    );
  }
}


class SelectedCategories extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<int>>(
        valueListenable: selectedLen,
        builder: (context, value, _) {
          return BoxCategory(
            buttonColor: Colors.blue,
            icon: Icons.category,
            iconColor: Colors.blueAccent,
            onPressed: () {
              Navigator.push(context, slideTransitionBuilder(
                  menu: CategoryMenu(),
                  begin: Offset(0.0, 1.0),
                  end: Offset.zero));
            },
            title: "  Quiz thématique",
            subtitle: value[0].toString() + "/" + value[1].toString(),
            buttonText: "CHOISIR",
          );
        }
    );

  }
}

class AllQuiz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoundedMenuBox(
      width: 0.8,
      height: 0.25,
      child: Column(
        children: <Widget>[
          BoxCategory(
            icon: Icons.all_inclusive,
            iconColor: Colors.blueAccent,
            title: "  Toutes catégories",
            subtitle: "",
            onPressed: () {}
          ),
          SizedBox(height: windowRelHeight(0.015)),
          ConfirmButton(text: "CRÉER", command: () {
            createQuiz("ALL", context);
          })
        ],
      )
    );
  }
}

Future<bool> getLearntPercentage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var learnedPaths = prefs.getStringList("learnedPaths") == null ? [] : prefs.getStringList("learnedPaths");
  var selected = prefs.getString("selectedCategories") == null ? '["ALL"]' : prefs.getString("selectedCategories");

  final percentLearntResponse = await http.post("https://quiz-app-express-db.azurewebsites.net/learned_percent", body: {'learned_paths': json.encode(learnedPaths), "selected": selected});

  print(percentLearntResponse.body);

  percentage.value = int.parse(percentLearntResponse.body);

  return true;

}


class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    getLearntPercentage();

    return PageTemplate(
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: windowRelWidth(0.05),),
              Column(
                children: [
                  SizedBox(height: windowRelHeight(0.075)),
                  Container(
                    width: windowRelWidth(0.15),
                    child: Image.asset("assets/icon/icon_fg.png"),
                  ),
                ],
              ),
              TitleAndSubtitle(
                  title: "La Taupinière",
                  subtitle: "",
                  titleAlignment: Alignment.centerLeft,
                  subtitleAlignment: Alignment.centerLeft,
                  padding: [10, 0, 20, 0]
              ),

            ],
          ),
          SizedBox(height: windowRelHeight(0.03),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
             SizedBox(height: windowRelHeight(0.1))
            ],
          ),
          SizedBox(height: windowRelHeight(0.025),),
          CurrentQuizBox(),
          SizedBox(height: windowRelHeight(0.055),),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InfoButton(),
                SizedBox(width: windowRelWidth(0.05)),
                SettingsButton(),
                SizedBox(width: windowRelWidth(0.05))
              ],
            )
          )
        ],
      )
    );
  }

}

class CurrentQuizBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoundedMenuBox(
        width: 0.8,
        height: 0.25,
        child: Column(
          children: <Widget>[
            ValueListenableBuilder<int>(
              valueListenable: percentage,
              builder: (context, value, _) {
                return BoxCategory(
                  title: "   Quiz Actuel",
                  subtitle: value.toString() + "% appris",
                  icon: Icons.question_answer,
                  iconColor: Colors.blueAccent,
                  onPressed: () {},
                );
              }
            ),
            SizedBox(height: windowRelHeight(0.0275),),
            ConfirmButton(text: "CONTINUER", command: () {
              resumeQuiz(context);
            },)
          ],
        )
    );
  }
}

class InfoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, scaleTransitionBuilder(
            menu: InfoMenu(),
            duration: 300)
        );
      },
      child: Icon(
                Icons.info_outline,
                color: Colors.grey[100],
                size: 35*(sizeCoeff + 0.1)
            ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, scaleTransitionBuilder(
            menu: SettingsMenu(),
            duration: 300)
        );
      },
      child: Icon(
          Icons.settings_applications,
          color: Colors.grey[100],
          size: 35*(sizeCoeff + 0.1)
      ),
    );
  }
}


Widget sheetsListView;
List<dynamic> treePath = [];
List<String> treePathNames = [];

class SheetsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SheetsPageState();
  }
}

class _SheetsPageState extends State<SheetsPage> {

  @override
  void initState() {
    sheetsListView = ListView(
        padding: EdgeInsets.all(10),
        children: sheets.entries.map<Widget>((sheet) {
          return Column(
            children: [
              sheet.value is! List ?
              SheetButton(title: sheet.key, url: sheet.value) :
              SheetFolder(title: sheet.key, children: sheet.value, notifyParent: refresh),
              SizedBox(height: windowRelHeight(0.015))
            ],
          );
        }).toList()
    );
    treePath = [];
    treePathNames = [];
    treePathNames.add("home");
    treePath.add(sheetsListView);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return PageTemplate(
      child: Column(
        children: <Widget>[
          TitleAndSubtitle(
            title: "Fiches",
            subtitle: treePathNames.length == 1 ? "" : treePathNames[treePathNames.length - 1],
            titleAlignment: Alignment.topCenter,
            subtitleAlignment: Alignment.topCenter,
            padding: [0, 0, 20, 0]
          ),
          SizedBox(height: windowRelHeight(0.01)),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[400], width: 1), bottom: BorderSide(color: Colors.grey[200], width: 1))
            ),
            height: windowRelHeight(0.7),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    child: sheetsListView,
                    duration: Duration(milliseconds: 300),
                  )
                ),
                treePath.length > 1 ?  FlatButton(
                  child: Icon(Icons.keyboard_return, size: 30*(sizeCoeff + 0.1), color: Colors.white),
                  onPressed: () {
                    treePath.removeLast();
                    treePathNames.removeLast();
                    sheetsListView = treePath[treePath.length - 1];
                    setState(() {});
                  },
                ) : SizedBox(height: 0)
              ],
            )
          )
        ],
      )
      ,
    );
  }

  void refresh() {
    setState(() {});
  }

}

class SheetButton extends StatelessWidget {

  final title;
  final url;

  SheetButton({@required this.title, @required this.url});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () async {
        if (title.startsWith("pdf.")) {
          launch(url);
        } else {
          Navigator.of(context).push(slideTransitionBuilder(
              menu: SheetMenu(url: url),
              begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0)
          ));
        }

      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15*(sizeCoeff + 0.1)),
          ),
          height: windowRelHeight(0.115),
          child: Center(
              child: Text(
                title.replaceAll(new RegExp(r'pdf.'), ""),
                style: mediumTitleFont2,
                textAlign: TextAlign.center,
              )
          )
      ),
    );
  }

}

class SheetFolder extends StatelessWidget {


  final title;
  final children;
  final notifyParent;

  SheetFolder({@required this.title, @required this.children, @required this.notifyParent});

  @override
  Widget build(BuildContext context) {
    return getFolderButton();
  }

  Widget getFolderPage() {
    return ListView(
          padding: EdgeInsets.all(10),
          children: children[0].entries.map<Widget>((sheet) {
            return Column(
              children: [
                sheet.value is! List ?
                SheetButton(title: sheet.key, url: sheet.value) :
                SheetFolder(title: sheet.key, children: sheet.value, notifyParent: notifyParent),
                SizedBox(height: windowRelHeight(0.015))
              ],
            );
          }).toList()
      );
  }

  Widget getFolderButton() {
    return FlatButton(
      onPressed: () {
        sheetsListView = getFolderPage();
        treePath.add(sheetsListView);
        treePathNames.add(title);
        notifyParent();
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15*sizeCoeff)),
        elevation: 10,
        child: Container(
            padding: EdgeInsets.all(20),
            height: windowRelHeight(0.115),
            child: Stack(
              children: [
                Center(
                    child: Text(
                      title,
                      style: mediumTitleFont2,
                      textAlign: TextAlign.center,
                    )
                ),
                Align(
                  child: Icon(Icons.folder_open, size: 20*(sizeCoeff + 0.1), color: Colors.blueAccent),
                  alignment: Alignment.bottomRight,
                )
              ],
            )
        ),
      )
    );
  }

}

class UpdateButton extends StatelessWidget {
  final size = 0.15;
  final color = Colors.green[300];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: windowRelWidth(size),
      height: windowRelWidth(size),
      child: FlatButton(
        child: Icon(Icons.update, color: color, size: 25,),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(windowRelWidth(size)/2)),
            side: BorderSide(color: color, width: 4)
        ),
        onPressed: () {
          loadData();
        },
      ),
    );
  }
}


void resumeQuiz (BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var learnedPaths = prefs.getStringList("learnedPaths") == null ? [] : prefs.getStringList("learnedPaths");
  var selected = prefs.getString("selectedCategories") == null ? '["ALL"]' : prefs.getString("selectedCategories");
  var response = await http.post("https://quiz-app-express-db.azurewebsites.net/random_path", body: {'learned_paths': json.encode(learnedPaths), "selected": selected});

  if (prefs.getInt("questionIndex") == null){
    prefs.setInt("questionIndex", 0);
  }


  if (response.body == "ALL LEARNED") {
    Navigator.of(context).push(scaleTransitionBuilder(
        menu: FinishedQuizMenu(),
        duration: 300)
    );
  } else {
    Question initialQuestion = Question(response.body);

    Navigator.push(context, slideTransitionBuilder(
        menu: QuizMenu(initialQuestion),
        begin: Offset(0, -1),
        end: Offset(0, 0),
        duration: 300)
    );
  }
}

void createQuiz (String type, BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("quizType", type);
  prefs.setStringList("learnedPaths", []);
  prefs.setInt("questionIndex", 0);
  if (type == "ALL") {
    prefs.setString("selectedCategories", '["ALL"]');
  } else {
    prefs.setString("selectedCategories", json.encode(selectedCategories));
  }

  var response = await http.post("https://quiz-app-express-db.azurewebsites.net/random_path", body: {'learned_paths': json.encode(prefs.getStringList("learnedPaths")), "selected": prefs.getString("selectedCategories")});

  if (response.body == "ALL LEARNED") {
    Navigator.push(context, scaleTransitionBuilder(
        menu: FinishedQuizMenu(),
        duration: 300)
    );
  } else {
    Question initialQuestion = Question(response.body);

    Navigator.push(context, slideTransitionBuilder(
        menu: QuizMenu(initialQuestion),
        begin: Offset(0, -1),
        end: Offset(0, 0),
        duration: 300)
    );
  }
}

ValueNotifier<int> tutorialStep = ValueNotifier(0);
dynamic tutorialStepDetails = [];


void startTutorial() {
  tutorialStepDetails = [
    [0.0 , 0.0, 0.0, 0.0, windowRelWidth(0.15), windowRelHeight(0.3), windowRelWidth(0.7), windowRelHeight(0.25), "Bienvenue sur Les Taupins ! \n\n Ce court tutoriel vous aidera à mieux prendre en main l'application.", 0],
    [windowRelWidth(0.1), windowRelHeight(0.325), windowRelWidth(0.8), windowRelHeight(0.25), windowRelWidth(0.15), windowRelHeight(0.05), windowRelWidth(0.7), windowRelHeight(0.25), "Cette partie correspond au quiz sur lequel vous vous entrainez actuellement. \n\n(Il contient des questions de toutes les matières par défaut)", 1],
    [windowRelWidth(0.125), windowRelHeight(0.385), windowRelWidth(0.275), windowRelHeight(0.065), windowRelWidth(0.15), windowRelHeight(0.15), windowRelWidth(0.7), windowRelHeight(0.15), "Apprendre des questions vous permet de ne plus retomber dessus si vous avez assimilé cette notion.", 1],
    [windowRelWidth(0.325), windowRelHeight(0.6175), windowRelWidth(0.15), windowRelWidth(0.15), windowRelWidth(0.15), windowRelHeight(0.45), windowRelWidth(0.7), windowRelHeight(0.15), "Ce menu donne des infos sur l'appli et le nombre de questions disponibles.", 1],
    [windowRelWidth(0.475), windowRelHeight(0.6175), windowRelWidth(0.15), windowRelWidth(0.15), windowRelWidth(0.15), windowRelHeight(0.45), windowRelWidth(0.7), windowRelHeight(0.15), "Le menu 'Options' permet de changer le thème ainsi que la taille de la police d'écriture.", 1],
    [windowRelWidth(0.3), windowRelHeight(0.915), windowRelWidth(0.4), windowRelWidth(0.15), windowRelWidth(0.15), windowRelHeight(0.625), windowRelWidth(0.7), windowRelHeight(0.15), "Naviguez les menus à l'aide des boutons ci-dessous ou en balayant l'écran.", 1],
    [windowRelWidth(0.1), windowRelHeight(0.22), windowRelWidth(0.8), windowRelHeight(0.25), windowRelWidth(0.075), windowRelHeight(0.5), windowRelWidth(0.85), windowRelHeight(0.25), "Prenez un quiz thématique en choisissant les matières et chapitres que vous souhaitez réviser... \n\nAstuce: Un swipe vers la droite sur le nom d'une matière permet de selectionner tous ses chapitres !", 0],
    [windowRelWidth(0.1), windowRelHeight(0.6), windowRelWidth(0.8), windowRelHeight(0.2), windowRelWidth(0.2), windowRelHeight(0.49), windowRelWidth(0.6), windowRelHeight(0.1), "... ou révisez toutes les matières à la fois.", 0],
    [0.0, 0.0, 0.0 , 0.0, windowRelWidth(0.1), windowRelHeight(0.49), windowRelWidth(0.8), windowRelHeight(0.1), "Profitez de fiches sur chaque matière !", 2],
    [0.0, 0.0, 0.0 , 0.0, windowRelWidth(0.1), windowRelHeight(0.39), windowRelWidth(0.8), windowRelHeight(0.15), "Vous êtes maintenant fin prêt pour utiliser l'application !\n\nBonnes révisions !", 1],

  ];

}


