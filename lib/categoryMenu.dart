
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'fontStyles.dart';
import 'components.dart';
import 'sizeControllers.dart';
import 'main.dart';

void updateCategoriesLen () async {
  selectedLen.value[0] = 0;
  for (var i = 0; i < subjects.length; i++) {
    for (var k = 0; k < categories[subjects[i][1]].length; k++) {
      if (selectedCategories[subjects[i][1]][categories[subjects[i][1]][k][1]] == true) {
        selectedLen.value[0]++;
      }
    }
  }

  selectedLen.value = List.from(selectedLen.value);
}

class CategoryMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0x00000000),
      body: Align(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(30))
                ),
                height: windowRelHeight(0.925),
                width: windowRelWidth(0.85),
                child: CategoriesListView(),
              ),
              SizedBox(height: windowRelHeight(0.0125),),
              SizedBox(
                width: windowRelWidth(0.85),
                height: windowRelHeight(0.0625),
                child: RaisedButton(
                  color: Colors.white,
                  child: Text("CONFIRM CATEGORIES", style: TextStyle(
                    color: Colors.green,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w800
                  ),),
                  onPressed: () {
                    updateCategoriesLen();
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                  ),
                )
              )
              
            ],
          )
        )
    );
  }
}


class CategoriesListView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border(top: BorderSide(color: Colors.grey[300]), bottom: BorderSide(color: Colors.grey[300]))
        ),
        height: windowRelHeight(0.925) - 60,
        child: ListView.builder(
          itemCount: subjects.length + 1,
          itemBuilder: (context, index) {
            if (index % 7 == 0) {
              return YearTitle(title: index == 0 ? "PTSI" : "PT");
            }
            List subject = subjects[(index % (subjects.length+1)) - 1];
            return SubjectTile(title: subject[0], subjectId: subject[1]);
          },
        )
      ),
    );
  }
}

class YearTitle extends StatelessWidget {

  final String title;

  YearTitle({@required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: <Widget>[
          Text(title, style: mediumTitleFont3),
          SizedBox(height: windowRelHeight(0.015)),
          HorizontalLine(length: windowRelWidth(0.35), width: 2, colors: [Colors.blueAccent, Colors.blue]),
          SizedBox(height: windowRelHeight(0.015))
        ],
      )
    );
  }
}


class SubjectTile extends StatefulWidget {

  final String title;
  final String subjectId;

  final selectedNumber = ValueNotifier(0);

  var subjectCategories;

  SubjectTile({@required this.title, @required this.subjectId});

  @override
  State<StatefulWidget> createState() {
    int selected = 0;
    selectedCategories[subjectId].forEach( (catID, _value) {
      if(_value == true) {
        selected += 1;
      }
    });
    selectedNumber.value = selected;
    subjectCategories = categories[subjectId];
    return _SubjectTileState();
  }

}

class _SubjectTileState extends State<SubjectTile> with TickerProviderStateMixin {

  AnimationController iconController;
  AnimationController folderController;

  Animation folderAnimation;

  List<CategoryTile> categoryWidgets = [];

  bool collapsed = false;

  double containerHeight = windowRelHeight(0.0775);

