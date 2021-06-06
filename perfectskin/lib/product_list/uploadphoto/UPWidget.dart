import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:perfectskin/product_list/ProductList.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';
import 'dart:io' as io;

class Uploader extends StatefulWidget {
  final File file;
  String nombre;

  Uploader({Key key, this.file, this.nombre})
      : super(key: key);
  createState() => _UploaderState(name: nombre);
}

class _UploaderState extends State<Uploader> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instanceFor(
          bucket: 'gs://perfectskin-3f85f.appspot.com');

  String name;

  _UploaderState({Key key, this.name});

  void _loading() {
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

  Future<bool> uploadFile() async {
    firebase_storage.UploadTask uploadTask;
    if (widget.file == null) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text("No file selected")));
    } else {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          _loading();
          User user = FirebaseAuth.instance.currentUser;

          String code = user.uid;

          // Create a Reference to the file
          firebase_storage.Reference ref = firebase_storage
              .FirebaseStorage.instance
              .ref()
              .child('$code')
              .child('images')
              .child('$name.png');

          final metadata = firebase_storage.SettableMetadata(
              contentType: 'image/jpeg',
              customMetadata: {'picked-file-path': widget.file.path});

          uploadTask = ref.putFile(io.File(widget.file.path), metadata);

          await uploadTask.whenComplete(() {
            Navigator.of(context, rootNavigator: true).pop('dialog');
              Navigator.pushReplacement(
                  context,
                  // We'll create the SelectionScreen in the next step!
                  MaterialPageRoute(builder: (context) => ProductList()));
          });

          return Future.value(true);
        }
      } on SocketException catch (_) {
        Fluttertoast.showToast(
            msg: MyLocalizations.of(context).getText('connfail'));
      }
    }
    return Future.value(false);
  }

  Color currentColor;

  void onSendMessage(String nom, int color) async {
    User user = FirebaseAuth.instance.currentUser;
    if (nom.trim() != '') {
      var countere = 0;
      var documentReference = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .doc(nom);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .get()
          .then((data) async {
        for (var i = 0; i < data.docs.length; i++) {
          countere++;
        }
      });

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'name': nom,
            'index': countere,
          },
        );
      });
    } else {
      Fluttertoast.showToast(
          msg: MyLocalizations.of(context).getText('writeproduct'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Allows user to decide when to start the upload
    return FlatButton.icon(
      label:
          Text(MyLocalizations.of(context).getText('continue').toUpperCase()),
      icon: Icon(Icons.cloud_upload),
      color: Colors.blue,
      onPressed: uploadFile,
    );
  }
}
