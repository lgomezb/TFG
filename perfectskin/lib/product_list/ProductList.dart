
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';
import 'Product.dart';
import 'package:perfectskin/utils/Size_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';



class ProductList extends StatefulWidget {
  ProductList({Key key}) : super(key: key);

  @override
  State createState() => new ProductLists();
}

class ProductLists extends State<ProductList> {
  List<String> cacheList = [];
  List<int> cacheColor = [];
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  var focus = new FocusNode();

  void onSendMessage(String nom) async {
    bool kgoing = true;
    User user = FirebaseAuth.instance.currentUser;
    if (nom.trim() != '') {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .where('name', isEqualTo: nom)
          .get()
          .then((data) async {
        if (data.docs.length > 0) kgoing = false;
      });

      if (kgoing) {
        var counter = 0;
        var documentReference = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('products')
            .doc(nom);

        documentReference.set({'id': nom});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('products')
        .get()
        .then((data) async {
    counter = data.docs.length;
    });
        FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(
            documentReference,
            {
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
              'name': nom,
              'index': counter,

            },
          );
        });
      }
    } else {
      Fluttertoast.showToast(
          msg: MyLocalizations.of(context).getText('writeproduct'));
    }
  }

  void color(String nombre) {
    AlertDialog dialog = new AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      title: Text(MyLocalizations.of(context).getText('choosecolor')),
      actions: <Widget>[
        FlatButton(
          child: Text(MyLocalizations.of(context).getText('morecolors')),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            colors(nombre);
          },
        ),
        FlatButton(
          child: Text(MyLocalizations.of(context).getText('c_product')),
          onPressed: () async {
            try {
              final result = await InternetAddress.lookup('google.com');
              if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                if (pickerColor == Color(0xff443a49)) {
                  Fluttertoast.showToast(
                      msg: MyLocalizations.of(context)
                          .getText('selectcolor'));
                } else {
                  try {
                    final result = await InternetAddress.lookup('google.com');
                    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                      setState(() => currentColor = pickerColor);
                      String colorString =
                          currentColor.toString(); // Color(0x12345678)
                      String valueString =
                          colorString.split('(0x')[1].split(')')[0];
                      if (valueString.contains('ff000000'))
                        valueString = 'ff515151';
                      int value = int.parse(valueString, radix: 16);
                      onSendMessage(nombre.trim());
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    } else {
                      Fluttertoast.showToast(
                          msg: MyLocalizations.of(context)
                              .getText('connfail'));
                    }
                  } on SocketException catch (_) {
                    Fluttertoast.showToast(
                        msg: MyLocalizations.of(context).getText("connfail"));
                  }
                }
              } else {
                Fluttertoast.showToast(
                    msg: MyLocalizations.of(context).getText('connfail'));
              }
            } on SocketException catch (_) {
              Fluttertoast.showToast(
                  msg: MyLocalizations.of(context).getText("connfail"));
            }
          },
        ),
      ],
      content: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        child: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: currentColor,
            onColorChanged: changeColor,
          ),
        ),
      ),
    );
    showDialog(context: context, builder: (_) => dialog);
  }

  void changeColor(Color color) {
    setState(() => (mounted) ? pickerColor = color : null);
  }

  void colors(String name) {
    AlertDialog dialog = new AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2))),
      title: Text(MyLocalizations.of(context).getText('choosecolor')),
      actions: <Widget>[
        FlatButton(
          child: Text(MyLocalizations.of(context).getText('back')),
          onPressed: () {
            onSendMessage(name.trim());
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
        ),
        FlatButton(
          child: Text(MyLocalizations.of(context).getText('c_product')),
          onPressed: () async {
            if (pickerColor == Color(0xff443a49)) {
              Fluttertoast.showToast(
                  msg: MyLocalizations.of(context).getText('selectcolor'));
            } else {
              try {
                final result = await InternetAddress.lookup('google.com');
                if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                  setState(() => currentColor = pickerColor);
                  String colorString =
                      currentColor.toString(); // Color(0x12345678)
                  String valueString =
                      colorString.split('(0x')[1].split(')')[0];
                  int value = int.parse(valueString, radix: 16);
                  onSendMessage(name.trim());
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                } else {
                  Fluttertoast.showToast(
                      msg: MyLocalizations.of(context).getText("connfail"));
                }
              } on SocketException catch (_) {
                Fluttertoast.showToast(
                    msg: MyLocalizations.of(context).getText("connfail"));
              }
            }
          },
        ),
      ],
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: changeColor,
          enableLabel: true,
          pickerAreaHeightPercent: 0.7,
        ),
      ),
    );
    showDialog(context: context, builder: (_) => dialog);
  }

  void _sendNoti(String value, BuildContext context) {
    final nameController = TextEditingController();

    AlertDialog dialog = new AlertDialog(
      title: new Center(
          child: Text(
        "• " + MyLocalizations.of(context).getText('nameproduct') + " •",
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
          child: Text(MyLocalizations.of(context).getText('c_product')),
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
                  msg: MyLocalizations.of(context).getText('rename2'));
            }
          },
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    SizeConfig().init(context);
      return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(title: Text(MyLocalizations.of(context).getText('products'), style: TextStyle(color: Theme.of(context).buttonColor)), backgroundColor: Theme.of(context).scaffoldBackgroundColor,),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _sendNoti(
                  MyLocalizations.of(context).getText('addproduct'), context);
              FocusScope.of(context).requestFocus(focus);
            },
            child: Icon(Icons.add, color: Theme.of(context).buttonColor,),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
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

                Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(top: 108),
                        child: Container(
                          height: SizeConfig.screenHeight,
                          child: ReorderableFirebaseList(
                              collection: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('products'),
                              indexKey: 'index',
                              itemBuilder: (BuildContext context, int index,
                                  DocumentSnapshot doc) {
                                return Row(
                                  key: Key(doc.id),
                                  children: <Widget>[
                                    Product(
                                        document: doc.data(),
                                        cheinherit: context),
                                  ],
                                );
                              }),
                        ),
                      ),
                    ),
                  ],
                ),

            ],
          ),
      );

  }
}

