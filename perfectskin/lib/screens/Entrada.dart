import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:perfectskin/DelayedAnimation.dart';
import 'package:flutter/material.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';
import 'package:perfectskin/screens/RegisterBAR.dart';

import 'Login.dart';

//Clase que contiene un widget con estado mutable y puede cambiar durante su vida util
class Entrada extends StatefulWidget {
  @override
  _Entrada createState() => _Entrada();
}

//Variable que no puede modificarse

class _Entrada extends State<Entrada> with SingleTickerProviderStateMixin {
  final int delayedAmount = 500;
  double _scale = 1;
  AnimationController _controller = null;

  //Method to be executed when screen is loaded
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
      setState(() {});
    });

    super.initState();
  }

  static Future<void> pop({bool animated}) async {
    await SystemChannels.platform
        .invokeMethod<void>('SystemNavigator.pop', animated);
  }

  @override
  void dispose() { //Method that execute when the window is closed
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final color = Colors.white;
    _scale = 1 - _controller.value;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //Para que el tamaño de fuete no cambie
        child: WillPopScope( //Recoge que pasa si el user da "atras"
          onWillPop: () async { //Cuando se cierra
            pop();
            return true;
          },
          child: Scaffold( //Hijos del padre onWillPop
            body: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.022,
                  ),
                  AvatarGlow(
                    endRadius: MediaQuery.of(context).size.height * 0.152,
                    duration: Duration(seconds: 2),
                    glowColor: Theme.of(context).hintColor,

                    repeat: true,
                    repeatPauseDuration: Duration(seconds: 2),
                    startDelay: Duration(seconds: 1),
                    child: Material(
                        elevation: 8.0,
                        shape: CircleBorder(),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[100],
                          child: SvgPicture.asset(
                            "assets/img/lotion.svg",
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          radius: MediaQuery.of(context).size.height * 0.0845,
                        )),
                  ),
                  
                  Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: FittedBox(
                      child: Column(
                        children: <Widget>[
                          DelayedAnimation(
                            child: Text(
                              "Welcome to",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Theme.of(context).scaffoldBackgroundColor),
                            ),
                            delay: delayedAmount + 1000,
                          ),
                          DelayedAnimation(
                            child: Text(
                              "PerfectSkin",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Theme.of(context).scaffoldBackgroundColor),
                            ),
                            delay: delayedAmount + 2000,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: FittedBox(
                      child: Column(children: <Widget>[
                        DelayedAnimation(
                          child: Text(
                            "Sign up and start",
                            style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
                          ),
                          delay: delayedAmount + 3000,
                        ),
                        DelayedAnimation(
                          child: Text(
                            "caring your face",
                            style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
                          ),
                          delay: delayedAmount + 3000,
                        ),
                      ]),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.12,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: FittedBox(
                      child: Column(
                        children: <Widget>[
                          DelayedAnimation(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push( //Antes era pushReplacement <- Sirve para retroceder o pasar a la siguiente pantalla
                                  context,
                                  // We'll create the SelectionScreen in the next step!
                                  MaterialPageRoute(builder: (context) => RegisterBAR()),
                                );        //This zone is listening
                      },
                              child: Transform.scale(
                                scale: _scale,
                                child: Container(
                                  height: MediaQuery.of(context).size.height *
                                      0.1025,
                                  width:
                                  MediaQuery.of(context).size.width * 0.725,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100.0),
                                    color: Theme.of(context).scaffoldBackgroundColor, //Button color
                                  ),
                                  child: Center(
                                    child: Text(
                                      MyLocalizations.of(context).getText('c_account'),
                                      textScaleFactor: 1.24,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).buttonColor, //TextColor
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            delay: delayedAmount + 4000,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.06),
                            child: DelayedAnimation(
                              child: GestureDetector(
                                child: Text(
                                  "SIGN IN",
                                  textScaleFactor: 1.2,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).scaffoldBackgroundColor),
                                ),
                                onTap: () {
                                  Navigator.push( //Antes era pushReplacement <- Sirve para retroceder o pasar a la siguiente pantalla
                                    context,
                                    // We'll create the SelectionScreen in the next step!
                                    MaterialPageRoute(builder: (context) => LoginScreen()),
                                  );        //This zone is listening
                                },
                              ),
                              delay: delayedAmount + 5000,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
