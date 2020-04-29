

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'fontStyles.dart';
import 'components.dart';
import 'sizeControllers.dart';

import 'categoryMenu.dart';
import 'quizMenu.dart';
import 'splashScreen.dart';
import 'finishedQuizMenu.dart';
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
ValueNotifier<List<int>> selectedLen = ValueNotifier([0, 0]);

void loadData() async {
  print("Loading Data...");
  final response = await http.get("https://quiz-app-db.glitch.me/json");
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
  final sheetsResponse = await http.get("https://quiz-app-db-sheets.glitch.me/sheets");
  sheets = json.decode(sheetsResponse.body);

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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0, 1.8],
                      colors: <Color> [
                        Colors.purple[800],
                        Color(0xFF00C8D9),
                      ]
                  )
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

  final _controller = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PageView(
            controller: _controller,
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
                      _controller.animateToPage(
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
          SizedBox(height: windowRelHeight(0.015)),
          SeparatorMenuBox(),
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
            iconColor: Colors.purple,
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
            iconColor: Colors.deepOrange,
            title: "  Toutes catégories",
            subtitle: "",
            onPressed: () {}
          ),
          SizedBox(height: windowRelHeight(0.015)),
          SeparatorMenuBox(),
          SizedBox(height: windowRelHeight(0.0275),),
          ConfirmButton(text: "CRÉER", command: () {
            createQuiz("ALL", context);
          })
        ],
      )
    );
  }
}


class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      child: Column(
        children: <Widget>[
          TitleAndSubtitle(
            title: "QMIN",
            subtitle: "PTSI / PT",
            titleAlignment: Alignment.centerLeft,
            subtitleAlignment: Alignment.centerLeft,
            padding: [40, 0, 20, 0]
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
          SizedBox(height: windowRelHeight(0.025),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
            ],
          ),
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
            BoxCategory(
              title: "   Quiz Actuel",
              subtitle: "0% appris",
              icon: Icons.question_answer,
              iconColor: Colors.red,
              onPressed: () {},
            ),
            SeparatorMenuBox(),
            SizedBox(height: windowRelHeight(0.0375),),
            ConfirmButton(text: "CONTINUER", command: () {
              resumeQuiz(context);
            },)
          ],
        )
    );
  }
}

class QuickQuizBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
      },
      child:RoundedMenuBox(
        width: 0.35,
        square: true,
        height: 0.35,
        child: Row(
          children: <Widget>[
            VerticalLine(height: 70, width: 3, colors: [Colors.blue, Colors.green],),
            SizedBox(width: 15,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Quick",
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.blueGrey
                  ),
                ),
                SizedBox(height: 5,),
                Text("QUIZ",
                  style: TextStyle(
                      fontFamily: "LibreCaslonText",
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Colors.blue
                  ),
                )
              ],
            )
          ],
        ),
      )
    );
  }
}

class StatsPageBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: RoundedMenuBox(
        width: 0.35,
        square: true,
        height: 0.35,
        child: Column(
          children: <Widget>[
            Icon(Icons.library_books, color: Colors.cyan,),
            SizedBox(height: windowRelHeight(0.0025),),
            Text("Your \n Statistics",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w600,
                color: Colors.lightBlueAccent,
              )
            ),
            SizedBox(height: windowRelHeight(0.02),),
            HorizontalLine(length: 80, width: 3, colors: [Colors.cyan, Colors.blue])
          ],
        ),
      )
    );
  }
}

Widget sheetsListView;
List<dynamic> treePath = [];

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
            subtitle: "",
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
                  child: Icon(Icons.keyboard_return, size: 30, color: Colors.white),
                  onPressed: () {
                    treePath.removeLast();
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
      onPressed: () {
        Navigator.of(context).push(slideTransitionBuilder(
            menu: SheetMenu(url: url),
            begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0)
        ));
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blue[100], Colors.grey[100]],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          height: windowRelHeight(0.115),
          child: Center(
              child: Text(
                title,
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
        notifyParent();
      },
      child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blue[100], Colors.grey[100]],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight
            ),
            borderRadius: BorderRadius.circular(15),
          ),
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
                child: Icon(Icons.folder_open, size: 20, color: Colors.blueAccent),
                alignment: Alignment.bottomRight,
              )
            ],
          )
      ),
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
  var response = await http.post("https://quiz-app-db.glitch.me/random_path", body: {'learned_paths': json.encode(learnedPaths), "selected": selected});

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

  var response = await http.post("https://quiz-app-db.glitch.me/random_path", body: {'learned_paths': json.encode(prefs.getStringList("learnedPaths")), "selected": prefs.getString("selectedCategories")});

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