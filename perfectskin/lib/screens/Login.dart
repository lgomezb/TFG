import 'dart:io';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/animation.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perfectskin/main.dart' as main;
import 'package:perfectskin/calendar/HomeScreen.dart';
import 'package:perfectskin/sign_up/RegisterLogin.dart';
import 'package:perfectskin/signUp/pages/SignUpLink.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../loginAnimation.dart';
import 'package:perfectskin/sign_up/widgets/InputFields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  AnimationController _loginButtonController;
  var animationStatus = 0;
  final email = TextEditingController();
  final contra = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String name;
  String emailC;

  @override
  void initState() {
    super.initState();
    _loginButtonController = new AnimationController(
        duration: new Duration(milliseconds: 3000), vsync: this);
  }

  @override
  void dispose() { //Close smth
    _loginButtonController.dispose();
    super.dispose();
  }

  Future<String> signInWithApple({List<Scope> scopes = const []}) async { //Function to sign in with Apple ID
    // 1. perform the sign-in request
    final result = await AppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential;

        final AuthCredential credential = OAuthProvider('apple.com').credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        User user = (await _auth.signInWithCredential(credential)).user;
        if (user != null) {
          if (scopes.contains(Scope.fullName)) {
            _loading("hello");
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: user.email)
                .get()
                .then((value) async {
              if (value.docs.length > 0) {

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get()
                    .then((data) {
                  main.name = data['name'];
                });
                // Navigation to the next screen
                Navigator.of(context, rootNavigator: true).pop('dialog');
                Navigator.pop(context);

                Navigator.pushReplacement(
                  context,
                  // We'll create the SelectionScreen in the next step!
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              }
            });
            return "good";
          }
        } else {
          _noti(MyLocalizations.of(context).getText('error'), context);
        }
        return "error";
      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }

  Future<String> signInWithGoogle() async { //Function to sign in with Google
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final User user = (await _auth.signInWithCredential(credential)).user;

    if (user != null) {
      _loading("Hello");
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get()
          .then((value) async {
        if (value.docs.length > 0) {

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .then((data) {
            main.name = data['name'];
          });

          // Navigation to the other screen
          Navigator.of(context, rootNavigator: true).pop('dialog');
          Navigator.pop(context);

          Navigator.pushReplacement(
            context,
            // We'll create the SelectionScreen in the next step!
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          FirebaseAuth.instance.signOut();
          await googleSignIn.signOut();
          _noti(MyLocalizations.of(context).getText('falseemail'), context);
        }
        return null;
      });
    } else {
      _noti(MyLocalizations.of(context).getText('error'), context);
    }
    return "true";
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            signInWithGoogle();
          } else {
            Fluttertoast.showToast(
              msg: MyLocalizations.of(context).getText('connfail'),
            );
          }
        } on SocketException catch (_) {
          Fluttertoast.showToast(
              msg: MyLocalizations.of(context).getText("connfail"));
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.black),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              FontAwesomeIcons.google,
              color: Colors.red,
              size: MediaQuery.of(context).size.height * 0.035,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                MyLocalizations.of(context).getText('logingoogle'),
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.025,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _signInButtonApple() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            signInWithApple(scopes: [Scope.email, Scope.fullName]);
          } else {
            Fluttertoast.showToast(
              msg: MyLocalizations.of(context).getText('connfail'),
            );
          }
        } on SocketException catch (_) {
          Fluttertoast.showToast(
              msg: MyLocalizations.of(context).getText("connfail"));
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              FontAwesomeIcons.apple,
              color: Theme.of(context).scaffoldBackgroundColor,
              size: MediaQuery.of(context).size.height * 0.035,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                MyLocalizations.of(context).getText('loginapple'),
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.025,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _noti(String value, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              Navigator.of(context, rootNavigator: true).pop('dialog');
              return true;
            },
            child: AlertDialog(
              title: new Center(child: Text(value + "\n")),
              content: SvgPicture.asset(
                "assets/images/error.svg",
                width: 140,
                height: 140,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: new Text(
                    MyLocalizations.of(context).getText('agree'),
                  ),
                ),
              ],
            ),
          );
        });
  }

  //Loading animation
  void _loading(String value) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xfff5a623)))));
        });
  }

  //ESTO NO SE LO QUE ES
  void _sendNoti(String value) {
    AlertDialog dialog = new AlertDialog(
      title: new Text(value),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      actions: <Widget>[
        new FlatButton(
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
          child: new Text(
            MyLocalizations.of(context).getText('agree'),
          ),
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  //Button to go to the previous screen
  Widget exitButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.02,
            top: MediaQuery.of(context).size.height * 0.05),
        child: IconButton(
          icon: Icon(Icons.keyboard_arrow_left),
          color: Theme.of(context).scaffoldBackgroundColor,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.4;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return (MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: new WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: new Scaffold(
              body: new Container(
                  decoration: new BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: new Container(
                      decoration: new BoxDecoration(
                          gradient: new LinearGradient(
                        colors: <Color>[
                          Theme.of(context).primaryColor,
                          Theme.of(context).canvasColor
                        ],
                        stops: [0.2, 1.0],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(0.0, 1.0),
                      )),
                      child: new Stack(
                        children: <Widget>[
                          new SingleChildScrollView(
                            child: Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.1,
                                      ),
                                    ),
                                    AvatarGlow(
                                      endRadius:
                                          MediaQuery.of(context).size.height *
                                              0.152,
                                      duration: Duration(seconds: 2),
                                      glowColor: Theme.of(context).buttonColor,
                                      repeat: true,
                                      repeatPauseDuration: Duration(seconds: 2),
                                      startDelay: Duration(seconds: 1),
                                      child: Material(
                                          elevation: 8.0,
                                          shape: CircleBorder(),
                                          child: CircleAvatar(
                                              backgroundColor:
                                                  Theme.of(context).buttonColor,
                                              child: SvgPicture.asset(
                                                  "assets/img/lotion.svg",
                                                  width: 60,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.125),
                                              radius: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.118)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.023),
                                    ),
                                    Container(
                                      margin: new EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Form(
                                              child: new Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              new InputFieldArea(
                                                hint: MyLocalizations.of(
                                                        context)
                                                    .getText('enteremailin'),
                                                controller: email,
                                                obscure: false,
                                                icon: Icons.person_outline,
                                              ),
                                              new InputFieldArea(
                                                hint: MyLocalizations.of(
                                                        context)
                                                    .getText('enterpsswdin'),
                                                controller: contra,
                                                obscure: true,
                                                icon: Icons.lock_outline,
                                              ),
                                            ],
                                          )),
                                        ],
                                      ),
                                    ),
                                    animationStatus == 0
                                        ? new Padding(
                                            padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.05),
                                            child: new InkWell(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  try {
                                                    final result =
                                                        await InternetAddress
                                                            .lookup(
                                                                'google.com');
                                                    if (result.isNotEmpty &&
                                                        result[0]
                                                            .rawAddress
                                                            .isNotEmpty) {
                                                      _loading("Hello");
                                                      if (email.text.trim() !=
                                                              "" &&
                                                          email.text
                                                              .contains("@") &&
                                                          email.text
                                                              .contains(".") &&
                                                          contra.text.trim() !=
                                                              "" &&
                                                          !email.text
                                                              .contains("/")) {
                                                        RegisterLogin.login(context,
                                                            email: email.text
                                                                .trim(),
                                                            password:
                                                                contra.text);
                                                      } else if (email.text
                                                          .contains("/")) {
                                                        Fluttertoast.showToast(
                                                          msg: MyLocalizations
                                                                  .of(context)
                                                              .getText('slash'),
                                                        );
                                                      } else {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop('dialog');
                                                        _sendNoti(
                                                          MyLocalizations.of(
                                                                  context)
                                                              .getText(
                                                                  'credentialerr'),
                                                        );
                                                      }
                                                    } else {
                                                      Fluttertoast.showToast(
                                                        msg: MyLocalizations.of(
                                                                context)
                                                            .getText(
                                                                'connfail'),
                                                      );
                                                    }
                                                  } on SocketException catch (_) {
                                                    Fluttertoast.showToast(
                                                        msg: MyLocalizations.of(
                                                                context)
                                                            .getText(
                                                                "connfail"));
                                                  }
                                                },
                                                child:
                                                    Column(children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.025),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.83,
                                                      height: 95,
                                                      alignment:
                                                          FractionalOffset
                                                              .center,
                                                      decoration:
                                                          new BoxDecoration(
                                                        color: Theme.of(context)
                                                            .scaffoldBackgroundColor,
                                                        borderRadius:
                                                            new BorderRadius
                                                                .all(const Radius
                                                                    .circular(
                                                                30.0)),
                                                      ),
                                                      child: new Text(
                                                        MyLocalizations.of(
                                                                context)
                                                            .getText('access'),
                                                        style: new TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor,
                                                          fontSize: 23.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 0.3,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  _signInButton(),
                                                  (Platform.isIOS)
                                                      ? Padding(
                                                          padding: EdgeInsets.only(
                                                              bottom: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.03),
                                                        )
                                                      : Container(),
                                                  (Platform.isIOS)
                                                      ? _signInButtonApple()
                                                      : Container(),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.03),
                                                  ),
                                                ]),
                                              ),
                                            ),
                                          )
                                        : new StaggerAnimation(
                                            buttonController:
                                                _loginButtonController.view
                                                    as AnimationController),
                                    new SignUp(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          exitButton(context),
                        ],
                      ))),
            ))));
  }
}
