import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:perfectskin/product_list/ProductList.dart';
import 'package:perfectskin/screens/Entrada.dart';
import 'package:perfectskin/screens/SelectorRutina.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:perfectskin/main.dart' as main;
import 'package:perfectskin/stepper/Routine.dart';
import 'package:perfectskin/alarm/reminder_page.dart';
import '../DelayedAnimation.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int delayedAmount = 500;
  double _scale = 1;
  CalendarController _controller;
  User user;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();

    user = FirebaseAuth.instance.currentUser;
  }

  logout(BuildContext context) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        await FirebaseAuth.instance.signOut();

        Navigator.pushReplacement(
          context,
          // We'll create the SelectionScreen in the next step!
          MaterialPageRoute(builder: (context) => Entrada()),
        );
      }
    } on SocketException catch (_) {
      Fluttertoast.showToast(
          msg: MyLocalizations.of(context).getText("errconnection"));
    }
  }

  void _enviarNoti(String value, BuildContext context) {
    AlertDialog dialog = new AlertDialog(
      title: new Text(value),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      actions: <Widget>[
        new TextButton(
          onPressed: () async {
            logout(context);

            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
          child: new Text(
            MyLocalizations.of(context).getText('yes'),
            style: TextStyle(color: Colors.red),
          ),
        ),
        new TextButton(
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
          child: new Text(
            MyLocalizations.of(context).getText('no'),
          ),
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  String hora() {
    var hour = DateTime.now().hour;
    if (hour <= 12) {
      return MyLocalizations.of(context).getText('morning');
    }
    if (hour <= 21) {
      return MyLocalizations.of(context).getText('evening');
    }
    return MyLocalizations.of(context).getText('night');
  }

  Widget appBarColumn(BuildContext context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 2,
            right: 8,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 64,
            child: new Column(
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        height: 60,
                        child: IconButton(
                          icon:
                              Icon(Icons.power_settings_new, color: Colors.red),
                          onPressed: () {
                            _enviarNoti(
                                MyLocalizations.of(context).getText('logout'),
                                context);
                          },
                        )),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      height: 60,
                      child: ProfileTile(
                        title: (main.name != null)
                            ? hora() + ", " + main.name
                            : hora(),
                        subtitle:
                            MyLocalizations.of(context).getText('subtitle'),
                        textColor: Colors.black,
                      ),
                    ),
                    Container(
                      width: 35,
                      height: 35,
                      child: (user != null && user.photoURL != null)
                          ? CachedNetworkImage(
                              imageUrl: user.photoURL,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: 30,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              ),
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )
                          : Material(
                              elevation: 8.0,
                              shape: CircleBorder(),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                child: SvgPicture.asset(
                                  "assets/img/lotion.svg",
                                  height: 23,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
            //child:Container(
            children: [
          new Stack(children: [
            new Container(
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
            ),
            new SafeArea(
              child: SingleChildScrollView(
                  child: new Column(children: [
                appBarColumn(context),
                Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.025)),
                new Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    height: 327,
                    width: 380,
                    child: new Card(
                      elevation: 5.0,
                      clipBehavior: Clip.antiAlias,
                      color: Theme.of(context).hintColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TableCalendar(
                            locale: 'en_US',
                            initialCalendarFormat: CalendarFormat.month,
                            calendarStyle: CalendarStyle(
                                //todayColor: Colors.blue,
                                //selectedColor: Theme.of(context).primaryColor,
                                // todayStyle: TextStyle(
                                //fontWeight: FontWeight.bold,
                                //fontSize: 30.0,
                                // color: Colors.white)
                                ),
                            headerStyle: HeaderStyle(
                              centerHeaderTitle: true,
                              formatButtonDecoration: BoxDecoration(
                                //CAJA DEL MES, 2 SEMAS O SEMANA A SEMANA
                                color: Colors.brown, //Month color
                                borderRadius:
                                    BorderRadius.circular(22.0), //Month radius
                              ),
                              formatButtonTextStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              //Month text
                              formatButtonShowsNext: false,
                            ),
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            //onDaySelected: (date, events) async => print(date.toUtc()),
                            builders: CalendarBuilders(
                              selectedDayBuilder: (context, date, events) =>
                                  Container(
                                      //el día que uno selecciona
                                      margin: const EdgeInsets.all(5.0),
                                      //selected day edges
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      child: Text(
                                        date.day.toString(),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor), //selected day color
                                      )),
                              todayDayBuilder: (context, date, events) =>
                                  Container(
                                      //today
                                      margin: const EdgeInsets.all(5.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).accentColor,
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      child: Text(
                                        date.day.toString(),
                                        style: TextStyle(color: Colors.white),
                                      )),
                            ),
                            calendarController: _controller,
                          )
                        ],
                      ),
                    )),
                new Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05),
                  //vertical: MediaQuery.of(context).size.width * 0.1),
                  //height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    children: <Widget>[
                      DelayedAnimation(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              //Antes era pushReplacement <- Sirve para retroceder o pasar a la siguiente pantalla
                              context,
                              // We'll create the SelectionScreen in the next step!
                              MaterialPageRoute(
                                  builder: (context) => ProductList()),
                            ); //This zone is listening
                          },
                          child: Transform.scale(
                            scale: _scale,
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.08,
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor, //Button color
                              ),
                              child: Center(
                                child: Text(
                                  MyLocalizations.of(context)
                                      .getText('myproducts'),
                                  textScaleFactor: 1.5,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .buttonColor, //TextColor
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.03),
                        child: DelayedAnimation(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                //Antes era pushReplacement <- Sirve para retroceder o pasar a la siguiente pantalla
                                context,
                                // We'll create the SelectionScreen in the next step!
                                MaterialPageRoute(
                                    builder: (context) => AlarmPage()),
                              ); //This zone is listening
                            },
                            child: Transform.scale(
                              scale: _scale,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor, //Button color
                                ),
                                child: Center(
                                  child: Text(
                                    MyLocalizations.of(context)
                                        .getText('reminders'),
                                    textScaleFactor: 1.5,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .buttonColor, //TextColor
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.03),
                        child: DelayedAnimation(
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                //Antes era pushReplacement <- Sirve para retroceder o pasar a la siguiente pantalla
                                context,
                                // We'll create the SelectionScreen in the next step!
                                MaterialPageRoute(
                                    builder: (context) => SelectorRutina()),
                              ); //This zone is listening
                            },
                            child: Transform.scale(
                              scale: _scale,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor, //Button color
                                ),
                                child: Center(
                                  child: Text(
                                    MyLocalizations.of(context)
                                        .getText('myroutines'),
                                    textScaleFactor: 1.5,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .buttonColor, //TextColor
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ])),
            )
          ])
        ]
            /*bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
        barBackgroundColor: Colors.white,
          selectedItemBorderColor: Colors.white,
          selectedItemBackgroundColor: main.primaryColor,
          selectedItemIconColor: Colors.white,
          selectedItemLabelColor: Colors.black,
        ),
      selectedIndex: _selectedIndex,
      onSelectTab: (index) {
        setState(() {
          _selectedIndex = index;
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 100), curve: Curves.ease);
        });
      },
      items: [
        FFNavigationBarItem(
          iconData: Icons.assignment,
          label: MyLocalizations.of(context).getText("listas"),
        ),
        FFNavigationBarItem(
          iconData: Icons.shopping_cart,
          label: MyLocalizations.of(context).getText("compras"),
        ),
        FFNavigationBarItem(
          iconData: Icons.people,
          label: MyLocalizations.of(context).getText("grupos"),
        ),
        FFNavigationBarItem(
          iconData: Icons.settings,
          label: MyLocalizations.of(context).getText("ajustes"),
        ),
      ],
    ),*/
            ));
  }
}

class ProfileTile extends StatelessWidget {
  final title;
  final subtitle;
  final textColor;

  ProfileTile({this.title, this.subtitle, this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.w700, color: textColor, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        Container(
          alignment: Alignment.center,
          child: Text(
            subtitle,
            overflow: TextOverflow.fade,
            style: TextStyle(
                fontWeight: FontWeight.normal, color: textColor, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
