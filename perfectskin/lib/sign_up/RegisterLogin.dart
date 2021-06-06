import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:perfectskin/calendar/HomeScreen.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:perfectskin/main.dart' as main;
import 'package:perfectskin/screens/Survey.dart';

class RegisterLogin {
  static Future<dynamic> register(
      String email, String password, BuildContext context, String name) async {
    void _sendNoti(String value) { //Shows possible errors
      AlertDialog dialog = new AlertDialog(
        title: new Text(value),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        actions: <Widget>[
          new TextButton(
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

    User user;
    try {
      user = (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password))
          .user;
    } catch (error) {
      Navigator.of(context, rootNavigator: true).pop('dialog');

      switch (error) {
        case "email-already-in-use":
          _sendNoti(MyLocalizations.of(context).getText('exist2'));
          return MyLocalizations.of(context).getText('exist2');
        case "error-invalid-email":
          _sendNoti(MyLocalizations.of(context).getText('wrongemail'));
          return "The email is wrong";
        case "weak-password":
          _sendNoti(MyLocalizations.of(context).getText('shortpsswd'));
          return "The password is too short";
        default:
          _sendNoti(error.toString());
      }
    }
    if (user != null) {

      var status = await OneSignal.shared.getPermissionSubscriptionState();

      Map<String, dynamic> userToRegister = Map();

      userToRegister['email'] = user.email;
      userToRegister['isEmailVerified'] = false;
      userToRegister['oneSignalId'] = status.subscriptionStatus.userId;
      userToRegister['google'] = false;
      userToRegister['name'] = name;
      userToRegister['apple'] = false;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userToRegister);

      main.name = name;
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Navigator.pushReplacement(
        context,
        // We'll create the SelectionScreen in the next step!
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  static login(BuildContext context,
      {bool providerGoogle, String email, String password}) async {
    User user;

    void _sendNoti(String value) {
      AlertDialog dialog = new AlertDialog(
        title: new Text(value),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        actions: <Widget>[
          new TextButton(
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop('dialog');
            },
            child: new Text(
              MyLocalizations.of(context).getText('agreed'),
            ),
          ),
        ],
      );

      showDialog(context: context, builder: (_) => dialog);
    }

    bool google = true;
    bool exist = false;

    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((data) async {
      if (data.docs.length > 0) {
        exist = true;
        for (DocumentSnapshot ds in data.docs) {
          await ds.reference.get().then((value) {
            google = value.data()['google'];
          });
        }
      }
    });
    if (exist) {
      if (!google) {
        user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email.toLowerCase().trim(), password: password))
            .user;

        if (user != null) {
          var status = await OneSignal.shared.getPermissionSubscriptionState();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .then((data) {
            main.name = data['name'];
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'oneSignalId': status.subscriptionStatus.userId});
          // Aqui haces la navegación a la otra pantalla
          Navigator.of(context, rootNavigator: true).pop('dialog');
          Navigator.pop(context);

          Navigator.pushReplacement(
            context,
            // We'll create the SelectionScreen in the next step!
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else if (email.contains('gmail')) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          _sendNoti(
            MyLocalizations.of(context).getText('onlygoogle'),
          );
        }
      }
    } else {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      _sendNoti(MyLocalizations.of(context).getText('notexistemail'));
    }
  }
}

Future<void> resetPassword(String email) async {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  await _firebaseAuth.sendPasswordResetEmail(email: email);
}
