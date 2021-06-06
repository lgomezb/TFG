import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:perfectskin/utils/initialize_i18n.dart';
import 'package:perfectskin/theme/style.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';
import 'package:perfectskin/utils/constant.dart';
import 'package:perfectskin/stepper/Routine.dart';
import 'package:provider/provider.dart';


import 'calendar/HomeScreen.dart';
import 'screens/Entrada.dart';


String language = 'en';
String name = "";
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Map<String, Map<String, String>> localizedValues = await initializeI18n();
  var initializationSettingsAndroid =
  AndroidInitializationSettings('codex_logo');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {});
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
      });
  User user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((data) async {
      name = data['name'];
    });

    runApp(MyApp(localizedValues: localizedValues, userexists: true));

  } else {

    runApp(MyApp(localizedValues: localizedValues, userexists: false));
  }

  //language = ui.window.locale.toString().split("_")[0];--> Activate in case of add more languages

//  await AndroidAlarmManager.initialize();
}

class MyApp extends StatelessWidget {
  Map<String, Map<String, String>> localizedValues;
  bool userexists;
  MyApp({this.localizedValues, this.userexists});
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: CustomTheme.lightTheme,
      locale: Locale(language),
      localizationsDelegates: [
        MyLocalizationsDelegate(localizedValues),

        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: languages.map((language) => Locale(language, '')),
      //Colors chosen for the app in lightMode
      home: (userexists) ? HomeScreen() : Entrada(),
      //Which class is shown when anyone enter the app
    );
  }
}
