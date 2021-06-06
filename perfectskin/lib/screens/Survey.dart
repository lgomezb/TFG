import 'dart:async';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:perfectskin/calendar/HomeScreen.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';


class Survey extends StatefulWidget {
  String name;

  Survey(this.name);
  @override
  SurveyState createState() {
    // TODO: implement createState
    return SurveyState();
  }
}

class SurveyState extends State<Survey>
    with TickerProviderStateMixin {
  AnimationController _animateController;
  AnimationController _longPressController;
  AnimationController _secondStepController;
  AnimationController _thirdStepController;
  AnimationController _fourStepController;

  double overall = 3.0;
  String overallStatus = "Good";
  int curIndex = 0;
  String usingTimes = 'Daily';


  List<SecondQuestion> usingCollection = [
    SecondQuestion('normal', 'Normal'),
    SecondQuestion('dry', 'Dry'),
    SecondQuestion('oily', 'Oily'),
    SecondQuestion('combination', 'Combination'),
    SecondQuestion('sensitive', 'Sensitive'),
    SecondQuestion('idk', 'I do not know'),

  ];

  Animation<double> longPressAnimation;
  Animation<double> secondTranformAnimation;
  Animation<double> thirdTranformAnimation;
  Animation<double> fourTranformAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _animateController = AnimationController(
        duration: Duration(milliseconds: 0), vsync: this);
    _longPressController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    _secondStepController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    _thirdStepController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    _fourStepController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    longPressAnimation =
        Tween<double>(begin: 1.0, end: 2.0).animate(CurvedAnimation(
            parent: _longPressController,
            curve: Interval(
              0.1,
              1.0,
              curve: Curves.fastOutSlowIn,
            )));

    fourTranformAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _fourStepController,
            curve: Interval(
              0.1,
              1.0,
              curve: Curves.fastOutSlowIn,
            )));

    secondTranformAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _secondStepController,
            curve: Interval(
              0.1,
              1.0,
              curve: Curves.fastOutSlowIn,
            )));

    thirdTranformAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _thirdStepController,
            curve: Interval(
              0.1,
              1.0,
              curve: Curves.fastOutSlowIn,
            )));

    _longPressController.addListener(() {
      setState(() {});
    });

    _secondStepController.addListener(() {
      setState(() {});
    });

    _thirdStepController.addListener(() {
      setState(() {});
    });

    _fourStepController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animateController.dispose();
    _secondStepController.dispose();
    _thirdStepController.dispose();
    _fourStepController.dispose();
    _longPressController.dispose();
    super.dispose();
  }

  Future _startAnimation() async {
    try {
      await _animateController
          .forward()
          .orCancel;
      setState(() {});
    } on TickerCanceled {}
  }

  Future _startSecondStepAnimation() async {
    try {
      await _secondStepController
          .forward()
          .orCancel;
    } on TickerCanceled {}
  }

  Future _startThirdStepAnimation() async {
    try {
      await _thirdStepController
          .forward()
          .orCancel;
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    final ui.Size logicalSize = MediaQuery
        .of(context)
        .size;
    final double _width = logicalSize.width;

    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Container(
          decoration: new BoxDecoration(
              gradient: new LinearGradient(
                colors: <Color>[
                  Color.fromRGBO(238, 211, 196, 1),
                  Color.fromRGBO(217, 163, 150, 1),
                ],
                stops: [0.2, 1.0],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.0, 1.0),
              )),
          padding: EdgeInsets.all(16.0),
          child: _animateController.isCompleted
              ? getPages(_width)
              : AnimationBox(
            controller: _animateController,
            screenWidth: _width - 32.0,
            onStartAnimation: () {
              _startAnimation();
              _startThirdStepAnimation();
            },
          ),
        ),
      ),
      bottomNavigationBar: _animateController.isCompleted
          ? BottomAppBar(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withAlpha(200))]),
            height: 50.0,
            child: GestureDetector(
              onTap: () async {
                setState(()  {

                  User user = FirebaseAuth.instance.currentUser;
                   List usadas = [];
                    for(int i = 0; i< thirdQuestionList.length; i++) {
                      if(thirdQuestionList[i].get()) {
                        usadas.add(1);
                      } else {
                        usadas.add(0);
                      }
                    }
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('routines')
                        .doc(widget.name)
                        .set({
                      'name': widget.name,
                      'question': usadas,
                    });//TENGO QUE METER LA SUBIDA DE DATOS A FIREBASE. SUBIR usingTimes 281
                    Navigator.pop(context);
                  }
                );
              },
              child: Center(
                  child: Text(
                    MyLocalizations.of(context).getText('finish'),
                    style: TextStyle(
                        fontSize: 32.0, color: Theme.of(context).scaffoldBackgroundColor),
                  )),
            ),
          ))
          : null,
    );
  }

  Widget getPages(double _width) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