  @override
  void initState() {
    super.initState();
    iconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200)
    );
    folderController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500)
    );

    folderAnimation = (Tween(begin: 0.0 , end: 1.0)).animate(folderController);
    for (var i = 0; i < widget.subjectCategories.length; i++) {
      var cat = categories[widget.subjectId][i];
      categoryWidgets.add(
          CategoryTile(
              parentNotifier: widget.selectedNumber,
              catId: cat[1],
              subjId: widget.subjectId,
              callback: categoryChanged,
              index: i,
              title: cat[0]
          )
        );
    }


  }


  @override
  Widget build(BuildContext context) {

    int len = widget.subjectCategories.length;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: containerHeight,
      curve: Curves.fastOutSlowIn,
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            GestureDetector(
              onTap: showCategories,
              child: Dismissible(
                  confirmDismiss: swipeCallBack,
                  background: selectBackground(),
                  secondaryBackground: unSelectBackground(),
                  key: UniqueKey(),
                  child: ListTile(
                      title: ValueListenableBuilder<int>(
                          valueListenable: widget.selectedNumber,
                          builder: (context, value, _) {
                            return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      AnimatedRotatingIcon(controller: iconController,),
                                      Container(
                                        width: value == len ? windowRelWidth(0.43) : null,
                                        child:Text(widget.title, style: mediumTitleFont2, softWrap: false, overflow: TextOverflow.fade, maxLines: 1,),
                                      ),
                                      SizedBox(width: windowRelWidth(0.015),),
                                      value == len ? Icon(Icons.check, color: Colors.green,) : SizedBox()
                                    ],
                                  ),
                                  Text("$value/$len   ", style: mediumTitleFont2,)
                                ]
                            );
                          }
                      )

                  )
              ),
            ),
            !collapsed ? SizedBox() :
            FadeTransition(
                opacity: folderAnimation,
                child: Column(
                    children: categoryWidgets
                )
            )
          ]
      ),
    );

  }

  Future<bool> swipeCallBack(direction) async {
    if (direction == DismissDirection.startToEnd) {
      // Select All
      for (var k = 0; k < categories[widget.subjectId].length; k++) {
        selectedCategories[widget.subjectId][categories[widget.subjectId][k][1]] = true;
      }
      for (final widget in categoryWidgets) {
        widget.updateValue(value: true, all: true);
      }
      widget.selectedNumber.value = widget.subjectCategories.length;
    } else {
      // Deselect All
      for (var k = 0; k < categories[widget.subjectId].length; k++) {
        selectedCategories[widget.subjectId][categories[widget.subjectId][k][1]] = false;
      }
      for (final widget in categoryWidgets) {
        widget.updateValue(value: false, all: true);
      }
      widget.selectedNumber.value = 0;
    }
  }

  void showCategories () {
    if (iconController == null) return;
    setState(() {
      if (collapsed) {
        containerHeight = windowRelHeight(0.0775);
        iconController.reverse();
        folderController.reverse();
      } else {
        containerHeight = windowRelHeight(0.0775 + 0.045*widget.subjectCategories.length);
        iconController.forward();
        folderController.forward();
      }
      collapsed = !collapsed;
    });
  }

  Widget selectBackground () {
    return Container(
      color: Colors.greenAccent[100],
      child: Row(
        children: <Widget>[
          SizedBox(width: windowRelWidth(0.025)),
          Icon(Icons.add_circle_outline, color: Colors.green[900],),
          Text("  Select All", style: mediumTextFontGreen,)
        ],
      ),
    );
  }

  Widget unSelectBackground () {
    return Container(
      color: Colors.redAccent[100],
      child: Row(
        children: <Widget>[
          SizedBox(width: windowRelWidth(0.465)),
          Text("Deselect All  ", style: mediumTextFontRed,),
          Icon(Icons.remove_circle_outline, color: Colors.red[900],),
        ],
      ),
    );
  }

  @override
  void dispose() {
    iconController.dispose();
    folderController.dispose();
    super.dispose();
  }

  void categoryChanged (int index) {
    var cat = categories[widget.subjectId][index][1];
    selectedCategories[widget.subjectId][cat] = !(selectedCategories[widget.subjectId][cat] == null ? false : selectedCategories[widget.subjectId][cat]);
    widget.selectedNumber.value += selectedCategories[widget.subjectId][cat] ? 1 : -1;
  }

}


class CategoryTile extends StatelessWidget {

  final ValueNotifier parentNotifier;
  final catId;
  final subjId;
  final String title;
  final callback;
  final int index;

  CategoryTile({@required this.parentNotifier,
    @required this.catId,
    @required this.subjId,
    @required this.title,
    @required this.callback,
    @required this.index});

  final selectNotifier = ValueNotifier(false);


  @override
  Widget build(BuildContext context) {

    selectNotifier.value = selectedCategories[subjId][catId];

    return GestureDetector(
      onTap: updateValue,
      child: Container(
        height: windowRelHeight(0.045),
        color: Colors.grey[50],
        child:
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(width: 10),
                Icon(Icons.arrow_right, color: Colors.blue[600], ),
                Container(
                  width: windowRelWidth(0.6),
                  child: Text(title, style: mediumTextFont2, softWrap: false, overflow: TextOverflow.fade, maxLines: 1,)
                )
              ],
            ),
            ValueListenableBuilder(
                valueListenable: selectNotifier,
                builder: (context, value, _) {
                  bool condition = value == null ? false : value;
                  return Row(
                    children: <Widget>[
                      condition ?
                      Icon(Icons.check_box, color: Colors.green[400]) :
                      Icon(Icons.check_box_outline_blank, color: Colors.red[400]),
                      SizedBox(width: 20),
                    ],
                  );
                }
            )
          ],
        )
      )
    );
  }

  void updateValue ({value: "undefined", all: false}) {
    if (value == "undefined") {
      selectNotifier.value = !(selectNotifier.value == null ? false : selectNotifier.value);
    } else {
      selectNotifier.value = value;
    }
    if (!all) {
      callback(index);
    }

  }

}