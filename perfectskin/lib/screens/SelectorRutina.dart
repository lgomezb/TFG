import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:perfectskin/stepper/Routine.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';
import 'package:perfectskin/main.dart' as main;

import 'Survey.dart';

final themeColor = Color(0xfff5a623);
final primaryColor = Color(0xff203152);
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);
List<String> playerIds = [];

class SelectorRutina extends StatefulWidget {
  SelectorRutina({Key key}) : super(key: key);

  @override
  State createState() => new Historialss();
}

class Historialss extends State<SelectorRutina> {
  Historialss({Key key});

  var listMessage;

  File imageFile;
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
  }

  void onSendMessage(String name) async {
    Navigator.push(
      //Antes era pushReplacement <- Sirve para retroceder o pasar a la siguiente pantalla
      context,
      // We'll create the SelectionScreen in the next step!
      MaterialPageRoute(
          builder: (context) => Survey(
              name)),
    );
  }

  void _sendNoti(BuildContext context) {
    final nameController = TextEditingController();

    AlertDialog dialog = new AlertDialog(
      title: new Center(
          child: Text(
            "• " + MyLocalizations.of(context).getText('nameroutine') + " •",
            textScaleFactor: 1.0,
          )),
      content: Container(
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: new EdgeInsets.symmetric(horizontal: 5.0),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: TextField(

                  maxLength: 20,
                  style: TextStyle(color: Colors.black, fontSize: 15.0),
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration.collapsed(
                    hintText: MyLocalizations.of(context).getText('writename'),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      actions: <Widget>[
        FlatButton(
          child: Text(MyLocalizations.of(context).getText('continue')),
          onPressed: () {
            if (nameController.text.trim() != '' &&
                !nameController.text.contains("/")) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              onSendMessage(nameController.text.trim());
            } else if (nameController.text.contains("/")) {
              Fluttertoast.showToast(
                msg: MyLocalizations.of(context).getText('slash'),
              );
            } else {
              Fluttertoast.showToast(
                  msg: MyLocalizations.of(context).getText('writename'));
            }
          },
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(MyLocalizations.of(context).getText('routines'), style: TextStyle(color: Theme.of(context).buttonColor)), backgroundColor: Theme.of(context).scaffoldBackgroundColor,),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _sendNoti(
               context);
        },
        child: Icon(Icons.add, color: Theme.of(context).buttonColor,),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Stack(
      children: <Widget>[
        new Container(
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
        ),
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 7.0),
            ),
            buildListMessage(),
          ],
        ),
      ],
      ),
    );
  }
  void dejarpulsado(
      String value, BuildContext context, DocumentSnapshot snapshot) {
    User user = FirebaseAuth.instance.currentUser;

    AlertDialog dialog = new AlertDialog(
      title: new Text(value),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      actions: <Widget>[
        new FlatButton(
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('routines')
                .doc(snapshot.id)
                .delete();
          },
          child: new Text(MyLocalizations.of(context).getText('yes'),
              style: TextStyle(color: Colors.red)),
        ),
        new FlatButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
          child: new Text(MyLocalizations.of(context).getText('no'),
              style: TextStyle(color: Colors.blue)),
        )
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }
  Widget mainCard(DocumentSnapshot snapshot) => GestureDetector(
    onLongPress: () {
      dejarpulsado(MyLocalizations.of(context).getText('delete'), context, snapshot);
    },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Text(
                          snapshot['name'],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0,
                              color: Colors.black),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          User user = FirebaseAuth.instance.currentUser;
                          List info = [];
                          List pos = [0, 0, 0, 0, 0, 0];
                          int products = 0;

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('routines')
                              .doc(snapshot['name'])
                              .get()
                              .then((result) {
                            setState(() {
                              info = result['question'];
                              for (int i = 0; i < 6; i++) {
                                if (info[i] == 1) {
                                  pos[i] = products;
                                  products++;
                                } else {
                                  pos[i] = 9;
                                }
                              }
                            });
                          });
                          print(pos);

                          Navigator.push(
                            //Antes era pushReplacement <- Sirve para retroceder o pasar a la siguiente pantalla
                            context,
                            // We'll create the SelectionScreen in the next step!
                            MaterialPageRoute(
                                builder: (context) => Routine(
                                    products: products, pos: pos, info: info)),
                          ); //This zone is listening
                        },
                        child: Material(
                          color: Colors.blue,
                          shape: StadiumBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Text(
                                MyLocalizations
                                    .of(context)
                                    .getText('start'),
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
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
        ),
      );

  Widget buildListMessage() {
    User user = FirebaseAuth.instance.currentUser;

    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('routines')
            .snapshots(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else {

            listMessage = snapshot.data.docs;
            if (listMessage.length == 0) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.02),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.28,
                      child: FittedBox(
                        child: SvgPicture.asset(
                          "assets/img/shelves.svg",
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: FittedBox(
                        child: Text(
                          MyLocalizations.of(context).getText('noroutines'),
                          style: TextStyle(
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {

            return ListView.builder(
              itemBuilder: (context, index) =>
                  mainCard(snapshot.data.docs[index]),
              itemCount: snapshot.data.docs.length,
              reverse: false,
              controller: listScrollController,
            );
          }}
        },
      ),
    );
  }
}

class LabelIcon extends StatelessWidget {
  final label;
  final icon;
  final iconColor;
  final onPressed;

  LabelIcon(
      {this.label, this.icon, this.onPressed, this.iconColor = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPressed,
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: iconColor,
          ),
          SizedBox(
            width: 5.0,
          ),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w700),
          )
        ],
      ),
    );
  }
}