typedef ReorderableWidgetBuilder = Widget Function(
    BuildContext context, int index, DocumentSnapshot doc);

class ReorderableFirebaseList extends StatefulWidget {
  const ReorderableFirebaseList({
    Key key,
    @required this.collection,
    @required this.indexKey,
    @required this.itemBuilder,
    this.descending = false,
  }) : super(key: key);

  final CollectionReference collection;
  final String indexKey;
  final bool descending;
  final ReorderableWidgetBuilder itemBuilder;

  @override
  _ReorderableFirebaseListState createState() =>
      _ReorderableFirebaseListState();
}

class _ReorderableFirebaseListState extends State<ReorderableFirebaseList> {
  List<DocumentSnapshot> _docs;
  Future _saving;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _saving,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<QuerySnapshot>(
            stream: widget.collection
                .orderBy(widget.indexKey, descending: widget.descending)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                _docs = snapshot.data.docs;
                if (_docs.length == 0) {
                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width * 0.46,
                            height: MediaQuery.of(context).size.height * 0.26,
                            child: FittedBox(
                              child: Image(
                                image: AssetImage("assets/img/thinking.png"),
                              ),
                            )),
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.04),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: FittedBox(
                                child: Column(children: <Widget>[
                              Text(
                                MyLocalizations.of(context).getText('no_product'),
                                style: TextStyle(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                MyLocalizations.of(context).getText('no_product2'),
                                style: TextStyle(
                                  color: Theme.of(context).hoverColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ]))),
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.05),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02),
                    child: GridView.count(
                      crossAxisCount: 2,
                      primary: false,
                      childAspectRatio: (0.846),
                      mainAxisSpacing: getProportionateScreenWidth(20),
                      crossAxisSpacing: getProportionateScreenWidth(20),
                      padding: EdgeInsets.only(
                          right: getProportionateScreenWidth(20),
                          left:
                              getProportionateScreenWidth(23)),
                      children: List.generate(_docs.length, (index) {
                        return widget.itemBuilder(context, index, _docs[index]);
                      }),
                    ),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
