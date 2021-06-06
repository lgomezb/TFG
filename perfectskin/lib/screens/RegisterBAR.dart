import 'package:apple_sign_in/apple_id_request.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:perfectskin/calendar/HomeScreen.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:perfectskin/utils/InputReg.dart';
import 'package:perfectskin/main.dart' as main;
import 'package:perfectskin/screens/Survey.dart';
import 'package:perfectskin/sign_up/RegisterLogin.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'dart:async';
import 'dart:io';


final myController = TextEditingController();
bool existName = false;
bool continue_bool = false;

class RegisterBAR extends StatefulWidget {
  static const String routeName = '/material/progress-indicator';

  @override
  RegisterBARR createState() => RegisterBARR();
}

class RegisterBARR extends State<RegisterBAR>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final _pageController = new PageController();
  var startFocus = new FocusNode();

  void pageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void initState() {
    Future.delayed(Duration(milliseconds: 500), () {
      FocusScope.of(context).requestFocus(startFocus);
    });
  }

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

  @override
  final emailController = TextEditingController();
  final contraController = TextEditingController();
  String email = "";
  String psswd = "";

  Future<bool> _onWillPop() async {
    if (_selectedIndex == 0) {
      Navigator.pop(context);
    }

    if (_selectedIndex >= 1) {
      setState(() {
        _selectedIndex--;
        _pageController.animateToPage(_selectedIndex,
            duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
      });
    }
    return true;
  }

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
            if (_selectedIndex == 0) {
              Navigator.pop(context);
            }
            if (_selectedIndex >= 1) {
              setState(() {
                _selectedIndex = _selectedIndex - 2;
                _pageController.animateToPage(_selectedIndex,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.fastOutSlowIn);
              });
            }
          },
        ),
      ),
    );
  }

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

  Widget build(BuildContext context) {

    return new MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              pageChanged(index);
            },
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
            new Container(
            decoration: new BoxDecoration(
            gradient: new LinearGradient(
            colors: <Color>[Theme.of(context).primaryColor, Theme.of(context).canvasColor],
            stops: [0.2, 1.0],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
          )),
              child: Stack(
                children: <Widget>[
                  exitButton(context),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.1),
                        child: Text(
                          "• " +
                              MyLocalizations.of(context)
                                  .getText('yourname') +
                              " •",
                          style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontSize: 25,
                            fontFamily: 'Dosis',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        margin: new EdgeInsets.symmetric(horizontal: 20.0),
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.02,
                        ),
                        child: InputReg(
                          hint: MyLocalizations.of(context)
                              .getText('entername'),
                          controller: myController,
                          focusNode: startFocus,
                          maxi: 20,
                          textCapitalization: TextCapitalization.sentences,
                          obscure: false,
                          icon: Icons.person,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.05),
                        child: GestureDetector(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.1,
                            alignment: FractionalOffset.center,
                            decoration: new BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: new BorderRadius.all(
                                  const Radius.circular(30.0)),
                            ),
                            child: new Text(
                              MyLocalizations.of(context).getText('next'),
                              style: new TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.07,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          onTap: () async {
                            if (myController.text.trim() != '' &&
                                !myController.text.contains("/")) {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _selectedIndex++;
                                _pageController.animateToPage(1,
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.fastOutSlowIn);
                              });
                            } else if (myController.text.contains("/")) {
                              Fluttertoast.showToast(
                                msg: MyLocalizations.of(context)
                                    .getText('slash'),
                              );
                            } else {
                              _sendNoti(
                                MyLocalizations.of(context)
                                    .getText('errusername'),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              )),
            new Container(
            decoration: new BoxDecoration(
            gradient: new LinearGradient(
            colors: <Color>[Theme.of(context).primaryColor, Theme.of(context).canvasColor],
            stops: [0.2, 1.0],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            )),
              child: Stack(
                children: <Widget>[
                  exitButton(context),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.04,
                        ),
                      ),
                      AvatarGlow(
                        endRadius: MediaQuery.of(context).size.height * 0.152,
                        duration: Duration(seconds: 2),
                        glowColor: Theme.of(context).hintColor,
                        repeat: true,
                        repeatPauseDuration: Duration(seconds: 1),
                        startDelay: Duration(seconds: 1),
                        child: Material(
                            elevation: 8.0,
                            shape: CircleBorder(),
                            child: CircleAvatar(
                                backgroundColor: Theme.of(context).hintColor, //background color of round logo
                                child: SvgPicture.asset(
                                    "assets/img/lotion.svg",
                                    width: 60,
                                    height: MediaQuery.of(context).size.height *
                                        0.125),
                                radius: MediaQuery.of(context).size.height *
                                    0.118)),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.1),
                          child: Center(child:Text(
                            "• " +
                                MyLocalizations.of(context)
                                    .getText('choosesignin') +
                                " •",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.055,
                                fontFamily: 'Dosis',
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.05),
                        child: OutlineButton(
                          splashColor: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _selectedIndex = _selectedIndex + 1;
                              _pageController.animateToPage(_selectedIndex,
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.fastOutSlowIn);
                            });
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                          highlightElevation: 0,
                          borderSide: BorderSide(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.solidEnvelope,
                                  color: Theme.of(context).accentColor,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.035,
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: FittedBox(
                                      child: Text(
                                        MyLocalizations.of(context)
                                            .getText('email'),
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.025,
                                          color: Theme.of(context).scaffoldBackgroundColor,
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
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.02,
                        ),
                      ),
                      _signInButton(
                          myController.text, context),
                      if (Platform.isIOS)
                        Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02,
                          ),
                        ),
                      if (Platform.isIOS)
                        _signInButtonApple(myController.text, context),
                    ],
                  ),
                ],
              )),
              new SingleChildScrollView(
                child: new Container(
                  height: MediaQuery.of(context).size.height,
                decoration: new BoxDecoration(
                gradient: new LinearGradient(
                colors: <Color>[Theme.of(context).primaryColor, Theme.of(context).canvasColor],
                stops: [0.2, 1.0],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.0, 1.0),
                )),
                child: Stack(

                  children: <Widget>[
                    exitButton(context),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.13),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: FittedBox(
                              child: Text(
                                "• " +
                                    MyLocalizations.of(context)
                                        .getText('enteremail') +
                                    " •",
                                style: TextStyle(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    fontFamily: 'Dosis',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),),
                        Container(
                          margin: new EdgeInsets.symmetric(horizontal: 20.0),
                          child: InputReg(
                            hint: MyLocalizations.of(context)
                                .getText('enteremailin'),
                            controller: emailController,
                            focusNode: null,
                            textCapitalization: TextCapitalization.none,
                            maxi: 100,
                            obscure: false,
                            icon: Icons.person_outline,
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.05,
                            ),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: FittedBox(
                                child: Text(
                                  "• " +
                                      MyLocalizations.of(context)
                                          .getText('enterpsswd') +
                                      " •",
                                  style: TextStyle(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      fontFamily: 'Dosis',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                        Container(
                          margin: new EdgeInsets.symmetric(horizontal: 20.0),
                          child: InputReg(
                            hint: MyLocalizations.of(context)
                                .getText('enterpsswdin'),
                            controller: contraController,
                            obscure: true,
                            focusNode: null,
                            textCapitalization: TextCapitalization.none,
                            maxi: 100,
                            icon: Icons.lock_outline,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.05),
                          child: GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.1,
                              alignment: FractionalOffset.center,
                              decoration: new BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: new BorderRadius.all(
                                    const Radius.circular(30.0)),
                              ),
                              child: new Text(
                                MyLocalizations.of(context).getText('signup'),
                                style: new TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.06,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            onTap: () async {
                              try {
                                final result =
                                    await InternetAddress.lookup('google.com');
                                if (result.isNotEmpty &&
                                    result[0].rawAddress.isNotEmpty) {
                                  if (emailController.text != "" &&
                                      emailController.text.contains("@") &&
                                      contraController.text != "" &&
                                      !emailController.text.contains("/")) {
                                    _loading("Hello");

                                    email = emailController.text;
                                    psswd = contraController.text;

                                    RegisterLogin.register(
                                        email.toLowerCase().trim(),
                                        psswd,
                                        context,
                                        myController.text.trim());
                                  } else if (emailController.text
                                      .contains("/")) {
                                    Fluttertoast.showToast(
                                      msg: MyLocalizations.of(context)
                                          .getText('slash'),
                                    );
                                  } else {
                                    _sendNoti(MyLocalizations.of(context)
                                        .getText('credentialerr'));
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                    msg: MyLocalizations.of(context)
                                        .getText('connfail'),
                                  );
                                }
                              } on SocketException catch (_) {
                                Fluttertoast.showToast(
                                    msg: MyLocalizations.of(context)
                                        .getText("connfail"));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavyBar(
            selectedIndex: _selectedIndex,
            showElevation: true,
            backgroundColor : Theme.of(context).primaryColor,
            onItemSelected: (index) => setState(() {}),
            items: [
              BottomNavyBarItem(
                  icon: Icon(FontAwesomeIcons.diceOne, size: 20),
                  title: Text(MyLocalizations.of(context).getText('name')),
                  activeColor: Theme.of(context).hoverColor,
                  inactiveColor: Colors.grey),
              BottomNavyBarItem(
                  icon: Icon(FontAwesomeIcons.diceTwo, size: 20),
                  title: Text(MyLocalizations.of(context).getText('account')),
                  activeColor: Theme.of(context).hoverColor,
                  inactiveColor: Colors.grey),
              BottomNavyBarItem(
                  icon: Icon(FontAwesomeIcons.diceThree, size: 20),
                  title: Text(MyLocalizations.of(context).getText('signupwblanks')),
                  activeColor: Theme.of(context).hoverColor,
                  inactiveColor: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  String name = "";
  String emailC = "";

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
                new TextButton(
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: new Text("Entendido"),
                ),
              ],
            ),
          );
        });
  }

  Future<String> signInWithGoogle(
      String name, BuildContext context) async {
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
          await googleSignIn.signOut();
          FirebaseAuth.instance.signOut();
          main.name = "";
          _noti(MyLocalizations.of(context).getText('alreadyexist'), context);

          return null;
        } else {
          // Checking if email and name is null
          assert(user.email != null);

          emailC = user.email;

          assert(!user.isAnonymous);
          assert(await user.getIdToken() != null);

          print('signInWithGoogle succeeded: $user');

          var status = await OneSignal.shared.getPermissionSubscriptionState();

          Map<String, dynamic> userToRegister = Map();


          userToRegister['email'] = user.email;
          userToRegister['oneSignalId'] = status.subscriptionStatus.userId;
          userToRegister['google'] = true;
          userToRegister['name'] = name;
          userToRegister['isEmailVerified'] = false;
          userToRegister['apple'] = false;



          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userToRegister);

          main.name = name;

          Navigator.of(context, rootNavigator: true).pop('dialog');

          Navigator.push(
            context,
            // We'll create the SelectionScreen in the next step!
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
          return 'bien';
        }
      });
    } else {
      _noti(MyLocalizations.of(context).getText('error'), context);
    }

    return "error";
  }

  Future<String> signInWithApple(
      String name, BuildContext context,
      {List<Scope> scopes = const []}) async {
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
        final user = (await _auth.signInWithCredential(credential)).user;
        if (user != null) {
          if (scopes.contains(Scope.fullName)) {
            _loading("Hello");

            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: user.email)
                .get()
                .then((value) async {
              if (value.docs.length > 0) {
                await googleSignIn.signOut();
                FirebaseAuth.instance.signOut();
                main.name = "";
                _noti(MyLocalizations.of(context).getText('alreadyexist'), context);

                return null;
              } else {
                if (user != null) {
                  // Checking if email and name is null
                  assert(user.email != null);

                  emailC = user.email;

                  assert(!user.isAnonymous);
                  assert(await user.getIdToken() != null);

                  print('signInWithGoogle succeeded: $user');

                  var status =
                      await OneSignal.shared.getPermissionSubscriptionState();

                  Map<String, dynamic> userToRegister = Map();


                  userToRegister['email'] = user.email;
                  userToRegister['oneSignalId'] = status.subscriptionStatus.userId;
                  userToRegister['name'] = name;
                  userToRegister['isEmailVerified'] = false;
                  userToRegister['google'] = false;
                  userToRegister['apple'] = true;


                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .set(userToRegister);

                  main.name = name;
                  Navigator.of(context, rootNavigator: true).pop('dialog');

                  Navigator.push(
                    context,
                    // We'll create the SelectionScreen in the next step!
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                  return 'bien';
                }
              }
            });
          }
        }
        return "bien";

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

  Widget _signInButton(String name, BuildContext context) {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            signInWithGoogle(name, context);
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
      borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage("assets/img/google_logo.png"),

              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.035,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: FittedBox(
                    child: Text(
                      MyLocalizations.of(context).getText('googlesignup'),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.03,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget _signInButtonApple(
      String name, BuildContext context) {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            try {
              await signInWithApple(name, context,
                  scopes: [Scope.email, Scope.fullName]);
            } catch (e) {
              // TODO: Show alert here
              print(e);
            }
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
      borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              FontAwesomeIcons.apple,
              color: Colors.black, //BLACK APPLE
              size: MediaQuery.of(context).size.height * 0.035,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.035,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: FittedBox(
                    child: Text(
                      "Sign up with Apple ID",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.025,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
