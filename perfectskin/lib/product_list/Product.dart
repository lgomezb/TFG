import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:perfectskin/product_list/uploadphoto/UploadPhoto.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../utils/Size_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Product extends StatefulWidget {
  Map<String, dynamic> document;

  BuildContext cheinherit;

  Product({Key key, @required this.document, this.cheinherit})
      : super(key: key);

  @override
  State createState() =>
      new Products(document: document, cheinherit: cheinherit);
}

class Products extends State<Product> {
  Map<String, dynamic> document;
  String nameproduct;
  bool mover = false;
  BuildContext cheinherit;
  FocusNode focus;

  Products({Key key, @required this.document, this.cheinherit});

  void initState() {
    super.initState();
    nameproduct = document['name'];
    focus = new FocusNode();
    loadImage();
  }

  void rename(String value, BuildContext context) {
    final nameController = TextEditingController();

    AlertDialog dialog = new AlertDialog(
      title: new Center(
          child: Text(
            MyLocalizations.of(context).getText('newname'),
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
                  focusNode: focus,
                  maxLength: 20,
                  style: TextStyle(color: Colors.black, fontSize: 15.0),
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration.collapsed(
                    hintText: MyLocalizations.of(context).getText('rename2'),
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
          child: Text(MyLocalizations.of(context).getText('rename')),
          onPressed: () async {
            User user = FirebaseAuth.instance.currentUser;
            if (nameController.text.trim() != '' &&
                !nameController.text.contains("/")) {
              if (nameController.text != nameproduct) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('products')
                    .doc(value)
                    .get()
                    .then((data) async {
                  var message = {
                    'timestamp': data['timestamp'],
                    'name': nameController.text.trim(),
                    'index': data['index'],
                  };

                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('products')
                      .doc(nameController.text.trim())
                      .set(message);

                  data.reference.delete();
                });
                Navigator.of(context, rootNavigator: true).pop('dialog');
              }
            } else if (nameController.text.contains("/")) {
              Fluttertoast.showToast(
                msg: MyLocalizations.of(context).getText('slash'),
              );
            } else {
              Fluttertoast.showToast(
                  msg: MyLocalizations.of(context).getText('rename2'));
            }
          },
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  void _sendNoti(String value, String name) {
    AlertDialog dialog = new AlertDialog(
      title: new Text(value),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      actions: <Widget>[
        new Center(
          child: FlatButton(
            onPressed: () async {
              try {
                final result = await InternetAddress.lookup(
                    'google.com'); //COMPRUEBA PETICION A GOOGLE
                if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                  User user = FirebaseAuth.instance.currentUser;
                  _loading(context);

                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('products')
                      .doc(name)
                      .delete();

                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  Navigator.of(context, rootNavigator: true).pop('dialog');
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
            child: new Text(MyLocalizations.of(context).getText('del_button'),
                style: TextStyle(color: Colors.red)),
          ),
        ),
        new Center(
          child: FlatButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              setState(() {
                mover = true;
              });
            },
            child: new Text(
              MyLocalizations.of(context).getText('reorganize'),
            ),
          ),
        ),
        new Center(
            child: FlatButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  Navigator.push(
                    context,
                    // We'll create the SelectionScreen in the next step!
                    MaterialPageRoute(
                        builder: (context) => ImageCapture(
                          name: name,
                        )),
                  );
                },
                child: new Text(
                  MyLocalizations.of(context).getText("changephoto"),
                ))),
        new Center(
            child: FlatButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  rename(name, context);
                },
                child: new Text(
                  MyLocalizations.of(context).getText("rename").toUpperCase(),
                )))
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  void _loading(BuildContext context) {
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

  CachedNetworkImageProvider a;
  var url;
  NetworkImage icono;

  void loadImage() async {
    String user = FirebaseAuth.instance.currentUser.uid;
    String name = document['name'];
    final ref = FirebaseStorage.instance.ref().child('$user/images/$name.png');
    url = await ref.getDownloadURL();

    a = CachedNetworkImageProvider(url);

    setState(() {
      icono = NetworkImage(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (!mover) {
          _sendNoti(MyLocalizations.of(context).getText('what_to_do'),
              document['name']);
        } else {
          setState(() {
            mover = false;
          });
        }
      },
      onTap: () {
        if (mover) {
          setState(() {
            mover = false;
          });
        }
      },
      child: SizedBox(
        width: getProportionateScreenWidth(167),
        child: Stack(
          children: [
            Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.39,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      image: (url != null)
                          ? DecorationImage(
                          image: CachedNetworkImageProvider(
                            url,
                          ),
                          fit: BoxFit.cover)
                          : null,
                    ),
                  ),
                ),
                Container(
                  width: getProportionateScreenWidth(167),
                  padding: EdgeInsets.only(
                    top: getProportionateScreenWidth(20),
                    bottom: getProportionateScreenWidth(20),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(5, 5),
                        blurRadius: 10,
                        color: Color(0xFFE9E9E9).withOpacity(0.56),
                      )
                    ],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        document['name'],
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width * 0.009)),
                      Text(
                        DateFormat('dd-MM-yy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(document['timestamp']))),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.037,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            (mover
                ? Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              color: Colors.grey.withOpacity(0.5),
              child: Container(
                  height: getProportionateScreenWidth(193),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            try {
                              final result = await InternetAddress.lookup(
                                  'google.com');
                              if (result.isNotEmpty &&
                                  result[0].rawAddress.isNotEmpty) {
                                _loading(cheinherit);
                                User user =
                                    FirebaseAuth.instance.currentUser;
                                var moved = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('products')
                                    .doc(document['name']);

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('products')
                                    .doc(document['name'])
                                    .get()
                                    .then(
                                      (datas) async {
                                    if (datas['index'] > 0) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .collection('products')
                                          .where('index',
                                          isEqualTo:
                                          datas['index'] - 1)
                                          .get()
                                          .then((data) async {
                                        if (data.docs[0].data()['name'] !=
                                            datas['name']) {
                                          var moved2 = FirebaseFirestore
                                              .instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .collection('products')
                                              .doc(data.docs[0]
                                              .data()['name']);

                                          FirebaseFirestore.instance
                                              .runTransaction(
                                                  (transaction) async {
                                                await transaction.update(
                                                  moved2,
                                                  {
                                                    'index': data.docs[0]
                                                        .data()['index'] +
                                                        1,
                                                  },
                                                );
                                              });
                                        }

                                        await FirebaseFirestore.instance
                                            .runTransaction(
                                                (transaction) async {
                                              transaction.update(
                                                moved,
                                                {
                                                  'index': datas['index'] - 1,
                                                },
                                              );
                                            });
                                      });
                                    }
                                  },
                                );
                                Navigator.of(cheinherit,
                                    rootNavigator: true)
                                    .pop('dialog');
                              } else {
                                Fluttertoast.showToast(
                                    msg: MyLocalizations.of(context)
                                        .getText("connfail"));
                              }
                            } on SocketException catch (_) {
                              Fluttertoast.showToast(
                                  msg: MyLocalizations.of(context)
                                      .getText("connfail"));
                            }
                          },
                          child: Icon(
                            Icons.arrow_left,
                            color: Colors.white,
                            size: getProportionateScreenWidth(100),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            try {
                              final result = await InternetAddress.lookup(
                                  'google.com');
                              if (result.isNotEmpty &&
                                  result[0].rawAddress.isNotEmpty) {
                                _loading(cheinherit);
                                User user =
                                    FirebaseAuth.instance.currentUser;
                                var moved = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('products')
                                    .doc(document['name']);

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('products')
                                    .doc(document['name'])
                                    .get()
                                    .then(
                                      (datas) async {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .collection('products')
                                        .get()
                                        .then((data) async {
                                      int test = datas['index'] + 1;

                                      if (test < data.docs.length) {
                                        for (var j = 0;
                                        j < data.docs.length;
                                        j++) {
                                          if (data.docs[j]
                                              .data()['index'] ==
                                              test &&
                                              data.docs[j]
                                                  .data()['name'] !=
                                                  datas['name']) {
                                            var moved2 = FirebaseFirestore
                                                .instance
                                                .collection('users')
                                                .doc(user.uid)
                                                .collection('products')
                                                .doc(data.docs[j]
                                                .data()['name']);

                                            FirebaseFirestore.instance
                                                .runTransaction(
                                                    (transaction) async {
                                                  transaction.update(
                                                    moved2,
                                                    {
                                                      'index':
                                                      data.docs[j].data()[
                                                      'index'] -
                                                          1,
                                                    },
                                                  );
                                                });
                                          }
                                        }

                                        await FirebaseFirestore.instance
                                            .runTransaction(
                                                (transaction) async {
                                              transaction.update(
                                                moved,
                                                {
                                                  'index': datas['index'] + 1,
                                                },
                                              );
                                            });
                                      }
                                    });
                                  },
                                );

                                Navigator.of(cheinherit,
                                    rootNavigator: true)
                                    .pop('dialog');
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
                          child: Icon(
                            Icons.arrow_right,
                            color: Colors.white,
                            size: getProportionateScreenWidth(100),
                          ),
                        ),
                      ],
                    ),
                  )),
            )
                : Container()),
          ],
        ),
      ),
    );
  }
}