//                color: Colors.blue,
          margin: EdgeInsets.only(top: 30.0),
          height: 10.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(1, (int index) {
              return Container(
                decoration: BoxDecoration(
                  color: index <= curIndex ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).hoverColor,
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
                height: 10.0,
                width: (_width - 32.0 - 25.0),
                margin: EdgeInsets.only(left: index == 0 ? 0.0 : 5.0),
              );
            }),
          ),
        ),
        _getThirdStep()
      ],
    );
  }

  Widget _getSecondStep() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 34.0),
        child: Transform(
          transform: new Matrix4.translationValues(
              0.0, 50.0 * (1.0 - secondTranformAnimation.value), 0.0),
          child: Opacity(
            opacity: secondTranformAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Question 1'),
                Container(
                    margin: EdgeInsets.only(top: 16.0),
                    child: Text('Which is your skin type?')),
                Expanded(
                  child: Center(
                    child: Container(
                      height: 308.0,
                      child: Card(
                        child: Column(
                          children: List.generate(usingCollection.length,
                                  (int index) {
                                final using = usingCollection[index];
                                return GestureDetector(
                                  onTapUp: (detail) {
                                    setState(() {
                                      usingTimes = using.identifier;
                                    });
                                  },
                                  child: Container(
                                    height: 50.0,
                                    color: usingTimes == using.identifier
                                        ? Theme.of(context).canvasColor.withAlpha(100)
                                        : Theme.of(context).accentColor,
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Radio(
                                                activeColor: Theme.of(context).hoverColor,
                                                value: using.identifier,
                                                groupValue: usingTimes,
                                                onChanged: (String value) {
                                                  setState(() {
                                                    usingTimes = value;
                                                  });
                                                }),
                                            Text(using.displayContent)
                                          ],
                                        ),
                                        Divider(
                                          height: index < usingCollection.length
                                              ? 1.0
                                              : 0.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<ThirdQuestion> thirdQuestionList = [
    ThirdQuestion('Cleanser', false),
    ThirdQuestion('Toner', false),
    ThirdQuestion('Serum', false),
    ThirdQuestion('Cream', false),
    ThirdQuestion('Moisturize', false),
    ThirdQuestion('Face oil', false),


  ];

  Widget _getThirdStep() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 34.0),
        child: Transform(
          transform: new Matrix4.translationValues(
              0.0, 50.0 * (1.0 - thirdTranformAnimation.value), 0.0),
          child: Opacity(
            opacity: thirdTranformAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(MyLocalizations.of(context).getText('question')),
                Container(
                    margin: EdgeInsets.only(top: 16.0),
                    child: Text(MyLocalizations.of(context).getText('whichproducts'))),
                Expanded(
                  child: Center(
                    child: Container(
                      height: 314.0,
                      child: Card(
                        child: Column(
                          children: List.generate(thirdQuestionList.length,
                                  (int index) {
                                ThirdQuestion question = thirdQuestionList[index];
                                return Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTapUp: (detail) {
                                        setState(() {
                                          question.isSelected =
                                          !question.isSelected;
//                                  isFairly = !isFairly;
                                        });
                                      },
                                      child: Container(
                                        height: 50.0,
                                        color: question.isSelected
                                            ? Colors.orangeAccent.withAlpha(100)
                                            : Colors.white,
                                        child: Row(
                                          children: <Widget>[
                                            Checkbox(
                                                activeColor: Colors
                                                    .orangeAccent,
                                                value: question.isSelected,
                                                onChanged: (bool value) {
//                                          print(value);
                                                  setState(() {
                                                    question.isSelected = value;
                                                  });
                                                }),
                                            Text(question.displayContent)
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: index < thirdQuestionList.length
                                          ? 1.0
                                          : 0.0,
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class AnimationBox extends StatelessWidget {
  AnimationBox(
      {Key key, this.controller, this.screenWidth, this.onStartAnimation})
      : width = Tween<double>(
    begin: screenWidth,
    end: 40.0,
  ).animate(
    CurvedAnimation(
      parent: controller,
      curve: Interval(
        0.1,
        0.3,
        curve: Curves.fastOutSlowIn,
      ),
    ),
  ),
        alignment = Tween<AlignmentDirectional>(
          begin: AlignmentDirectional.bottomCenter,
          end: AlignmentDirectional.topStart,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.3,
              0.6,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        radius = BorderRadiusTween(
          begin: BorderRadius.circular(20.0),
          end: BorderRadius.circular(2.0),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.6,
              0.8,
              curve: Curves.ease,
            ),
          ),
        ),
        height = Tween<double>(
          begin: 40.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.3,
              0.8,
              curve: Curves.ease,
            ),
          ),
        ),
        movement = EdgeInsetsTween(
          begin: EdgeInsets.only(top: 0.0),
          end: EdgeInsets.only(top: 30.0),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.3,
              0.6,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        scale = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.8,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        opacity = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.8,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        numberOfStep = IntTween(
          begin: 1,
          end: 4,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.8,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        super(key: key);

  final VoidCallback onStartAnimation;
  final Animation<double> controller;
  final Animation<double> width;
  final Animation<double> height;
  final Animation<AlignmentDirectional> alignment;
  final Animation<BorderRadius> radius;
  final Animation<EdgeInsets> movement;
  final Animation<double> opacity;
  final Animation<double> scale;
  final Animation<int> numberOfStep;
  final double screenWidth;
  final double overral = 3.0;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget child) {
        return Stack(
          alignment: alignment.value,
          children: <Widget>[
            Opacity(
              opacity: 1.0 - opacity.value,
              child: Column(
                children: <Widget>[
                  Container(
//                color: Colors.blue,
                    margin: EdgeInsets.only(top: 30.0),
                    height: 10.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(numberOfStep.value, (int index) {
                        return Container(
                          decoration: BoxDecoration(
//                    color: Colors.orangeAccent,
                            color:
                            index == 0 ? Colors.orangeAccent : Colors.grey,
                            borderRadius:
                            BorderRadius.all(Radius.circular(2.0)),
                          ),
                          height: 10.0,
                          width: (screenWidth - 15.0) / 5.0,
                          margin: EdgeInsets.only(left: index == 0 ? 0.0 : 5.0),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity:
              controller.status == AnimationStatus.dismissed ? 1.0 : 0.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                      child: Center(
                        child: Image.asset('assets/img/lotion.png'),
                      )),
                  Text(
                    'We want to know to know you better!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 170.0),
                    child: Text(
                      'By answering this survey, you help us improve your experience in the app',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Opacity(
              opacity: opacity.value,
              child: GestureDetector(
                onTap: onStartAnimation,
                child: Transform.scale(
                  scale: scale.value,
                  child: Container(
                    margin: movement.value,
                    width: width.value,
                    child: GestureDetector(
                      child: Container(
                        margin: new EdgeInsets.symmetric(vertical: 60.0,horizontal:8.0),
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: radius.value),
                        child: Center(
                          child: controller.status == AnimationStatus.dismissed
                              ? Text(
                            'Start creating my routine',
                            style: TextStyle(
                                color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
                          )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
//            Opacity(
//              opacity: 1.0 - opacity.value,
//              child:
//            ),
          ],
        );
      },
    );
  }
}

class SecondQuestion {
  final String identifier;
  final String displayContent;

  SecondQuestion(this.identifier, this.displayContent);
}

class ThirdQuestion {
  final String displayContent;
  bool isSelected;

  ThirdQuestion(this.displayContent, this.isSelected);

  bool get() {
    return isSelected;
  }
}